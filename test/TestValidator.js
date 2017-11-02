var Validator = artifacts.require("./Validator.sol");
var ContractProvider = artifacts.require("./ContractProvider.sol");

contract('Validator', function(accounts) {
    let V;
    let CP;

    beforeEach(async function(){
        V = await Validator.deployed();
        CP = await ContractProvider.deployed();
    });

    describe("Setup", function(){
        it('should have onwer setup', async function(){
            let owner = await CP.owner();
            assert.equal(owner, accounts[0], "Owner is not right.");
        });

        it("should set CP owner permission to 255", async function(){
            let owner = await CP.owner();
            let perm = await V.userPerms(owner)
            assert.equal(perm, 255, "owner perm is not setup correctly");
        });
    });
});
