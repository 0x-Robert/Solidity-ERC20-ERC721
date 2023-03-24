pragma solidity ^0.8.0;

contract MyERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    address public nftContractAddress;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, address _nftContractAddress) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;

        nftContractAddress = _nftContractAddress;
    }

    function exchangeForNFT(uint256 _amount, uint256 _tokenId) public {
        // Transfer ERC20 tokens from the caller to this contract
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        balanceOf[msg.sender] -= _amount;
        balanceOf[nftContractAddress] += _amount;

        // Mint ERC721 token and transfer it to the caller
        MyERC721Token nftContract = MyERC721Token(nftContractAddress);
        nftContract.mint(msg.sender, _tokenId);
    }
}
