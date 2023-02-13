// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract YongariToken is ERC20 {
    uint public totalSupply;
    string public constant name = "Yongari Token";
    string public constant symbol = "Yong";
    uint8 public constant decimals = 2;
    uint constant _initial_supply = 2100000000;

    function YONGToken() public{
        totalSupply_ = totalSupply;
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    // constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    //     // Mint 100 tokens to msg.sender
    //     // Similar to how
    //     // 1 dollar = 100 cents
    //     // 1 token = 1 * (10 ** decimals)
    //     _mint(msg.sender, 100 * 10 ** uint(decimals()));
    // }


    
}