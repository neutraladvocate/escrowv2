pragma solidity ^0.4.8;
import "../implementation/wethr_token.sol";

contract ExampleToken is wethr_token {
  function ExampleToken(uint initialBalance) {
    balances[msg.sender] = initialBalance;
    totalSupply = initialBalance;
    // Ideally call token fallback here too
  }
}
