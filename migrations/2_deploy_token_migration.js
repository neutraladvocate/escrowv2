var Migrations = artifacts.require("./Migrations.sol");
var token = artifacts.require("../contracts/implementation/wethr_token.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};

module.exports = function(deployer) {
  deployer.deploy(token);
};