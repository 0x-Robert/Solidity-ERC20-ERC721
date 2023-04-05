#!/bin/bash

curl -X 'GET'   'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD'   -H 'accept: application/json' | jq .


