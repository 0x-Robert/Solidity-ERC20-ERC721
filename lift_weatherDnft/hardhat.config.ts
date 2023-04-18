import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    mumbai: {
      chainId: 80001,
      from: process.env.DEFAULT_ADDRESS,
      url: "https://rpc-mumbai.maticvigil.com",
    },
  },
  paths: {
    sources: "./src",
  },
};

export default config;
