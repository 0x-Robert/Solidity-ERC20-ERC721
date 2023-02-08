//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17; 

contract RockPaperScissors {

  // Event declarations
  event GameCreated(address originator, uint256 originatorBet);
  event GameJoined(address originator, address taker, uint256 originatorBet, uint256 takerBet);
  event OriginatorWins(address originator, address taker, uint256 betAmount);
  event TakerWins(address originator, address taker, uint256 betAmount);

  // Enums for Hand and Player Status
  enum Hand {
    Rock, 
    Paper,
    Scissors 
  }
  
  enum PlayerStatus {
    Win, 
    Lose, 
    Tie,
    Pending
  }

  enum GameStatus {
    NotStarted,
    Started,
    Complete, 
    Error 
  }

  // Player structure
  struct Player {
    address payable addr; // player's address
    uint256 betAmount; // player's bet amount
    Hand hand; // player's hand (rock/paper/scissors)
    PlayerStatus status; // player's status (win/lose/tie/pending)
  }

  // Game structure
  struct Game {
    uint256 betAmount;  // bet amount
    GameStatus status;  // current game status 
    Player originator;  // room owner information
    Player taker;   // participant information 
  }

  // Mapping of game rooms
  mapping(uint => Game) public rooms;
  uint public roomCount = 0;

  // Modifier to check if a hand is valid (rock/paper/scissors)
  modifier isValidHand (Hand _hand) {
    require((_hand == Hand.Rock) || (_hand == Hand.Paper) || (_hand == Hand.Scissors)); 
    _;
  }

  // Modifier to check if the sender is a player in the room
  modifier isPlayer (uint roomNum, address sender) {
    require(sender == rooms[roomNum].originator.addr || sender == rooms[roomNum].taker.addr );
    _; 
  }

  // Function to create a game room
  function createRoom (Hand _hand) public payable isValidHand(_hand) returns (uint roomNum) {
    // Deposits the bet amount, hence using the payable keyword

    rooms[roomCount] = Game({
      betAmount: msg.value, // bet amount
      status: GameStatus.NotStarted,
      originator: Player({
        hand: _hand,
        addr: payable(msg.sender),
        status: PlayerStatus.Pending,
        betAmount: msg.value 
      }),
      taker: Player({
        hand: Hand.Rock,
        addr: payable(msg.sender),
        status: PlayerStatus.Pending,
        betAmount: 0
      })
    });

    roomNum = roomCount; // assign the current room number to roomNum and return
    roomCount = roomCount + 1; // set the next room number
    emit GameCreated(msg.sender, msg.value); // emit event GameCreated
    return roomNum;
