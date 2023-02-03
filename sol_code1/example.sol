pragma solidity ^0.8.7;

contract Example {


    //storage에 변수를 저장하는 예시
    uint public a = 3; //함수 외부에 선언된 상태변수라 storage에 저장됨

    struct Item{
        uint price;
        uint units;
    }

    Item[] public items;
    function myFunc1() external view returns(uint, uint){
        uint b = 4; 
        return (a,b);
    }

    function myFunc2(uint _itemIdx) public returns (uint){
        Item storage item = items[_itemIdx];
        return item.units; 
    }

    //memory에 변수를 저장하는 예시
    function myFunc3(string memory str) public pure returns(uint, string memory, bytes memory){
        uint num = 99;
        bytes memory byt = hex"01";
        return (num, str, byt);

    }

    // calldata에 변수를 저장하는 예시
    function myFunc4(string calldata str) external pure returns(string memory){
        return str; 
    }
}