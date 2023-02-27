//getBalance.js




const Web3 = require("web3");
const rpcURL = "https://goerli.infura.io/v3/8f0f6f1d3eba4554818d7e69ef83053f";

const web3 = new Web3(rpcURL);
const txId = "0xb2fdb6338c9337cc8b60f0f1c9b8538347b7296ebc265b1bcd20e8452f446617"
const account = "0x7684992428a8E5600C0510c48ba871311067d74c";
const blockNum = "8536151"

web3.eth.getBalance(account)
  .then((bal) => {
  //  console.log(`지갑 ${account}의 잔액은... ${bal}입니다.`);
    return web3.utils.fromWei(bal, "ether"); //web3.utils.fromWei를 이용해 ether 단위로 변경

  })
  .then((eth)=>{
  //  console.log(`이더 단위로는 ${eth} ETH 입니다.`)
  })

web3.eth.getTransaction(txId)
  .then((obj)=>{
   // console.log("getTransaction", obj);
  })


web3.eth.getTransactionReceipt(txId)
  .then((obj)=>{
   // console.log("getTransactionReceipt", obj);
  })

web3.eth.getBlock(blockNum).then((obj)=>{
 // console.log("blockNumber", obj)
})

async function getBlock() {
  try {
      const getBlock = await getWeb3().eth.getBlock("latest");
      console.log(getBlock);
      return getBlock;
  } catch (e) {
      console.log(e);
      return e;
  }
}

app.get('/getblock', (req, res) => {
  getBlock().then((getBlock) => {
      res.send(getBlock);
  })
})

function getTransactionsByAccount(start, end, account){
  // 계정 주소값과 블록 범위(ex. 11,300,000번째 블록부터 11,400,000번째 블록까지, 제네시스 블록부터 가장 최근 블록까지)를 입력하면 해당 블록 범위에 있는 블록에 기록된 트랜잭션 중 해당 계정이 참여한 트랜잭션만 추출합니다.
// 인자로 주소값 account와 블록 숫자로 이루어진 블록 범위 값 startBlock, endBlock 을 인자로 가집니다.
// 해당 블록 범위 내에 송신 또는 수신자로 참여한 트랜잭션들로 구성된 배열을 반환합니다.
  for (let i=start; i < end; i++){
  web3.eth.getBlock(i).then((obj)=>{
   // console.log(obj.transactions.length)
    for (let j = 0; j < obj.transactions.length; j++){
     // console.log(obj.transactions[j])
      if(txId === obj.transactions[j]){
        console.log("j",j)
        console.log("transaction", obj.transactions[j])
        web3.eth.getTransaction(obj.transactions[j])
        .then((obj)=>{
         console.log("getTransaction", obj);
        })
      }
         
    }
  })
}

}

async function getTransactionsByAccount2(account, startBlock, endBlock){

  const latestBlockNumber = await web3.eth.getBlockNumber();

  const validatedStartBlock = 8536151 || 0; 
  const validatedEndBlock = endBlock || latestBlockNumber


  const matchingTransactions=[];

  for(let blockNumber=validatedStartBlock; blockNumber<= validatedEndBlock; blockNumber++){

    const block = await web3.eth.getBlock(blockNumber, true);

    for (let tx of block.transactions){
      if(tx.from === account || tx.to === account){
        matchingTransactions.push(tx);
      } 
    }
  }
  return matchingTransactions; 
}


function main(){
  //const blockNum = "8536151"
  start="8536151"
  end="8536152"

  start2="0"
  end2="8536152"
  getTransactionsByAccount(start,end,account)
 //getTransactionsByAccount2(account, start2, end2 )
}

main()