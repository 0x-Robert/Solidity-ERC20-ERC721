// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
contract MyToken is ERC20, Ownable {
    address public nftContract;

    constructor(string memory name, string memory symbol, address _nftContract, uint256 initialSupply) ERC20("TokenInside", "TKI") {
        nftContract = _nftContract;
        _mint(msg.sender, initialSupply);
    }

    function swapWithNFT(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(ERC721(nftContract).balanceOf(msg.sender) >= amount, "Insufficient NFT balance");
        _burn(msg.sender, amount);
        ERC721(nftContract).transferFrom(msg.sender, address(this), amount);
    }

    function setNFTContract(address _nftContract) external onlyOwner {
        require(_nftContract != address(0), "Invalid NFT address");
        nftContract = _nftContract;
    }
}

contract MyNFT is ERC721, Ownable {
    address public tokenContract;

    constructor(string memory name, string memory symbol, address _tokenContract, uint256 initialSupply) ERC721("TokenInside", "TKI") {
        tokenContract = _tokenContract;
        _mint(msg.sender, initialSupply);
    }

    function swapWithToken(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        _transfer(msg.sender, address(this), tokenId);
        MyToken(tokenContract).transfer(msg.sender, 1);
    }

    function setTokenContract(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid token address");
        tokenContract = _tokenContract;
    }

        function mintNFT(address recipient, string memory tokenURI,string memory _name,string memory _description) public onlyOwner returns (uint256) {
       
        _mint(recipient, newItemId);
       

        return newItemId;
    }
}
