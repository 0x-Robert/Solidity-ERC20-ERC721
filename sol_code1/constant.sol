pragma solidity ^0.8.7; 

uint constant bigNum = 32**22 + 8;

contract Example {

    //constant는 선언 및 초기화를 해주어야 함 
    string constant str = "hello";
    bytes32 constant hash = keccak256("hello");

    //immutable은 선언해두었다. constructor에서 값을 할당할 수 있음
    address immutable owner = msg.sender ;
    uint immutable decimals;
    uint immutable maxBalance; 

    constructor(uint decimals_, address ref){
        decimals = decimals_;
        maxBalance = ref.balance; 

    }

    function isBalanceTooHigh(address other) public view returns (bool){
        return other.balance > maxBalance; 
    }
    
}