const Web3 = require('web3');

// Ethereum JSON-RPC 클라이언트 생성
const web3 = new Web3('https://goerli.infura.io/v3/your-project-id');

// 이더리움 블록 정보 가져오기
web3.eth.getBlock('latest', (error, result) => {
  if (!error) {
    console.log(result);
  } else {
    console.error(error);
  }
});

// 이더리움 계정 정보 가져오기
web3.eth.getBalance('0x1234567890123456789012345678901234567890', (error, result) => {
  if (!error) {
    console.log(result);
  } else {
    console.error(error);
  }
});

// 이더리움 스마트 계약 ABI 가져오기
const contractABI = [
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "name",
        "type": "string"
      },
      {
        "internalType": "uint256",
        "name": "age",
        "type": "uint256"
      }
    ],
    "name": "createPerson",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

// 이더리움 스마트 계약 주소 설정
const contractAddress = '0x1234567890123456789012345678901234567890';

// 이더리움 스마트 계약 인스턴스 생성
const contractInstance = new web3.eth.Contract(contractABI, contractAddress);

// 이더리움 스마트 계약 함수 호출
contractInstance.methods.createPerson('Alice', 30).send({ from: '0x1234567890123456789012345678901234567890' }, (error, transactionHash) => {
  if (!error) {
    console.log(transactionHash);
  } else {
    console.error(error);
  }
});