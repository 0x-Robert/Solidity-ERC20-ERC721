//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17; 

contract RPS {

    constructor() payable {
    }

     /*
    event GameCreated(address originator, uint256 originator_bet);
    event GameJoined(address originator, address taker, uint256 originator_bet, uint256 taker_bet);
    event OriginatorWin(address originator, address taker, uint256 betAmount);
    event TakerWin(address originator, address taker, uint256 betAmount);
   */

    //가위, 바위, 보에 대한 enum
    //rock 0 / paper 1 / scissors 2 
    enum Hand {
        rock, 
        paper,
        scissors 
    }
    //플레이어 상태
    //이김, 짐, 비김, 대기 중 
    enum PlayerStatus{
        STATUS_WIN, 
        STATUS_LOSE, 
        STATUS_TIE,
        STATUS_PENDING
    }

    enum GameStatus {
        STATUS_NOT_STARTED,
        STATUS_STARTED,
        STATUS_COMPLETE, 
        STATUS_ERROR 
    }

    struct Player{
        address payable addr; //주소 
        uint256 playerBetAmount; //베팅 금액
        Hand hand; //플레이어가 낸 가위/바위/보 
        PlayerStatus playerStatus; //플레이어의 상태를 담은 변수
    
    }


    struct Game {
        uint256 betAmount;  //베팅 금액
        GameStatus gameStatus;  //게임의 현재 상태 
        Player originator;  //방장 정보
        Player taker;   //참가자 정보 
    }

    mapping(uint => Game) rooms;
    uint roomLen = 0;

    modifier isValidHand (Hand _hand){
        require((_hand == Hand.rock) || (_hand == Hand.paper) || (_hand == Hand.scissors)); 
        _;
    }

    modifier isPlayer (uint roomNum, address sender){
        require(sender == rooms[roomNum].originator.addr || sender == rooms[roomNum].taker.addr );
        _; 
    }

    //가위바위보 게임을 하기위한 방을 만들기 
    //1. 방장이 createRoom 호출 
    function createRoom (Hand _hand) public payable isValidHand(_hand) returns (uint roomNum){

        //베팅금액을 입금하기 때문에 payable 키워드 사용
        
        rooms[roomLen] = Game({
            betAmount: msg.value,//베팅 금액 
            gameStatus: GameStatus.STATUS_NOT_STARTED,
            originator: Player({
                hand: _hand,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: msg.value 
            }),
            taker: Player({
                hand: Hand.rock,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount:0
            })
        });
        roomNum = roomLen; //현재 방번호를 roomNum에 할당시켜 반환
        roomLen = roomLen+1;    //다음 방번호를 설정
        return roomNum;
        //Emit gameCreated(msg.sender, msg.value)


    }

    //join room 방에 참가하기
    function joinRoom(uint roomNum, Hand _hand) public payable isValidHand(_hand){
        // Emit gameJoined(game.originator.addr, msg.sender, game.betAmount, msg.value);
        rooms[roomNum].taker = Player({
            hand: _hand,
            addr: payable(msg.sender),
            playerStatus: PlayerStatus.STATUS_PENDING,
            playerBetAmount: msg.value 
        });
        rooms[roomNum].betAmount = rooms[roomNum].betAmount + msg.value; 
        compareHands(roomNum);
    }

    //만들어진 방들의 총 베팅금액을 확인하기
    //방장 혹은 참가자가 checkTotalPay함수를 호출함 
    function checkTotalPay(uint roomNum) public view returns(uint roomNumPay){
        return rooms[roomNum].betAmount;
    }

    //게임을 마치기 / 게임결과에따라 베팅금액을 송금하기 
    //방장 혹은 참가자가payout을 호출함 
    function payout(uint roomNum) public payable isPlayer(roomNum, msg.sender){
        if(rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_TIE && rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_TIE ){
            rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
            rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
        }else{
            if(rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_WIN){
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].betAmount);
            }else if(rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_WIN){
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].betAmount);
            }else{
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
            }
        }
        rooms[roomNum].gameStatus = GameStatus.STATUS_COMPLETE;
    }

    //게임결과 업데이트
    function compareHands(uint roomNum )private {
        uint8 originator = uint8(rooms[roomNum].originator.hand);
        uint8 taker = uint8(rooms[roomNum].taker.hand);

        rooms[roomNum].gameStatus = GameStatus.STATUS_STARTED;

        if(taker == originator){ //비긴 경우 
            //draw
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_TIE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_TIE;
        }
        else if ((taker + 1) % 3 == originator){ //방장이 이긴 경우 
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_WIN;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_LOSE;
        }
        else if ((originator + 1) %3 == taker){ //참가자가 이긴 경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_LOSE; 
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_WIN;
        }
        else{ // 그 외 상황은 게임 상태를 에러로 업데이트 
            rooms[roomNum].gameStatus = GameStatus.STATUS_ERROR;
        }
    }
}