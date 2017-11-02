var ContractProvider = artifacts.require("./ContractProvider.sol");
var Validator = artifacts.require("./Validator.sol");
var SaleManager = artifacts.require("./SaleManager");

module.exports = function(deployer, network, accounts) {
    ContractProvider.deployed().then(function(CP){
        CP.addContract("validator", Validator.address);
        CP.addContract("salemanager", SaleManager.address);
    });
};
