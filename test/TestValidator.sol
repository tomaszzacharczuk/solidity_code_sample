pragma solidity 0.4.17;

import 'truffle/Assert.sol';
import "truffle/DeployedAddresses.sol";
import '../contracts/Validator.sol';
import '../contracts/ContractProvider.sol';

contract TestValidator {
    Validator public V = Validator(DeployedAddresses.Validator());
    ContractProvider public CP = ContractProvider(DeployedAddresses.ContractProvider());
    address addr1 = 0xCf22dbFa2c54419FAEd2100e3Ea87b5113AaBF75;
    address addr2 = 0xAeCfD69D9B1A34e22685b4d9388eF2FE69167323;

    function testOwnerSet() public {
        address owner = CP.owner();
        uint perm = V.userPerms(owner);
        Assert.equal(perm, 255, "Owner permission should be 255");
    }

    function testMethodsPermissions() public {
        uint perm1 = V.contractPerms(V, "setUserPerm");
        Assert.equal(perm1, 255, "should require 255 permission");

        uint perm2 = V.contractPerms(V, "setMethodPerm");
        Assert.equal(perm2, 255, "should require 255 permission");
    }

    function testSetUserPerm() public {
        ContractProvider newCP = new ContractProvider();
        Validator newV = new Validator();
        bool contractAdded = newCP.addContract("validator", newV);
        Assert.equal(contractAdded, true, "should add validator to contracts");
        
        address validatorAddr = newCP.contracts("validator");
        Assert.equal(validatorAddr, address(newV), "should match Validator address");

        uint ownerPerm = newV.userPerms(this);
        Assert.equal(ownerPerm, 255, "should set test contract perm to 255");

        bool result = newV.setUserPerm(addr1, 16);
        Assert.equal(result, true, "should set perm and return true");

        uint perm = newV.userPerms(addr1);
        Assert.equal(perm, 16, "should equal to 16");
    }

    function testSetUserPermFail() public {
        bool result = V.setUserPerm(addr2, 8);
        Assert.equal(result, false, "should not set perm and return true");
        
        uint perm = V.userPerms(addr2);
        Assert.equal(perm, 0, "should equal to 0");
    }    

    function testSetMethodPerm() public {
        ContractProvider newCP = new ContractProvider();
        Validator newV = new Validator();
        bool contractAdded = newCP.addContract("validator", newV);
        Assert.equal(contractAdded, true, "should add validator to contracts");

        bool result = newV.setMethodPerm(addr1, "testMethod1", 32);
        Assert.equal(result, true, "should set method perm and return true");

        uint methodPerm = newV.contractPerms(addr1, "testMethod1");
        Assert.equal(methodPerm, 32, "should get 32 as method permission");
    }

    function testSetMethodPermFail() public {
        bool result = V.setMethodPerm(addr2, "testMethod2", 64);
        Assert.equal(result, false, "should not set method perm and return false");

        uint methodPerm = V.contractPerms(addr2, "testMethod2");
        Assert.equal(methodPerm, 0, "should get 0 as method permission");   
    }
}
