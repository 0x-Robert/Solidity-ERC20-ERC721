// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/ILocationManager.sol";

contract LocationManager is ConfirmedOwner, ILocationManager {
    using Counters for Counters.Counter;
    Counters.Counter private _locationIds;

    struct Location {
        string lat;
        string lon;
    }

    mapping(uint256 => string) private _names;
    mapping(uint256 => Location) private _locations;
    mapping(string => mapping(string => uint256)) public getLocationId;

    // Location[] public allLocations;

    event LocationCreated(
        uint256 indexed _locationId,
        string _name,
        string _lat,
        string _lon
    );

    constructor() ConfirmedOwner(msg.sender) {}

    function nameOf(uint256 _locationId) public view returns (string memory) {
        return _names[_locationId];
    }

    function locationOf(
        uint256 _locationId
    ) public view returns (string memory lat, string memory lon) {
        Location memory location = _locations[_locationId];
        lat = location.lat;
        lon = location.lon;
    }

    function locationsLength() public view returns (uint256) {
        return _locationIds.current();
    }

    /**
     * @param _name 위치 이름
     * @param _lat the latitude (WGS84 standard, from -90 to 90)
     * @param _lon the latitude (WGS84 standard, from -180 to 180)
     */
    function addLocation(
        string memory _name,
        string calldata _lat,
        string calldata _lon
    ) external onlyOwner {
        require(
            _isValidLocation(_lat, _lon),
            "'lat' or 'lon' is an invalid value"
        );
        require(getLocationId[_lat][_lon] == 0, "location is aready exist");
        _addLocation(_name, _lat, _lon);
    }

    function _addLocation(
        string memory _name,
        string memory _lat,
        string memory _lon
    ) private {
        _locationIds.increment();
        uint256 newLocationId = _locationIds.current();
        _names[newLocationId] = _name;
        _locations[newLocationId] = Location(_lat, _lon);
        getLocationId[_lat][_lon] = newLocationId;

        emit LocationCreated(newLocationId, _name, _lat, _lon);
    }

    function removeLocation(uint256 _locationId) external onlyOwner {
        Location memory location = _locations[_locationId];
        require(_isValidLocation(location.lat, location.lon), "");
        _removeLocation(_locationId);
    }

    function _removeLocation(uint256 _locationId) private {
        Location memory location = _locations[_locationId];
        uint256 requestId = getLocationId[location.lat][location.lon];
        require(requestId != 0, "is not exist location");
        delete _names[requestId];
        delete _locations[requestId];
        delete getLocationId[location.lat][location.lon];
    }

    function _isValidLocation(
        string memory _lat,
        string memory _lon
    ) private pure returns (bool) {
        return bytes(_lat).length > 0 && bytes(_lon).length > 0;
    }

    // function _isExistLocation() private pure returns (bool) {
    //     return
    // }
}
