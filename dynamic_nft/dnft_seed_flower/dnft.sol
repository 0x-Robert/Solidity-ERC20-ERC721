// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import "./Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract DynamicNFT is ERC721, ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;
    using Counters for Counters.Counter;
uint256 public temperature;
    bytes32 private jobId;
    uint256 private fee;
    Counters.Counter private _tokenIdCounter;
    bool public paused = false;
event RequestTemperature(bytes32 indexed requestId, uint256 temperature);
/**
     * @notice Initialize the link token and target oracle
     *
     * Kovan Testnet details:
     * Link Token: 0xa36085F69e2889c224210F603D836748e7dC0088
     * Oracle: 0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656 (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ERC721("Dynamic NFT", "DNFT") {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        setChainlinkOracle(0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
        temperature=0;
    }
function buildMetadata(uint256 _tokenId)
        private
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Dynamic NFT", "description":"Dynamic NFT Test","image": "https://gateway.pinata.cloud/ipfs/QmeAKDXvQyGUdvwRSvazCyj4CYeN6qrcpQr4Lmgf7Cc2UC", "attributes": ',
                                "[",
                                '{"trait_type": "Temperature",',
                                '"value":"',
                                Strings.toString(temperature),
                                '"}',
                                "]",
                                "}"
                            )
                        )
                    )
                )
            );
    }
function requestTempData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
// Set the URL to perform the GET request on
        req.add('get', 'http://api.weatherapi.com/v1/current.json?q=Aartselaar&Key=30e737e440484fd18a5134039221006');
req.add('path', 'current,temp_c'); 
        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10;
        req.addInt('times', timesAmount);
// Sends the request
        return sendChainlinkRequest(req, fee);
    }
/**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, uint256 _temperature) public recordChainlinkFulfillment(_requestId) {
        emit RequestTemperature(_requestId, _temperature);
        temperature = _temperature;
    }
/**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
//ERC721 functions
    function safeMint(uint minttimes) external payable {
  
  require(!paused);
     
        for(uint i=0;i<minttimes;i++){
   _safeMint(msg.sender, _tokenIdCounter.current()); 
   _tokenIdCounter.increment();
     
  }          
   
  
 }
function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override(ERC721)
    returns (string memory)
 {
  require(
  _exists(tokenId),
  "ERC721Metadata: URI query for nonexistent token"
  );
  
        return buildMetadata(tokenId);
 }
 
 //Return current counter value
 function getCounter()
        
  external
        view
        returns (uint256)
    {
        return _tokenIdCounter.current();
    }
function setTemp(uint256 newTemp) external{
        temperature = newTemp;
    }
}