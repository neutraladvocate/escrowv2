pragma solidity ^0.4.8;


import '../../contracts/implementation/wethr_token.sol';

// mock class using wethr_token
contract StandardTokenMock is wethr_token {
  function StandardTokenMock(address initialAccount, uint initialBalance) {
    balances[initialAccount] = initialBalance;
    totalSupply = initialBalance;
  }
}
