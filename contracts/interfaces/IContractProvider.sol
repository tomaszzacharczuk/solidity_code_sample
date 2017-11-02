pragma solidity 0.4.17;


interface IContractProvider {
    function owner() public returns(address);
    function contracts(bytes32 name) public returns(address);
}