pragma solidity 0.4.17;


contract IValidator {
    function validate(address sender, bytes32 methodName) public returns(bool);
}