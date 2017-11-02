var ContractProvider = artifacts.require("./ContractProvider.sol");
var Validator = artifacts.require("./Validator.sol");
var SaleManager = artifacts.require("./SaleManager");
var DoublyLinkedListOfParticipants = artifacts.require("./DoublyLinkedListOfParticipants");

module.exports = function(deployer) {
    deployer.deploy(ContractProvider);
    deployer.deploy(Validator);
    deployer.deploy(DoublyLinkedListOfParticipants);
    deployer.link(DoublyLinkedListOfParticipants, SaleManager);
    deployer.deploy(SaleManager);
};
