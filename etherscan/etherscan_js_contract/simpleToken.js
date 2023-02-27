const express =require('express');
const app = express();
const port = 8999;
const Contract = require('web3-eth-contract');

async function deploySimpleToken() {
    try {
        const abi = [
            {
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
            }
        ]
        const byteCode = "608060405234801561001057600080fd5b5061017c806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063942ae0a714610030575b600080fd5b61003861004e565b60405161004591906100c4565b60405180910390f35b60606040518060400160405280600c81526020017f48656c6c6f20576f726c64210000000000000000000000000000000000000000815250905090565b6000610096826100e6565b6100a081856100f1565b93506100b0818560208601610102565b6100b981610135565b840191505092915050565b600060208201905081810360008301526100de818461008b565b905092915050565b600081519050919050565b600082825260208201905092915050565b60005b83811015610120578082015181840152602081019050610105565b8381111561012f576000848401525b50505050565b6000601f19601f830116905091905056fea2646970667358221220596ec5a7ee37d3aa98d5aa51468fc486cfa5addb8149040424c42f7d267c60ce64736f6c63430008070033"
        Contract.setProvider('http://127.0.0.1:7545');
        const contract = new Contract(abi);
        const receipt = await contract.deploy({data:"0x" + byteCode, arguments: ["ErcSimpleToken", "EST"]}).send({from:"0x09B225298c2C9F8428c198068588d10B677d1A08", gas: 2000000, gasPrice:'1000000000000'});
        console.log("receipt", receipt);
        return receipt;
    } catch(e) {
        console.log(e);
        return e;
    }
}

app.get('/deploy', (req, res) => {
    deploySimpleToken().then((result) => {
        res.send(result);
    })
})

app.listen(port, () => {
	console.log('Listening...');
});