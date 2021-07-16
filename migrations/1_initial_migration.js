const Migrations = artifacts.require("Migrations");
const UniswapV2Factory = artifacts.require("UniswapV2Factory");
const NFTWarrior = artifacts.require("NFTWarrior");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(UniswapV2Factory, "0x6148Ce093DCbd629cFbC4203C18210567d186C66");
  deployer.deploy(NFTWarrior, "Defi Warrior", "FIWA");
};
