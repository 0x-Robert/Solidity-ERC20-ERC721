// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "base64-sol/base64.sol";

contract DynamicNFT is VRFConsumerBase, ERC721Enumerable, Ownable{
    using SafeMath for uint256;
    using Strings for uint256;
    using Strings for uint8;

    // VRF Variables
    bytes32 public keyHash;
    uint256 public  fee;
    uint256 public randomResult;

    // ERC721 Variables

    // Token Data
    uint256 public TOKEN_PRICE;
    uint256 public MAX_TOKENS;
    uint256 public MAX_MINTS;

    // Metadata
    string public _baseTokenURI;

    // Maps
    mapping(uint256 => uint256) public randomMap; // maps a tokenId to a random number
    mapping(bytes32 => uint256) public requestMap; // maps a requestId to a tokenId
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor(
        address _link,
        address _coordinator, 
        bytes32 _keyhash,
        uint256 _fee,
        string memory name, 
        string memory symbol, 
        string memory baseURI,
        uint256 tokenPrice,
        uint256 maxTokens,
        uint256 maxMints
    ) 
    VRFConsumerBase(_coordinator, _link)
    ERC721(name, symbol)
    {
        // Chainlink setters
        keyHash = _keyhash;
        fee = _fee;

        // ERC721 setters
        setTokenPrice(tokenPrice);
        setMaxTokens(maxTokens);
        setMaxMints(maxMints);
        setBaseURI(baseURI);
    }

    /* ========== ERC721 FUNCTIONS ========== */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setMaxMints(uint256 maxMints_) public onlyOwner {
        MAX_MINTS = maxMints_;
    }

    function setTokenPrice(uint256 tokenPrice_) public onlyOwner {
        TOKEN_PRICE = tokenPrice_;
    }

    function setMaxTokens(uint256 maxTokens_) public onlyOwner {
        MAX_TOKENS = maxTokens_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function mintTokens(uint256 numberOfTokens) public payable {
        require(numberOfTokens <= MAX_MINTS, "Can only mint max purchase of tokens at a time");
        require(totalSupply().add(numberOfTokens) <= MAX_TOKENS, "Purchase would exceed max supply of Tokens");
        require(TOKEN_PRICE.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");

        for(uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (mintIndex < MAX_TOKENS) {
                _safeMint(msg.sender, mintIndex);

                // request a random number from VRF oracle
                bytes32 requestId = getRandomNumber();
                // map request to tokenId
                requestMap[requestId] = mintIndex;
            }
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // construct metdata from tokenId
        return constructTokenURI(tokenId);
    }

    function constructTokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // get random number from map
        uint256 randomNumber = randomMap[tokenId];
        // build tokenURI from randomNumber
        string memory randomTokenURI = string(abi.encodePacked(_baseTokenURI, randomNumber.toString(), ".png"));
        
        // metadata
        string memory name = string(abi.encodePacked("token #", tokenId.toString()));
        string memory description = "A dynamic NFT";

        // prettier-ignore
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', randomTokenURI, '"}')
                    )
                )
            )
        );
    }
    
    /** 
     * Requests randomness 
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        // constrain random number between 1-10
        uint256 modRandom = randomResult % 10 + 1;
        // get tokenId that created the request
        uint256 tokenId = requestMap[requestId];
        // store random result in token image map
        randomMap[tokenId] = modRandom;
    }
}