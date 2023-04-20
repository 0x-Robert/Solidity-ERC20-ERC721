// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/token//ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RandomNFT is ERC721, VRFConsumerBaseV2, ConfirmedOwner {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event MetadataUpdate(uint256 indexed tokenId);
    event RequestSent(uint256 indexed requestId, uint32 numWords);
    event RequestFulfilled(uint256 indexed requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256 randomWord;
    }

    mapping(uint256 => string[]) private _randTokenURIs;
    mapping(uint256 => RequestStatus)
        public requests; /* requestId --> requestStatus */
    

    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 public numWords = 1;
    uint256 public lastRequestId;

    VRFCoordinatorV2Interface private immutable COORDINATOR;

    bytes32 constant KEY_HASH = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    uint64 private immutable SUBSCRIPTION_ID;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 private _callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 private _requestConfirmations = 3;

    constructor(string memory _name, string memory _symbol, uint64 _subscriptionId, address _coordinator)
    ERC721(_name, _symbol) 
    VRFConsumerBaseV2(_coordinator)
    ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            _coordinator
        );
        SUBSCRIPTION_ID = _subscriptionId;
    }

    /** public function */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // (bool fulfilled, uint256[] randomWords) = getRequestStatus(lastRequestId);
        RequestStatus memory request = requests[lastRequestId];
        string[] memory tokenURIs = _randTokenURIs[_tokenId];
        uint256 rand = request.randomWord % tokenURIs.length;
        return tokenURIs[rand];
    }

    /** external function */
    function mint(address _to, string[] memory _tokenURIs)
        external
        onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURIs);
        return newTokenId;
    }
    /** private function */
    function _setTokenURI(uint256 _tokenId, string[] memory _tokenURIs) private {
        require(_exists(_tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _randTokenURIs[_tokenId] = _tokenURIs;

        emit MetadataUpdate(_tokenId);
    }

    function getRequestStatus(
        uint256 _requestId 
    ) external view returns (bool fulfilled, uint256 randomWord) {
        require(requests[_requestId].exists, "request not found");
        RequestStatus memory request = requests[_requestId];
        return (request.fulfilled, request.randomWord);
    }

    function requestRandomWords()
        external
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            KEY_HASH,
            SUBSCRIPTION_ID,
            _requestConfirmations,
            _callbackGasLimit,
            numWords
        );
        requests[requestId] = RequestStatus({
            randomWord: 0,
            exists: true,
            fulfilled: false
        });
        // requestIds.push(requestId);
        emit RequestSent(requestId, _requestConfirmations);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(requests[_requestId].exists, "request not found");
        requests[_requestId].fulfilled = true;
        requests[_requestId].randomWord = _randomWords[0];
        lastRequestId = _requestId;
        emit RequestFulfilled(_requestId, _randomWords);
    }
}