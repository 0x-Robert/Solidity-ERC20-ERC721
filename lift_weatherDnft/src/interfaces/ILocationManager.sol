// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ILocationManager {
    function nameOf(uint256 _locationId) external view returns (string memory) ;

    function locationOf(uint256 _locationId) external view returns (string memory lat, string memory lon);

    function locationsLength() external view returns (uint256);

    function getLocationId(string memory _lat, string memory _lon) external view returns (uint256);
}
