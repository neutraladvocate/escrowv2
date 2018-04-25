// Workether tests : Run against workether token to check full backwards compatibility.
const assertJump = require('./helpers/assertJump');
var TokenWethr = artifacts.require("../contracts/implementation/wethr_token.sol");
var ContractEscrow = artifacts.require("../contracts/implementation/TokenEscrow.sol");

contract('WETHRESCROW', async (accounts) => {
  var owner = accounts[0];
  var buyer = accounts[1];
  var seller = accounts[2];
  var wethrAddress;
  var escrowAddress;
  var amount = 5000000;
  var wethrInstance;
  var escrowInstance;


  it("should create WETHR and ESCROW with address and balance in owner account", async () => {
    wethrInstance = await TokenWethr.deployed();
    wethrAddress = await wethrInstance.address;
    escrowInstance = await ContractEscrow.deployed();
    escrowAddress = await escrowInstance.address;
    let balance = await wethrInstance.balanceOf(owner);
    assert.equal(balance.valueOf(), 50000000);
  })

  it("should add wethr to buyer account", async () => {
    await wethrInstance.transfer(buyer,10000000)
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), 10000000);
  })

  it("should create escrow and deduct buyer balance", async () => {
    await escrowInstance.create(wethrAddress, amount, 3, seller, buyer);
    escrowInstance.receive(amount,{from: buyer});
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), 5000000);
  })

  it("should not change buyer balance", async () => {
    escrowInstance.receive(amount,{from: seller});
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), 5000000);
  })


});
