// SPDX-License-Identifier: MIT
// 라이선스 표시 

pragma solidity ^0.8.13;
//솔리디티 버전 명시 

contract Variables {
    // State variables are stored on the blockchain.
    // 스테이트 변수는 블록체인에 저장됩니다. 
    string public text = "Hello";
    uint public num = 123;


    function doSomething() public {
        // Local variables are not saved to the blockchain.
        // 로컬 변수는 블록체인에 저장되지 않습니다.
        uint i = 456;

        // Here are some global variables
        // 여기에 있는 변수는 글로벌 변수입니다. 
        uint timestamp = block.timestamp; // Current block timestamp 현재 블록 타임스탬프
        address sender = msg.sender; // address of the caller 호출한 사람의 주소 
    }
}