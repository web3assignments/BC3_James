const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const game = artifacts.require("./GachaGame");
const gameV2 = artifacts.require("./GachaGameV2");

module.exports = async function(deployer) {
    const gameOld = await game.deployed();
    const gameNew = await upgradeProxy(gameOld.address, gameV2, {deployer, unsafeAllowCustomTypes: true});
    console.log('Old', gameOld.address);
    console.log('New', gameNew.address);
}
