pragma solidity ^0.8.14;

contract SimpleStorage{

    //동적 크기의 배열 상태변수 선언
    uint256[] stateArray;

    function doStuff() public {
        //솔리디티는 아래와 같은 지역변수는 자동으로 storage reference로 생성합니다.
        //이것은 다음과 같이 명시한 것과 같습니다. uint256[] storage localReference = stateArray
        uint256[] localReference = stateArray;

        uint256[] memory memArray = new uint256[](5);
    }
    function simpleFunction() public pure returns(uint){
        uint a; //지역변수 선언 
        uint b = 1; //지역변수 선언 및 초기화
        a = 1;
        uint result = a + b;
        return result ;
    }
}