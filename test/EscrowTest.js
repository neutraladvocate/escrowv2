// Workether tests : Run against workether token to check full backwards compatibility.
const assertJump = require('./helpers/assertJump');
var TokenEscrow = artifacts.require("../contracts/implementation/TokenEscrow.sol");
var TokenWethr = artifacts.require("../contracts/implementation/wethr_token.sol");

contract('TokenWethr', function(accounts) {
  var owner = accounts[0];
  var buyer = accounts[1];
  var seller = accounts[2];
  var token;
  var escrow;



  it('init', function() {
    return TokenWethr.new({from:owner}).then(function(wethrContract) {
      if(wethrContract.address){
        token = wethrContract;
      } else {
        throw new Error("no contract address");
      }
      return true;
    })
  })

  it('test-escrow-creation', function() {
    return TokenEscrow.new()
      .then(function(escrowContract){
        if (escrowContract.address) {
          escrow = escrowContract;
        } else {
          throw new Error("no escrow address");
        }
        console.log("Escrow address is: " + escrowContract.address);
        console.log("owner address is: " + escrowContract.owner);
        console.log("account1 address is: " + accounts[0].address);

        return true
      })
      .then(function(value){
        return escrow.create(token.address, 200, 3, buyer, seller);
        assert.equal(escrow.getEscrowIdExt(), 1);
      })
})



  it("should create an escrow", function() {
    console.log("Pending issue");
   
  })



});
