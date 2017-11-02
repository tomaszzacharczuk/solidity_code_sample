pragma solidity 0.4.17;


contract ContractProviderEnabled {
    address cp;

    function setContractProvider(address _cp) public returns(bool) {
        require(_cp != 0x0);
        if(cp == 0x0 || msg.sender == cp) {
            cp = _cp;
            return true;
        } else {
            return false;
        }
    }
}