// SPDX-License-Identifier: MIT
// Solidity 버전 선언
pragma solidity ^0.8.13;

contract Counter {
    //unsigned int면서 public한 변수로 count 선언
    uint public count;

    // Function to get the current count
    function get() public view returns (uint) {
        return count;
    }

    // Function to increment count by 1
    // 1씩 더해지는 count 변수 
    function inc() public {
        count += 1;
    }

    // Function to decrement count by 1
    // 1씩 마이너스 되는 count 변수 
    function dec() public {
        // This function will fail if count = 0
        count -= 1;
    }
}