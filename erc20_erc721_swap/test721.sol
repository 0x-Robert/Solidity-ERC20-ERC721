
contract MyERC721Token {
    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balanceOf;

    address public erc20ContractAddress;

    constructor(address _erc20ContractAddress) {
        erc20ContractAddress = _erc20ContractAddress;
    }

    function exchangeForERC20(uint256 _tokenId, uint256 _amount) public {
        // Transfer ERC721 token from the caller to this contract
        require(owners[_tokenId] == msg.sender, "Caller does not own token");
        owners[_tokenId] = address(0);
        balanceOf[msg.sender]--;

        // Transfer ERC20 tokens to the caller
        MyERC20Token erc20Contract = MyERC20Token(erc20ContractAddress);
        erc20Contract.transfer(msg.sender, _amount);
    }

    function mint(address _to, uint256 _tokenId) public {
        owners[_tokenId] = _to;
        balanceOf[_to]++;
    }
}