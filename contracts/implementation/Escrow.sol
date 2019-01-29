pragma solidity ^0.4.8;
import "../implementation/Standard223Receiver.sol";

contract IToken {
  function balanceOf(address _address) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
}

contract Escrow is Standard223Receiver {
    uint requestAmount;
    address public buyer;
    address public seller;
    address private creator;
    uint private start;
    bool buyerOk;
    bool sellerOk;
    address public wethr;
    address public arbitrator;
    string reference;
    Stages public stage = Stages.Created;

    enum Stages {
        Created,
        BuyerAccepted,
        SellerAccepted,
        Settled,
        BuyerCancelled,
        SellerCancelled,
        ArbiterationRequested
    }

    uint public creationTime = now;

    //the modifier atStage ensures that the function can only be called at a certain stage.
    //If atStage is combined with timedTransitions, make sure that you mention it after the latter, so that the new stage is taken into account.
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    // If a function implements the modifier transitionAfter(), the internal method nextStage() is called at the end of the function and the contract transitions in the next stage.
    modifier transitionAfter(Stages _stage) {
        _;
        transitionNext(_stage);
    }

    //Automatic timed transitions are handled by the modifier timeTransitions, which should be used for all functions.
    modifier timedTransitions() {
        if (now >= creationTime + 30 days) {
            transitionNext(Stages.ArbiterationRequested);
        }
        _;
    }

    //the modifier transitionNext can be used to automatically go to the next stage when the function finishes.
    function transitionNext(Stages _stage) internal {
        stage = _stage;
    }


    function Escrow(address buyer_address, address seller_address, address token_address, address arbitrator_address, string ref) payable public {
        // this is the constructor function that runs ONCE upon initialization
        buyer = buyer_address;
        seller = seller_address;
        creator = msg.sender;
        creationTime = now; //now is an alias for block.timestamp, not really "now"
        wethr = token_address;
        arbitrator = arbitrator_address;
        requestAmount = 0;
        reference = ref;
        EscrowEvent(100, "created", msg.sender,0, "");

    }
    
    function getEscrowDetails() public constant returns(address, address,address ,uint,uint,uint,string) {
        IToken token = IToken(wethr);
        uint bal = token.balanceOf(address(this));
        return (buyer, seller, arbitrator, uint(stage),bal, requestAmount, reference);
    }





    event EscrowEvent(uint code, string etype, address sender, uint value, string hashContent);
    event EscrowError(uint code, string etype, address sender, uint value);
//    event LogTokenPayable(uint i, address token, address sender, uint value);

    // EVENTS in sequence by stages..last digit one in case of error
    // 100 - created -> 200 - deposit -> 600 - buyerAccepted -> 700 - sellerAccepted -> 800 - settled
    // 100 - created -> 200 - deposit -> 400 - reduce -> 500 - increase ..continue 
    // 100 - created -> 200 - deposit -> both dont accept -> 300 - arbitrate -> 800 - settled
    //350 - cancel


    function accept(string hashContent) public  timedTransitions {
        if ( (stage == Stages.Created) || (stage == Stages.BuyerAccepted) || (stage == Stages.SellerAccepted) ){
            if (msg.sender == buyer){
                buyerOk = true;
                stage = Stages.BuyerAccepted;
                EscrowEvent(600, "buyerAccepted", msg.sender,0, hashContent);
            } else if (msg.sender == seller){
                sellerOk = true;
                stage = Stages.SellerAccepted;
                EscrowEvent(700, "sellerAccepted", msg.sender,0, hashContent);
            }
            
            if (buyerOk && sellerOk){
                payBalance(hashContent);
                stage = Stages.Settled;
                EscrowEvent(800, "settled", msg.sender,0, hashContent);
            }
            
            //  else if (buyerOk && !sellerOk && now > start + 30 days) {
            //     // Freeze 30 days before release to buyer. The customer has to remember to call this method after freeze period.
            //     selfdestruct(buyer);
            // }
        }
    }

    function cancel(string hashContent) public  timedTransitions {
        if ( (stage == Stages.Created) || (stage == Stages.BuyerCancelled) || (stage == Stages.SellerCancelled) ){
            if (msg.sender == buyer){
                buyerOk = true;
                stage = Stages.BuyerCancelled;
                EscrowEvent(620, "BuyerCancelled", msg.sender,0, hashContent);
            } else if (msg.sender == seller){
                sellerOk = true;
                stage = Stages.SellerCancelled;
                EscrowEvent(720, "SellerCancelled", msg.sender,0, hashContent);
            }
            
            if (buyerOk && sellerOk){
                returnBalance(hashContent);
                stage = Stages.Settled;
                EscrowEvent(800, "settled", msg.sender,0, hashContent);
            }
            
            //  else if (buyerOk && !sellerOk && now > start + 30 days) {
            //     // Freeze 30 days before release to buyer. The customer has to remember to call this method after freeze period.
            //     selfdestruct(buyer);
            // }
        }
    }

    function requestArbitration(string hashContent) public payable timedTransitions transitionAfter(Stages.ArbiterationRequested) {
        EscrowEvent(220, "requestArbitration", msg.sender,0,hashContent);
    }

    
    function arbitrateReduce(string hashContent,uint amount ) public  timedTransitions atStage(Stages.ArbiterationRequested) {
        require(msg.sender == arbitrator );
        reduceEscrowBy(hashContent,amount);
        EscrowEvent(800, "arbitrateReduce", msg.sender,amount, hashContent);
    }

    function sellerReduce(string hashContent,uint amount ) public  timedTransitions atStage(Stages.Created) {
        require(msg.sender == seller );
        reduceEscrowBy(hashContent,amount);
        EscrowEvent(810, "sellerReduce", msg.sender,amount, hashContent);
    }

   function arbitrateSettle(string hashContent) public  timedTransitions atStage(Stages.ArbiterationRequested) transitionAfter(Stages.Settled) {
        require(msg.sender == arbitrator );
        payBalance(hashContent);
        EscrowEvent(820, "arbitrateSettle", msg.sender,0, hashContent);
    }

    
    //reduce the escrow by given amount, only called by buyer 
    function reduceEscrowBy(string hashContent,uint amount) private {
        IToken token = IToken(wethr);
        uint bal = token.balanceOf(address(this));

        if (amount < bal)
        {
            //note below that contract itself is the msg.sender
            if (token.transfer(buyer, amount)) {
            } else {
                EscrowError(403, "TransferFailed", msg.sender,0);
                throw;
            }
        } else
            EscrowError(402, "reduceEscrowWrongAmount", msg.sender,0);

    EscrowEvent(400, "EscrowReducedBy", msg.sender,amount, hashContent);
    } 




    
 //   function payBalance(address party, uint amount, string hashContent) private tokenPayable {
   function payBalance(string hashContent) private {
         // we are sending ourselves (contract creator) a fee
       // escrow.transfer(balance / 100);
        // send seller the balance, send only works on ether hence changing
        IToken token = IToken(wethr);
        uint bal = token.balanceOf(address(this));
        // Check the token contract if we have been issued tokens already
//          token.approve(this, balance);
//          if (token.transferFrom(this, seller, this.balance)) {

        //note below that contract itself is the msg.sender

        if (token.transfer(seller, bal)) {
        } else {
            EscrowError(703, "TransferFailed", msg.sender,0);
            throw;
        }
        EscrowEvent(750, "payBalanceToSeller", msg.sender,bal, hashContent);
    }
    

   function returnBalance(string hashContent) private {
        //note below that contract itself is the msg.sender
        IToken token = IToken(wethr);
        uint bal = token.balanceOf(address(this));

        if (token.transfer(buyer, bal)) {
        } else {
            EscrowError(703, "TransferFailed", msg.sender,0);
            throw;
        }
        EscrowEvent(750, "returnBalance", msg.sender,bal, hashContent);
    }



    






    
    function kill() public constant {
        if (msg.sender == creator) {
            selfdestruct(buyer);
        }
    }

  function getState() public constant returns (uint) {
    return uint(stage);
  }

  function getBalance() public constant returns (uint) {
    IToken token = IToken(wethr);
    uint bal = token.balanceOf(address(this));
    return bal;
  }

  function supportsToken(address token) returns (bool) {
    return true;
  }

//   function () tokenPayable {
//     //LogTokenPayable(0, tkn.addr, tkn.sender, tkn.value);
//   }


}