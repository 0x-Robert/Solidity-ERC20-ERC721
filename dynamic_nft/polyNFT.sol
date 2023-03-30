pragma  solidity ^0.8.7;


import "@openzeppelin/contracts@4.4.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.4.2/utils/Counter.sol" ;


contract PolyBloom is ERC721, ERC721URIStorage{

    using Counters for Counters.Counter; 

    Counters.Counter private _tokenIdCounter; 

    uint interval; 
    uint lastTimeStamp;


    string[] IpfsUri = [
        "https://~json",
        "https://~json",
        "https://~json"
    ];

    constructor() ERC721("POLYdNFTs", "dNFT"){
        interval = _interval ; 
        lastTimeStamp = block.timestamp;

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


    /// @dev this method is called by the Automation Nodes to check if `performUpkeep` should be performed
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = false;
        for (uint256 i = 0; i < SIZE && !upkeepNeeded; i++) {
            if (balances[i] < LIMIT) {
                // if one element has a balance < LIMIT then rebalancing is needed
                upkeepNeeded = true;
            }
        }
        return (upkeepNeeded, "");
    }

    /// @dev this method is called by the Automation Nodes. it increases all elements which balances are lower than the LIMIT
    function performUpkeep(bytes calldata /* performData */) external  {
        uint256 increment;
        uint256 _balance;
        for (uint256 i = 0; i < SIZE; i++) {
            _balance = balances[i];
            // best practice: reverify the upkeep is needed
            if (_balance < LIMIT) {
                // calculate the increment needed
                increment = LIMIT - _balance;
                // decrease the contract liquidity accordingly
                liquidity -= increment;
                // rebalance the element
                balances[i] = LIMIT;
            }
        }
    }

}