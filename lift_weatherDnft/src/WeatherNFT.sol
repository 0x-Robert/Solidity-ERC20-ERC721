// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./interfaces/IWeatherFeed.sol";

contract WeatherNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    enum WeatherStatus {
        sunny,
        cloud,
        rain,
        snow
    }

    mapping(uint256 => uint256) private _locationIds;
    mapping(uint256 => string[4]) private _weatherURIs;
    mapping(uint8 => WeatherStatus) private _overrideWeatherIcon;

    IWeatherFeed private _weatherFeed;

    constructor(string memory _name, string memory _symbol, address _feed)
        ERC721(_name, _symbol)
    {
        _weatherFeed = IWeatherFeed(_feed);

        _overrideWeatherIcon[1] = WeatherStatus.sunny;
        _overrideWeatherIcon[2] = WeatherStatus.sunny;
        _overrideWeatherIcon[3] = WeatherStatus.sunny;
        _overrideWeatherIcon[4] = WeatherStatus.sunny;
        _overrideWeatherIcon[5] = WeatherStatus.sunny;
        _overrideWeatherIcon[6] = WeatherStatus.cloud;
        _overrideWeatherIcon[7] = WeatherStatus.cloud;
        _overrideWeatherIcon[8] = WeatherStatus.cloud;
        _overrideWeatherIcon[11] = WeatherStatus.cloud;
        _overrideWeatherIcon[12] = WeatherStatus.rain;
        _overrideWeatherIcon[13] = WeatherStatus.rain;
        _overrideWeatherIcon[14] = WeatherStatus.rain;
        _overrideWeatherIcon[15] = WeatherStatus.rain;
        _overrideWeatherIcon[16] = WeatherStatus.rain;
        _overrideWeatherIcon[17] = WeatherStatus.rain;
        _overrideWeatherIcon[18] = WeatherStatus.rain;
        _overrideWeatherIcon[19] = WeatherStatus.sunny;
        _overrideWeatherIcon[20] = WeatherStatus.sunny;
        _overrideWeatherIcon[21] = WeatherStatus.sunny;
        _overrideWeatherIcon[22] = WeatherStatus.sunny;
        _overrideWeatherIcon[23] = WeatherStatus.sunny;
        _overrideWeatherIcon[24] = WeatherStatus.sunny;
        _overrideWeatherIcon[25] = WeatherStatus.sunny;
        _overrideWeatherIcon[26] = WeatherStatus.sunny;
        _overrideWeatherIcon[29] = WeatherStatus.sunny;
        _overrideWeatherIcon[30] = WeatherStatus.sunny;
        _overrideWeatherIcon[31] = WeatherStatus.sunny;
        _overrideWeatherIcon[32] = WeatherStatus.sunny;
        _overrideWeatherIcon[33] = WeatherStatus.sunny;
        _overrideWeatherIcon[34] = WeatherStatus.sunny;
        _overrideWeatherIcon[35] = WeatherStatus.cloud;
        _overrideWeatherIcon[36] = WeatherStatus.cloud;
        _overrideWeatherIcon[37] = WeatherStatus.cloud;
        _overrideWeatherIcon[38] = WeatherStatus.cloud;
        _overrideWeatherIcon[39] = WeatherStatus.rain;
        _overrideWeatherIcon[40] = WeatherStatus.rain;
        _overrideWeatherIcon[41] = WeatherStatus.rain;
        _overrideWeatherIcon[42] = WeatherStatus.rain;
        _overrideWeatherIcon[43] = WeatherStatus.rain;
        _overrideWeatherIcon[44] = WeatherStatus.snow;
    }

    function locationOf(uint256 _tokenId) public view returns (uint256) {
        return _locationIds[_tokenId];
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireMinted(_tokenId);

        string[4] memory _tokenURIs = _weatherURIs[_tokenId];
        uint256 locationId = locationOf(_tokenId);
        uint8 weatherId = _weatherFeed.getLatestWeather(locationId);
        if (weatherId == 0) {
            return _tokenURIs[0];
        }
        return _tokenURIs[uint256(_overrideWeatherIcon[weatherId])];
    }

    function mint(
        address _to,
        string[4] memory _uris,
        uint256 _locationId
    ) external returns (uint256) {
        uint256 newTokenId = _tokenIds.current();
        _mint(_to, newTokenId);
        _setLocation(newTokenId, _locationId);
        _setWeatherURI(newTokenId, _uris);
        _tokenIds.increment();

        return newTokenId;
    }

    /**
     * @notice 각 토큰의 날씨 정보를 받는 컨트랙트를 설정하는 함수입니다.
     * @dev Feed가 올바른 인터페이스를 상속받았는지 확인할 필요가 있습니다.
     * @param _tokenId 토큰의 id
     * @param _locationId 변경할 location id
     */
    function setLocation(uint256 _tokenId, uint256 _locationId) external {
        address owner = ERC721.ownerOf(_tokenId);
        require(_msgSender() == owner, "WeaterNFT: caller is not onwer");
        _setLocation(_tokenId, _locationId);
    }

    function setWeatherURI(uint256 _tokenId, string[4] memory _uris) external {
        address owner = ERC721.ownerOf(_tokenId);
        require(_msgSender() == owner, "WeatherNFT: caller is not token owner");

        _setWeatherURI(_tokenId, _uris);
    }

    function setWeatherFeed(address _feed) external onlyOwner {
        _setWeatherFeed(_feed);
    }

    function _setLocation(uint256 _tokenId, uint256 _locationId) private {
        _locationIds[_tokenId] = _locationId;
    }

    function _setWeatherURI(uint256 _tokenId, string[4] memory _uris) private {
        _weatherURIs[_tokenId] = _uris;
    }

    function _setWeatherFeed(address _feed) private {
        _weatherFeed = IWeatherFeed(_feed);
    }
}
