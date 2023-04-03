// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

// Chainlink Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// This import includes functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Dev imports
import "hardhat/console.sol";


contract BullBear is ERC721, ERC721Enumerable, ERC721URIStorage, KeeperCompatibleInterface, Ownable  {
    using Counters for Counters.Counter;

    //토큰아이디 카운터해주는 라이브러리 사용
    Counters.Counter private _tokenIdCounter;

    //interface 타입 변수 선언
    AggregatorV3Interface public pricefeed;
    int256 public currentPrice;

    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    //시간간격과 타임스탬프 변수 선언
    uint public /* immutable */ interval; 
    uint public lastTimeStamp;

    
    
    // IPFS URIs for the dynamic nft graphics/metadata.
    // NOTE: These connect to my IPFS Companion node.
    // You should upload the contents of the /ipfs folder to your own node for development.
    //민팅할 떄 bullNFT를 디폴트로 설정함, performUpKeep 함수를 통해 가격이 변하면 url을 수정하면 된다. 
    string[] bullUrisIpfs = [
        "https://ipfs.io/ipfs/QmRXyfi3oNZCubDxiVFre3kLZ8XeGt6pQsnAQRZ7akhSNs?filename=gamer_bull.json",
        "https://ipfs.io/ipfs/QmRJVFeMrtYS2CUVUM2cHJpBV5aX2xurpnsfZxLTTQbiD3?filename=party_bull.json",
        "https://ipfs.io/ipfs/QmdcURmN1kEEtKgnbkVJJ8hrmsSWHpZvLkRgsKKoiWvW9g?filename=simple_bull.json"
    ];
    string[] bearUrisIpfs = [
        "https://ipfs.io/ipfs/Qmdx9Hx7FCDZGExyjLR6vYcnutUR8KhBZBnZfAPHiUommN?filename=beanie_bear.json",
        "https://ipfs.io/ipfs/QmTVLyTSuiKGUEmb88BgXG3qNC8YgpHZiFbjHrXKH3QHEu?filename=coolio_bear.json",
        "https://ipfs.io/ipfs/QmbKhBXVWmwrYsTPFYfroR2N7NAekAMxHUVg2CWks7i9qj?filename=simple_bear.json"
    ];

    //event 변수 선언 
    event TokensUpdated(string marketTrend);

    // For testing with the mock on Rinkeby, pass in 10(seconds) for `updateInterval` and the address of my 
    // deployed  MockPriceFeed.sol contract (0xD753A1c190091368EaC67bbF3Ee5bAEd265aC420).
    // bear 또는 bull 상황에 맞춰서 tokenURI 업데이트 
    constructor(uint updateInterval, address _pricefeed) ERC721("Bull&Bear", "BBTK") {
        // Set the keeper update interval
        //변수 선언
        interval = updateInterval; 
        lastTimeStamp = block.timestamp;  //  seconds since unix epoch

        // set the price feed address to
        // BTC/USD Price Feed Contract Address on Rinkeby: https://rinkeby.etherscan.io/address/0xECe365B379E1dD183B20fc5f022230C044d51404
        // or the MockPriceFeed Contract
        pricefeed = AggregatorV3Interface(_pricefeed); // To pass in the mock

        // set the price for the chosen currency pair.
        currentPrice = getLatestPrice();
    }

    function safeMint(address to) public  {
        // Current counter value will be the minted token's token ID.
        uint256 tokenId = _tokenIdCounter.current();

        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();

        // Mint the token
        _safeMint(to, tokenId);

        // Default to a bull NFT
        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);

        console.log("DONE!!! minted token ", tokenId, " and assigned token url: ", defaultUri);
    }

    //checkUpkeep 함수는 체인 외부에서 performUpkeep 함수가 실행되어야 하는지 매 블록마다 체크한다. 
    //checkUpkeep 함수가 true를 리턴하면 체인 내부에 있는 performUpkeep 함수에 작성된 트리거가 발동한다.
    //리턴한 performData를 performUpkeep 함수에 넘긴다.
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData */) {
         upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;

    }

    function performUpkeep(bytes calldata /* performData */ ) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        //checkUpkeep 함수에서 업데이트를 확인 했더라도 performUpkeep에서 한 번 더 확인하는 것이 좋다.
        if ((block.timestamp - lastTimeStamp) > interval ) {
            //시간을 업데이트 하고
            lastTimeStamp = block.timestamp;         
            //최신가격을 가져온다. 
            int latestPrice =  getLatestPrice();

            //최종가격과 현재가격이 같은지 체크하고 같을 경우 변화가 없다는 것을 로그에 기록 
            if (latestPrice == currentPrice) {
                console.log("NO CHANGE -> returning!");
                return;
            }

            //가격에 맞춰서 토큰Uri 수정
            //현재가격이 최신 가격보다 높을경우 bear로 업데이트
            if (latestPrice < currentPrice) {
                // bear
                console.log("ITS BEAR TIME");
                updateAllTokenUris("bear");

            } else {
                // bull
                //현재가격이 최신 가격보다 낮을경우 bull로 업데이트
                console.log("ITS BULL TIME");
                updateAllTokenUris("bull");
            }

            // update currentPrice
            currentPrice = latestPrice;
        } else {
            console.log(
                " INTERVAL NOT UP!"
            );
            return;
        }

       
    }

    // Helpers
    //최신가격 가져오기
    //최신 가격을 가져올 때 latestRoundData 가 사용된다. latestRoundData는 AggregatorV3Interface 에 포함된 함수다. 여러 정보를 가져올 수 있지만 destruct해서 가격만 리턴시킨다.
    function getLatestPrice() public view returns (int256) {
         (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = pricefeed.latestRoundData();

        return price; //  example price returned 3034715771688
    }
  
    function updateAllTokenUris(string memory trend) internal {
        if (compareStrings("bear", trend)) {
            console.log(" UPDATING TOKEN URIS WITH ", "bear", trend);
            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, bearUrisIpfs[0]);
            } 
            
        } else {     
            console.log(" UPDATING TOKEN URIS WITH ", "bull", trend);

            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, bullUrisIpfs[0]);
            }  
        }   
        emit TokensUpdated(trend);
    }

    function setPriceFeed(address newFeed) public onlyOwner {
        pricefeed = AggregatorV3Interface(newFeed);
    }
    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }
    
    //글자 비교함수 
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }


    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}