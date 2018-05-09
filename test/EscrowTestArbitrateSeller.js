// Workether tests : Run against workether token to check full backwards compatibility.
const assertJump = require('./helpers/assertJump');
var TokenWethr = artifacts.require("../contracts/implementation/wethr_token.sol");
var ContractEscrow = artifacts.require("../contracts/implementation/Escrow.sol");



contract('Escrow-Arbitrate-Seller', async (accounts) => {
  var owner = accounts[0];
  var buyer = accounts[1];
  var seller = accounts[2];
  var wethrAddress;
  var escrowAddress;
  var wethrAmount = 50000000;
  var wethrInstance;
  var escrowInstance;
  var escrowAmount = 5000;
  


  it("should create WETHR and ESCROW with address and balance in owner account", async () => {
    wethrInstance = await TokenWethr.deployed();
    wethrAddress = wethrInstance.address;
    escrowInstance = await ContractEscrow.new(buyer, seller, wethrAddress,owner);
    escrowAddress = escrowInstance.address;
    let balance = await wethrInstance.balanceOf(owner);
    assert.equal(balance.valueOf(), wethrAmount);
  })

  it("should add wethr to buyer account", async () => {
    await wethrInstance.transfer(buyer,escrowAmount);
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), escrowAmount);
  })

  it("should create escrow and deduct buyer balance", async () => {
    await wethrInstance.transfer(escrowAddress, escrowAmount, {from: buyer});
    await escrowInstance.deposit({value: escrowAmount,from: buyer});
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), 0);
  })

  it("should show right escrow balance", async () => {
    let balance = await wethrInstance.balanceOf(escrowAddress);
    assert.equal(balance.valueOf(), escrowAmount);
  })


  it("When mediator arbitrates in favour of Buyer it should show funds transferred to seller", async () => {
    await escrowInstance.arbitrateInFavorOfSeller({from: owner});
    let balance = await wethrInstance.balanceOf(seller);
    assert.equal(balance.valueOf(), escrowAmount);
  })


});
