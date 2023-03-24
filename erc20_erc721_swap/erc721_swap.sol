// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyERC721 is ERC721, IERC721Receiver {
    IERC20 public erc20Contract;
    uint256 public erc20Amount;
    
    constructor(string memory _name, string memory _symbol, address _erc20Contract, uint256 _erc20Amount) ERC721(_name, _symbol) {
        erc20Contract = IERC20(_erc20Contract);
        erc20Amount = _erc20Amount;
    }

    function exchangeForERC20() external {
        require(ownerOf(1) == msg.sender, "You are not the owner of the token");
        erc20Contract.transfer(msg.sender, erc20Amount);
        _burn(1);
    }
    
    function onERC721Received(address, address, uint256, bytes memory) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
