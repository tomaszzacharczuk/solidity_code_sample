pragma solidity 0.4.17;


import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './interfaces/IContractProviderEnabled.sol';


contract ContractProvider is Ownable {
    mapping(bytes32 => address) public contracts;

    function addContract(bytes32 name, address addr) public onlyOwner returns(bool) {
        require(addr != 0x0);
        require(name.length > 0);

        if (IContractProviderEnabled(addr).setContractProvider(this)) {
            contracts[name] = addr;
            return true;
        } else {
            return false;
        }
    }

    function removeContract(bytes32 name) public onlyOwner returns(bool) {
        require(name.length > 0);

        if(contracts[name] == 0x0) {
            return false;
        } else {
            delete contracts[name];
            return true;
        }
    }
}