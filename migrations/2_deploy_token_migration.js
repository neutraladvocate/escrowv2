var Migrations = artifacts.require("./Migrations.sol");
var token = artifacts.require("../contracts/implementation/wethr_token.sol");
var escrow = artifacts.require("../contracts/implementation/TokenEscrow.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};

module.exports = function(deployer) {
  deployer.deploy(token);
  deployer.deploy(escrow);
};