const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const game = artifacts.require("./GachaGame");

const gameSettings = {
  name: "James"
}

module.exports = async function(deployer) {
  const instance = await deployProxy(game, { deployer, unsafeAllowCustomTypes: true });
  console.log('Deployed', instance.address);
};
