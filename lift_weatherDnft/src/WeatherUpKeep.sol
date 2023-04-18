// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import "./LocationManager.sol";
import "./interfaces/IWeatherFeed.sol";
import "./interfaces/ILocationManager.sol";
import "./WeatherFeed.sol";

contract WeatherUpKeep is ConfirmedOwner {
    // uint256 public interval;
    // uint256 public lastTimeStamp;

    IWeatherFeed private _weatherFeed;
    ILocationManager private _locationManager;

    // 1시간 = 3600000
    constructor(address _feed, address _manager) ConfirmedOwner(msg.sender) {
        _weatherFeed = IWeatherFeed(_feed);
        _locationManager = ILocationManager(_manager);
        // interval = _interval;
        // lastTimeStamp = block.timestamp;
    }

    // function checkUpkeep(
    //     bytes calldata /* checkData */
    // ) external view returns (bool upkeepNeeded, bytes memory performData) {
    //     upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    //     if (upkeepNeeded) {
    //         uint256 length = _locationManager.locationsLength();
    //         uint256[] memory locationIds = new [];
    //         for (uint i=0; i<length; i++) {
    //             (string memory lat, string memory lon) = _locationManager.locationOf(i);
    //             if (bytes(lat).length > 0 && bytes(lon).length > 0) {
    //                 locationIds.push(i);
    //             }
    //             // _weatherFeed.requestLocationCurrentConditions(lat, lon);
    //         }
    //     }
    // }

    function performUpkeep() external {
        for (uint256 i = 0; i < _locationManager.locationsLength(); i++) {
            // locationId가 존재하는지 확인
            (string memory lat, string memory lon) = _locationManager
                .locationOf(i);
            if (_locationManager.getLocationId(lat, lon) != 0) {
                _weatherFeed.requestLocationCurrentConditions(lat, lon);
            }
        }
    }
}
