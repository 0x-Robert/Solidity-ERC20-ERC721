// SPDX-License-Identifier: MIT
// 라이선스 명시

pragma solidity ^0.8.13;
//솔리디티 버전 명시

contract SimpleStorage {
    // State variable to store a number
    // 숫자를 저장하기 위해 상태변수 선언 
    uint public num;

    // You need to send a transaction to write to a state variable.
    // 상태변수를 쓰기 위해 트랜잭션을 보내야한다.
    function set(uint _num) public {
        num = _num;
    }

    
    // You can read from a state variable without sending a transaction.
    // 트랜잭션을 보내지 않고 상태변수를 읽을 수 있다.
    function get() public view returns (uint) {
        return num;
    }
}

