var MyNFTs = artifacts.require("MyNFTs.sol"); // MyNFT.sol 파일 추가

module.exports = function (deployer) {
  deployer.deploy(MyNFTs);
};
