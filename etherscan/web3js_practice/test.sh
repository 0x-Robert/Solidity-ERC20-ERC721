#!/bin/bash

curl https://goerli.infura.io/v3/8f0f6f1d3eba4554818d7e69ef83053f \
 -X POST \
 -H "Content-type: application/json" \
 -d '{"jsonrpc": "2.0", "method": "eth_getBalance", "params": ["0x7684992428a8E5600C0510c48ba871311067d74c", "latest"], "id":1}'
