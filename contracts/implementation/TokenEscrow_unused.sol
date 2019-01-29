pragma solidity ^0.4.8;

//
// The workether escrow contract
//
// To create an escrow request, follow these steps:
// 1. Call the create() method for setup
// 2. Transfer the tokens to the escrow contract
//
// The recipient can make a simple Ether transfer to get the tokens released to his address.
//
// The buyer pays all the fees (including gas).
//

contract IToken {
  function balanceOf(address _address) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
}

contract TokenEscrow {
  address owner;
  modifier owneronly { if (msg.sender == owner) _; }
  function setOwner(address _owner) owneronly {
    owner = _owner;
  }

  int escrowId=1;
  uint balanceToken;

  function TokenEscrow() payable {
    owner = msg.sender;
  }

  struct Escrow {
    address token;           // address of the token contract
    uint tokenAmount;        // number of tokens requested
    bool tokenReceived;      // are tokens received?
    uint price;              // price to be paid by buyer
    address seller;          // seller's address
    address recipient;       // address to receive the tokens
  }

  mapping (address => Escrow) public escrows;


    // Status of transaction. Used for error handling.
    event Status(uint statusCode);


  function create(address token, uint tokenAmount, uint price, address seller, address buyer, address recipient) {
    escrows[buyer] = Escrow(token, tokenAmount, false, price, seller, recipient);
  }

  function create(address token, uint tokenAmount, uint price, address seller, address buyer) {
     create(token, tokenAmount, price, seller, buyer, buyer);
  }

  // Incoming transfer from the buyer, following default function did'nt work hence recreated as receive
  function() payable {
      receive();
  }

// Incoming transfer from the buyer
  function receive() payable {
    Escrow escrow = escrows[msg.sender];

    // Contract not set up
    if (escrow.token == 0)
    {
      //Error("No escrows created by the called buyer");
      emit Status(101);
      revert();
    }
    IToken token = IToken(escrow.token);

    // Check the token contract if we have been issued tokens already
    if (!escrow.tokenReceived) {
      uint balance = token.balanceOf(this);
      balanceToken = balance;
       emit Status(balance);
      if (balance >= escrow.tokenAmount)
        escrow.tokenReceived = true;
      // FIXME: what to do if we've received more tokens than required?
    }

    // No tokens yet
    if (!escrow.tokenReceived)
      throw;

    // Buyer's price is below the agreed
    //if (amount < escrow.price)
      //throw;

    // Transfer tokens to buyer, this probably only works for ether, hence using EC20 transferFrom
    //https://ethereum.stackexchange.com/questions/17322/using-solidity-how-can-i-transfer-erc20-tokens-from-the-current-address-to-anot
    //token.transfer(escrow.recipient, escrow.tokenAmount);
    token.approve(msg.sender,escrow.tokenAmount);
    token.approve(escrow.recipient,escrow.tokenAmount);
    token.transferFrom(msg.sender,escrow.recipient,escrow.tokenAmount);

    // Transfer money to seller
    //escrow.seller.send(escrow.price);

    // Refund buyer if overpaid
    //msg.sender.send(escrow.price - amount);

    delete escrows[msg.sender];
  }


}
