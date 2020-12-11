const game = artifacts.require("./GachaGame");

const gameSettings = {
  name: "James"
}

module.exports = function(deployer) {
  deployer.deploy(game, gameSettings.name);
};
