// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("ToKenIn", "TKI") {
        _mint(msg.sender, initialSupply);
    }

    mapping(address => uint) public amount;

    function transferBetweenAccounts(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value > 0, "Transfer value must be greater than 0");
    require(amount[_from] >= _value, "Insufficient balance");
    amount[_from] -= _value;
    amount[_to] += _value;
    emit Transfer(_from, _to, _value);
    return true;
}



}