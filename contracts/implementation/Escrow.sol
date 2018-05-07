pragma solidity ^0.4.8;
import "../implementation/Standard223Receiver.sol";

contract IToken {
  function balanceOf(address _address) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
}

contract Escrow is Standard223Receiver {
    uint balance;
    address public buyer;
    address public seller;
    address private escrow;
    uint private start;
    bool buyerOk;
    bool sellerOk;
    address public wethr;
    address public arbitrator;
    



function Escrow(address buyer_address, address seller_address, address token_address, address arbitrator_address) payable public {
        // this is the constructor function that runs ONCE upon initialization
        buyer = buyer_address;
        seller = seller_address;
        escrow = msg.sender;
        start = now; //now is an alias for block.timestamp, not really "now"
        wethr = token_address;
        arbitrator = arbitrator_address;

    }
    
    event Status(uint statusCode);
    event LogTokenPayable(uint i, address token, address sender, uint value);
    event EscrowEvent(uint code, string etype, address sender, uint value);

    function accept() public {
        if (msg.sender == buyer){
            buyerOk = true;
        } else if (msg.sender == seller){
            sellerOk = true;
        }
        if (buyerOk && sellerOk){
            payBalance();
        } else if (buyerOk && !sellerOk && now > start + 30 days) {
            // Freeze 30 days before release to buyer. The customer has to remember to call this method after freeze period.
            selfdestruct(buyer);
        }
        EscrowEvent(100, "accept", msg.sender,0);

    }
    
    function payBalance() private {
        // we are sending ourselves (contract creator) a fee
       // escrow.transfer(this.balance / 100);
        // send seller the balance, send only works on ether hence changing
        IToken token = IToken(wethr);
        // Check the token contract if we have been issued tokens already
//          token.approve(this, this.balance);
//          if (token.transferFrom(this, seller, this.balance)) {
        Status(this.balance); //fail to transfer from escrow to seller

        if (token.transfer(seller, this.balance)) {
            balance = 0;
        } else {
            Status(102); //fail to transfer from escrow to seller
            throw;
        }
    EscrowEvent(200, "payBalance", msg.sender,this.balance);
    }
    
    function deposit() public payable {
        if (msg.sender == buyer) {
            balance += msg.value;
        }
    EscrowEvent(300, "deposit", msg.sender,msg.value);
    }
    
    function cancel() public {
        if (msg.sender == buyer){
            buyerOk = false;
        } else if (msg.sender == seller){
            sellerOk = false;
        }
        // if both buyer and seller would like to cancel, money is returned to buyer 
        if (!buyerOk && !sellerOk){
            selfdestruct(buyer);
        }
        EscrowEvent(400, "cancel", msg.sender,0);

    }

    function arbitrateInFavorOfBuyer() public {
        if (msg.sender == arbitrator){
            // if arbitrator wants then money is returned to buyer 
            selfdestruct(buyer);
        }else
        {
            Status(107); //unauthorised call for arbitrate 
        }

        EscrowEvent(500, "arbitrateInFavorOfBuyer", msg.sender,msg.value);
 
    }
    
    function arbitrateInFavorOfSeller() public {
        if (msg.sender == arbitrator){
            // if arbitrator wants then money is returned to seller 
            payBalance();
        }else
        {
            Status(107); //unauthorised call for arbitrate 
        }
        EscrowEvent(600, "arbitrateInFavorOfSeller", msg.sender,msg.value);
        
    }
    
    function kill() public constant {
        if (msg.sender == escrow) {
            selfdestruct(buyer);
        }
    }

  function foo(/*uint i*/) tokenPayable {
    LogTokenPayable(1, tkn.addr, tkn.sender, tkn.value);
  }

  function () tokenPayable {
    LogTokenPayable(0, tkn.addr, tkn.sender, tkn.value);
  }

  function supportsToken(address token) returns (bool) {
    return true;
  }


}