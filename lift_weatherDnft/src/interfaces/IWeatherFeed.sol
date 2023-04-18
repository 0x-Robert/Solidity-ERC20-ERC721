// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IWeatherFeed {
  function getLatestWeather(uint256 _locationId) external view returns (uint8);

  function requestLocationCurrentConditions(string memory _lat, string memory _lon) external;
}
