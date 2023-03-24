// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MyERC20 is ERC20 {
    IERC721 public nftContract;
    uint256 public nftTokenId;
    
    constructor(string memory _name, string memory _symbol, address _nftContract, uint256 _nftTokenId) ERC20(_name, _symbol) {
        nftContract = IERC721(_nftContract);
        nftTokenId = _nftTokenId;
    }

    function exchangeForNFT() external {
        require(nftContract.ownerOf(nftTokenId) == msg.sender, "You are not the owner of the NFT");
        _burn(msg.sender, balanceOf(msg.sender));
        nftContract.safeTransferFrom(msg.sender, address(this), nftTokenId);
    }
}

