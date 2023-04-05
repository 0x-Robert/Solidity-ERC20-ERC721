#!/bin/bash


PASSWORD=asdf1234zxcv5678


docker run --name cl-postgres -e POSTGRES_PASSWORD=asdf1234zxcv5678 -p 5432:5432 -d postgres


#asdf1234zxcv5678
# cd ~/.chainlink-sepolia && docker run --platform linux/x86_64/v8 --name chainlink  -v ~/.chainlink-sepolia:/chainlink -it --env-file=.env -p 6688:6688 --add-host=192.168.1.100:host-gateway smartcontract/chainlink:1.13.0-root


#cd ~/.chainlink-sepolia && docker run --platform linux/x86_64/v8 --name chainlink  -v ~/.chainlink-sepolia:/chainlink -it --env-file=.env -p 6688:6688 --add-host=192.168.219.101:host-gateway smartcontract/chainlink:1.13.0-root

# cd ~/.chainlink-sepolia && docker run --name chainlink -p 6688:6688 -v ~/.chainlink-sepolia:/chainlink -it --env-file=.env smartcontract/chainlink local n

#docker run --platform linux/x86_64/v8 --name chainlink -v ~/.chainlink-sepolia:/chainlink -it --env-file=.env -p 6688:6688 --add-host=host.docker.internal:host-gateway  smartcontract/chainlink:1.13.0

# docker run --platform linux/x86_64/v8 --name chainlink -v ~/.chainlink-sepolia:/chainlink -it --env-file=.env -p 6688:6688 --add-host=host.docker.internal:172.17.0.1 smartcontract/chainlink:1.13.0


docker run --platform linux/x86_64/v8 --name chainlink -v .chainlink-sepolia:/chainlink -it --env-file=.env -p 6688:6688 --add-host=host.docker.internal:host-gateway smartcontract/chainlink:1.13.0 local n
