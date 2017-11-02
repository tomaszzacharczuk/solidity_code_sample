pragma solidity 0.4.17;


import './interfaces/IContractProvider.sol';
import './interfaces/IValidator.sol';
import './ContractProviderEnabled.sol';


contract Validee is ContractProviderEnabled {

    event UnathorisedCall(
        address indexed caller,
        address indexed calledContract,
        bytes32 methodName,
        uint16 indexed responseCode
        );
    
    modifier validate(bytes32 methodName) {
        address v = IContractProvider(cp).contracts("validator");
        if(v != 0x0) {
            bool result = IValidator(v).validate(msg.sender, methodName);
            if (result) {
                _;
            } else {
                UnathorisedCall(msg.sender, this, methodName, 401);
                revert();
            }
        } else {
            _;
        }
    }
}