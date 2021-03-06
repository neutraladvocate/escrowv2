pragma solidity ^0.4.8;

 /* WorkEther token contract code . ERC223 additions to ERC20 */

import "../interface/ERC223.sol";
import "../interface/ERC223Receiver.sol";

import "./StandardToken.sol";

contract wethr_token is ERC223, StandardToken {

    uint public constant initialSupply = 50000000000000000000000000;
    string public constant name = "WorkEther";
    string public constant symbol = "wethr";
    uint8  public constant decimals = 18;  

  /* Initializes contract with initial supply tokens to the creator of the contract */
  function wethr_token  () payable public {
        balances[msg.sender] = initialSupply;              // Give the creator all initial tokens
  }

  event Status(uint statusCode);

  //function that is called when a user or another contract wants to transfer funds
  function transfer(address _to, uint _value, bytes _data) returns (bool success)  {
    //filtering if the target is a contract with bytecode inside it
//    if (!super.transfer(_to, _value)) throw; // do a normal token transfer
      if (super.transfer(_to, _value))
      {
          Status(400);//super.transfer worked
          //done
      } else
      {
          Status(401);//super.transfer failed
          throw; // do a normal token transfer
      }
      
//      if (isContract(_to)) return contractFallback(msg.sender, _to, _value, _data);
      if (isContract(_to)) {
          Status(601);//its a contract
          return contractFallback(msg.sender, _to, _value, _data);
      } 

  return true;
  }

  function transferFrom(address _from, address _to, uint _value, bytes _data) returns (bool success)  {
    if (!super.transferFrom(_from, _to, _value)) throw; // do a normal token transfer
    if (isContract(_to)) return contractFallback(_from, _to, _value, _data);
    return true;
  }

  function transfer(address _to, uint _value) returns (bool success)  {
    Status(_value);
    return transfer(_to, _value, new bytes(0));
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success)  {
    return transferFrom(_from, _to, _value, new bytes(0));
  }

  //function that is called when transaction target is a contract
  function contractFallback(address _origin, address _to, uint _value, bytes _data) private returns (bool success) {
    ERC223Receiver reciever = ERC223Receiver(_to);
    return reciever.tokenFallback(msg.sender, _origin, _value, _data);
  }

  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
    // retrieve the size of the code on target address, this needs assembly
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }

  

}
