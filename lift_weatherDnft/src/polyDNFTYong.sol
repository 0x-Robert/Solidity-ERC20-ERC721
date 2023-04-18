// SPDX-License-Identifier: GPL-3.0
pragma  solidity ^0.8.7;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//0x5DfB8244EcCF8a65bA65824435484643f3c65f4b
contract PolyBloom is ERC721, ERC721URIStorage{

    using Counters for Counters.Counter; 

    Counters.Counter private _tokenIdCounter; 

    uint interval; 
    uint lastTimeStamp;
    string[] IpfsUri; 

    event IpfsUriUpdated(string[] ipfsUri);

    function setIpfsUri(string[] memory _uri) public {
        IpfsUri = _uri;
        emit  IpfsUriUpdated(IpfsUri);
    }

    function getIpfsUri() public view returns (string[] memory) {
        return IpfsUri;
    }

    constructor(uint _interval ) ERC721("Yong-POLYdNFTs", "dNFT"){
        interval = _interval ; 
        lastTimeStamp = block.timestamp;

    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current(); 
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function growFlower(uint256 _tokenId) public{
        if(flowerStage(_tokenId) >= 2){return; }
        uint256 newVal = flowerStage(_tokenId) + 1;
        string memory newUri = IpfsUri[newVal];
        _setTokenURI(_tokenId, newUri);
    }

    function flowerStage(uint256 _tokenId) public view returns (uint256){
        string memory _uri = tokenURI(_tokenId);
        for (uint256 i = 0; i < IpfsUri.length; i++) {
            if (keccak256(bytes(_uri)) == keccak256(bytes(IpfsUri[i]))) {
                return i;
        }
         }
                return 0;
         }


    /// @dev this method is called by the Automation Nodes to check if `performUpkeep` should be performed
    function checkUpkeep(bytes calldata) external view returns (bool upkeepNeeded, bytes memory){
      upkeepNeeded = (block.timestamp - lastTimeStamp) > interval; 
    }

    /// @dev this method is called by the Automation Nodes. it increases all elements which balances are lower than the LIMIT
    function performUpkeep(bytes calldata /* performData */) external  {
        if ((block.timestamp - lastTimeStamp) > interval ){
            lastTimeStamp = block.timestamp; 
            //counter = counter + 1;
            //growFlower(_tokenId);
            growFlower(0);
        }
    }
        function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

}