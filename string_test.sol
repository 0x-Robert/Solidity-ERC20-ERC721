// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract StringTesting {
    
    function stringCompare(string calldata _inputOne, string calldata _inputTwo) external pure returns (bool r) {
        
        bool rslt;
        
        //Solidity does not offer string comparison
        //Will produce TypeError: operator == not compatible with types string calldata and string calldata
        //rslt = (_inputOne == _inputTwo);
        
        //string memory testOne = "test";
        //string memory testTwo = "test";
        
        //Will produce TypeError: operator == not compatible with types string memory and string memory
        //rslt = (testOne == testTwo);
        
        rslt = (keccak256(abi.encodePacked(_inputOne)) == keccak256(abi.encodePacked(_inputTwo)));
        
        return rslt;
        
    }
    
    function stringCompareBytes(string calldata _inputOne, string calldata _inputTwo) external pure returns (bool r) {
        
        bool rslt;
        
        rslt = (keccak256(bytes(_inputOne)) == keccak256(bytes(_inputTwo)));
        
        return rslt;
        
    }
    
    function stringConcat(string calldata _inputOne, string calldata _inputTwo) external pure returns (string memory r) {
        
        string memory rslt = string(abi.encodePacked(_inputOne, _inputTwo));
        return rslt;
        
    }
    
    function stringConcatBytes(string calldata _inputOne, string calldata _inputTwo) external pure returns (string memory r) {
        
        string memory rslt = string(bytes.concat(bytes(_inputOne), bytes(_inputTwo)));
        return rslt;
        
    }
    
}