pragma solidity ^0.8.10;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Sample.sol";


contract TestSimpleStorage{
    // 주의 : solidity 파일로 테스트 파일을 생성할 때에 
    //파일명은 contract 명과 일치하게 하며, contract name은 Test~ 로 시작하고, 함수명도 test~ 로 시작하여야 합니다.
    function testSimpleStorage() public {
        SimpleStorage ss = new SimpleStorage();

        uint expected = 4;
        ss.set(expected);
        Assert.equal(ss.get(), expected, "value equal test");
    }
}