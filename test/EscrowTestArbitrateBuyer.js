// Workether tests : Run against workether token to check full backwards compatibility.
const assertJump = require('./helpers/assertJump');
var TokenWethr = artifacts.require("../contracts/implementation/wethr_token.sol");
var ContractEscrow = artifacts.require("../contracts/implementation/Escrow.sol");



contract('Escrow-Arbitrate-Buyer', async (accounts) => {
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

    balance = await wethrInstance.balanceOf(owner);
    console.log("OwnerBalance" + balance);
    balance = await wethrInstance.balanceOf(buyer);
    console.log("BuyerBalance" + balance);
    balance = await wethrInstance.balanceOf(seller);
    console.log("SellerBalance" + balance);
    balance = await wethrInstance.balanceOf(escrowAddress);
    console.log("EscrowBalance" + balance);

  })

  it("should add wethr to buyer account", async () => {
    await wethrInstance.transfer(buyer,escrowAmount);
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), escrowAmount);
  })

  it("should create escrow and deduct buyer balance", async () => {
    await wethrInstance.transfer(escrowAddress, escrowAmount, {from: buyer});
    await escrowInstance.deposit("dochash", {value: escrowAmount,from: buyer});
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), 0);

    console.log("PostDeposit");
    balance = await wethrInstance.balanceOf(owner);
    console.log("OwnerBalance" + balance);
    balance = await wethrInstance.balanceOf(buyer);
    console.log("BuyerBalance" + balance);
    balance = await wethrInstance.balanceOf(seller);
    console.log("SellerBalance" + balance);
    balance = await wethrInstance.balanceOf(escrowAddress);
    console.log("EscrowBalance" + balance);
    balance = await escrowInstance.getBalance();
    console.log("escrowInstance Balance" + balance);
    let state = await escrowInstance.getState();
    console.log("escrowInstance state" + state);
  })

  it("should show right escrow balance", async () => {
    let balance = await wethrInstance.balanceOf(escrowAddress);
    assert.equal(balance.valueOf(), escrowAmount);

    balance = await wethrInstance.balanceOf(owner);
    console.log("OwnerBalance" + balance);
    balance = await wethrInstance.balanceOf(buyer);
    console.log("BuyerBalance" + balance);
    balance = await wethrInstance.balanceOf(seller);
    console.log("SellerBalance" + balance);
    balance = await wethrInstance.balanceOf(escrowAddress);
    console.log("EscrowBalance" + balance);
    balance = await escrowInstance.getBalance();
    console.log("escrowInstance Balance" + balance);
  })


  it("When mediator arbitrates in favour of Buyer it should show funds transferred to buyer", async () => {
    await escrowInstance.arbitrateInFavorOf(buyer,"dochash",{from: owner});
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), escrowAmount);

    balance = await wethrInstance.balanceOf(owner);
    console.log("OwnerBalance" + balance);
    balance = await wethrInstance.balanceOf(buyer);
    console.log("BuyerBalance" + balance);
    balance = await wethrInstance.balanceOf(seller);
    console.log("SellerBalance" + balance);
    balance = await wethrInstance.balanceOf(escrowAddress);
    console.log("EscrowBalance" + balance);

  })


});
