const express =require('express');
const app = express();
const port = 8080;
const Contract = require('web3-eth-contract');

async function helloWorld() {
    try {
        const abi = [{  // ABI를 복사합니다
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
        const address = '0x000';  // 자신의 컨트랙트 주소를 할당합니다
        Contract.setProvider('https://goerli.infura.io/v3/8f0f6f1d3eba4554818d7e69ef83053f');
        const contract = new Contract(abi, address);
        const result = await contract.methods.renderHelloWorld().call();
        console.log(result);
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