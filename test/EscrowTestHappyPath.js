// Workether tests : Run against workether token to check full backwards compatibility.
const assertJump = require('./helpers/assertJump');
var TokenWethr = artifacts.require("../contracts/implementation/wethr_token.sol");
var ContractEscrow = artifacts.require("../contracts/implementation/Escrow.sol");



contract('Escrow-HAPPYPATH', async (accounts) => {
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
    escrowInstance = await ContractEscrow.new(buyer, seller, wethrAddress,owner,escrowAmount);
    escrowAddress = escrowInstance.address;
    let balance = await wethrInstance.balanceOf(owner);
    assert.equal(balance.valueOf(), wethrAmount);

    balance = await wethrInstance.balanceOf(owner);
    console.log("OwnerBalance: " + balance);
    balance = await wethrInstance.balanceOf(buyer);
    console.log("BuyerBalance" + balance);
    balance = await wethrInstance.balanceOf(seller);
    console.log("SellerBalance" + balance);
    balance = await wethrInstance.balanceOf(escrowAddress);
    console.log("EscrowBalance" + balance);
    let state = await escrowInstance.getState();
    console.log("EscrowStateOnCreate" + state);

  
  })

  it("should add wethr to buyer account", async () => {
    await wethrInstance.transfer(buyer,escrowAmount);
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), escrowAmount);


  })


  it("should show correct seller zero balance", async () => {
    let balance = await wethrInstance.balanceOf(seller);
    assert.equal(balance.valueOf(), 0);
  })

  it("should create escrow and deduct buyer balance", async () => {
    let state = await escrowInstance.getState();
    console.log("EscrowStateBeforeDeposit" + state);

    await wethrInstance.transfer(escrowAddress, escrowAmount, {from: buyer});
    await escrowInstance.depositIntoEscrow("dochash",{value: escrowAmount,from: buyer});
    let balance = await wethrInstance.balanceOf(buyer);
    assert.equal(balance.valueOf(), 0);
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
    let state = await escrowInstance.getState();
    console.log("EscrowStateAfterDeposit" + state);

  })


  it("The happy path should show funds transferred to seller after both acceptance", async () => {
    await escrowInstance.accept("dochash",{from: seller});
    await escrowInstance.accept("dochash",{from: buyer});
    let balance = await wethrInstance.balanceOf(seller);
    assert.equal(balance.valueOf(), escrowAmount);

    balance = await wethrInstance.balanceOf(owner);
    console.log("OwnerBalance" + balance);
    balance = await wethrInstance.balanceOf(buyer);
    console.log("BuyerBalance" + balance);
    balance = await wethrInstance.balanceOf(seller);
    console.log("SellerBalance" + balance);
    balance = await wethrInstance.balanceOf(escrowAddress);
    console.log("EscrowBalanceCHECK" + balance);
    let state = await escrowInstance.getState();
    console.log("EscrowStateAfterAccept" + state);
    balance = await escrowInstance.getBalance();
    console.log("EscrowStateBalance" + balance);

  })


});
