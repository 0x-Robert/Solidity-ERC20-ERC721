// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IWeatherFeed.sol";
import "./interfaces/ILocationManager.sol";
import "./LocationManager.sol";

contract WeatherFeed is ChainlinkClient, ConfirmedOwner, IWeatherFeed {
    using Chainlink for Chainlink.Request;
    /* ========== CONSUMER STATE VARIABLES ========== */
    
    struct RequestParams {
        uint256 locationId;
        string lat;
        string lon;
    }
    struct LocationResult {
        uint256 locationKey;
        string name;
        bytes2 countryCode;
    }
    struct CurrentConditionsResult {
        uint256 timestamp;
        uint24 precipitationPast12Hours;
        uint24 precipitationPast24Hours;
        uint24 precipitationPastHour;
        uint24 pressure;
        int16 temperature;
        uint16 windDirectionDegrees;
        uint16 windSpeed;
        uint8 precipitationType;
        uint8 relativeHumidity;
        uint8 uvIndex;
        uint8 weatherIcon;
    }
    // Maps
    mapping(bytes32 => CurrentConditionsResult)
        public requestIdCurrentConditionsResult;
    mapping(bytes32 => LocationResult) public requestIdLocationResult;
    mapping(bytes32 => RequestParams) public requestIdRequestParams;

    // locationId => requestId
    mapping(uint256 => bytes32) private _latestRequestIds; 
    string constant JOB_ID = "eb894ae815a14257b6682ddff0913e1b";
    uint256 public ORACLE_PAYMENT;

    ILocationManager private _locationManager;

    /**
     * @dev
     * @param _link 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * @param _oracle 0x7ca7215c6B8013f249A195cc107F97c4e623e5F5
     */
    /* ========== CONSTRUCTOR ========== */
    constructor(address _link, address _oracle, address _manager) ConfirmedOwner(msg.sender) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        setOraclePayment(((1 * LINK_DIVISIBILITY) / 100) * 25);
        setLocationManager(_manager);
    }
    /* ========== CONSUMER REQUEST FUNCTIONS ========== */

    /**
     * @notice Returns the current weather conditions of a location for the given coordinates.
     * @param _lat the latitude (WGS84 standard, from -90 to 90).
     * @param _lon the longitude (WGS84 standard, from -180 to 180).
     */
    function requestLocationCurrentConditions(
        string calldata _lat,
        string calldata _lon
        // string calldata _units
    ) public {
        uint256 locationId = _locationManager.getLocationId(_lat, _lon);

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(JOB_ID),
            address(this),
            this.fulfill.selector
        );
        req.add("lat", _lat);
        req.add("lon", _lon);
        req.add("units", "metric");
        bytes32 requestId = sendChainlinkRequest(req, ORACLE_PAYMENT);
        // Below this line is just an example of usage
        _storeRequestParams(
            requestId,
            locationId,
            _lat,
            _lon
        );
    }

    /* ========== CONSUMER FULFILL FUNCTIONS ========== */
    /**
     * @notice Consumes the data returned by the node job on a particular request.
     * @dev Only when `_locationFound` is true, both `_locationFound` and `_currentConditionsResult` will contain
     * meaningful data (as bytes). This function body is just an example of usage.
     * @param _requestId the request ID for fulfillment.
     * @param _locationFound true if a location was found for the given coordinates, otherwise false.
     * @param _locationResult the location information (encoded as LocationResult).
     * @param _currentConditionsResult the current weather conditions (encoded as CurrentConditionsResult).
     */
    function fulfill(
        bytes32 _requestId,
        bool _locationFound,
        bytes memory _locationResult,
        bytes memory _currentConditionsResult
    ) public recordChainlinkFulfillment(_requestId) {
        if (_locationFound) {
            _latestRequestIds[requestIdRequestParams[_requestId].locationId] = _requestId;
            _storeLocationResult(_requestId, _locationResult);
            _storeCurrentConditionsResult(_requestId, _currentConditionsResult);
        }
    }

    function setLocationManager(address _manager) public onlyOwner {
        _locationManager = ILocationManager(_manager);
    }

    function getLatestWeather(uint256 _locationId) external view returns (uint8) {
        // _locationId로 requestId를 가져온다.
        bytes32 requestId = _latestRequestIds[_locationId];
        return requestIdCurrentConditionsResult[requestId].weatherIcon;
    }

    /* ========== OTHER FUNCTIONS ========== */
    function setOraclePayment(uint256 _payment) public onlyOwner {
        ORACLE_PAYMENT = _payment;
    }
 
    function withdrawLink() public onlyOwner {
        LinkTokenInterface linkToken = LinkTokenInterface(
            chainlinkTokenAddress()
        );
        require(
            linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function setOracle(address _oracle) external onlyOwner {
        setChainlinkOracle(_oracle);
    }

    /* ========== PRIVATE FUNCTIONS ========== */
    function _storeRequestParams(
        bytes32 _requestId,
        uint256 _locationId,
        string calldata _lat,
        string calldata _lon
    ) private {
        RequestParams memory requestParams;
        requestParams.locationId = _locationId;
        requestParams.lat = _lat;
        requestParams.lon = _lon;
        requestIdRequestParams[_requestId] = requestParams;
    }

    function _storeLocationResult(
        bytes32 _requestId,
        bytes memory _locationResult
    ) private {
        LocationResult memory result = abi.decode(
            _locationResult,
            (LocationResult)
        );
        requestIdLocationResult[_requestId] = result;
    }

    function _storeCurrentConditionsResult(
        bytes32 _requestId,
        bytes memory _currentConditionsResult
    ) private {
        CurrentConditionsResult memory result = abi.decode(
            _currentConditionsResult,
            (CurrentConditionsResult)
        );
        requestIdCurrentConditionsResult[_requestId] = result;
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
