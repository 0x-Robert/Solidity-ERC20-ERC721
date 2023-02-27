const express =require('express');
const app = express();
const port = 9000;
const Contract = require('web3-eth-contract');




const Web3 = require("web3");
const rpcURL = "https://goerli.infura.io/v3/8f0f6f1d3eba4554818d7e69ef83053f";

const web3 = new Web3(rpcURL);
const txId = "0xb2fdb6338c9337cc8b60f0f1c9b8538347b7296ebc265b1bcd20e8452f446617"
const account = "0x7684992428a8E5600C0510c48ba871311067d74c";
const blockNum = "8536151"



async function helloWorld() {
    try {
        const abi = [{
                "inputs": [],
                "name": "renderHelloWorld",
                "outputs": [
                    {
                        "internalType": "string",
                        "name": "greeting",
                        "type": "string"
                    }
                ],
                "stateMutability": "pure",
                "type": "function"
            }];
        
        const address = '0x1426A5079Cb2864D76fC1596fDC2FDFDCC646a0f'; //가나슈1 어드레스
        console.log("address",address)
        Contract.setProvider('http://127.0.0.1:7545'); //가나슈 주소 
        console.log("1","contract")
        const contract = new Contract(abi, address);
        console.log("2","contract")
        const result = await contract.methods.renderHelloWorld().call();
        //const result2 = await contract.methods.renderHelloWorld().call();
        console.log("result", result);
        return result;
    } catch(e) {
        console.log(e);
        return e;
    }
}

app.get('/helloworld', (req, res) => {
    helloWorld().then((result) => {
        res.send(result);
    })
})

app.listen(port, () => {
	console.log('Listening...');
});