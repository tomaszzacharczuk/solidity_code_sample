pragma solidity 0.4.17;


import './interfaces/IContractProvider.sol';
import './ContractProviderEnabled.sol';


contract Validator is ContractProviderEnabled {
    // 255 - God mode
    // 128 - Admin
    // 64...
    // user address => granted perm value
    mapping(address => uint8) public userPerms;

    // contract address => method name => required perm value
    mapping(address => mapping(bytes32 => uint8)) public contractPerms;

    function setContractProvider(address _cp) public returns(bool) {
        if (!super.setContractProvider(_cp)) {
            return false;
        }

        address owner = IContractProvider(cp).owner();
        userPerms[owner] = 255;
        contractPerms[this]["setUserPerm"] = 255;
        contractPerms[this]["setMethodPerm"] = 255;
        return true;
    }

    function setUserPerm(address user, uint8 perm) public returns(bool) {
        // validate expects external call so have to use "this"
        if (this.validate(msg.sender, "setUserPerm")) {
            userPerms[user] = perm;
            return true;
        } else {
            return false;
        }
    }

    function setMethodPerm(address contractAddr, bytes32 methodName, uint8 perm) 
        public returns(bool) 
    {
        // validate expects external call so have to use "this"
        if (this.validate(msg.sender, "setMethodPerm")) {
            contractPerms[contractAddr][methodName] = perm;
            return true;
        } else {
            return false;
        }
    }

    function validate(address caller, bytes32 methodName) public view returns(bool) {
        address callingContract = msg.sender;
        uint8 permRequired = contractPerms[callingContract][methodName];
        uint8 permGranted = userPerms[caller];
        return permGranted >= permRequired;
    }
}