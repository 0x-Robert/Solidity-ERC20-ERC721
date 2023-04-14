//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract Count {
    uint public counted=0;
    constructor() {}
    function count() public{
        counted+=1;
    }
}