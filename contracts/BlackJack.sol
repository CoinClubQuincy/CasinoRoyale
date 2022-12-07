pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT 

contract Blackjack {
  uint public baseFee;
  uint private difficulty = 10;

  uint public userBaseFee;
  uint[] public playerHand;
  uint[] public houseHand;
  uint public playerBet;
  // The game's current state (0 = not started, 1 = player turn, 2 = house turn, 3 = game over)
  uint public gameState;


  function startGame() public payable {
    require(msg.value >= baseFee, "The bet must be at least the base fee");
    playerBet = msg.value;
    // Deal the initial cards to the player and the house
    playerHand.push(dealCard(block.timestamp));
    playerHand.push(dealCard(block.difficulty));
    houseHand.push(dealCard(block.number));
    houseHand.push(dealCard(block.gaslimit));
    gameState = 1;
  }

  function hit() public {
    if (gameState == 1 && !isGameOver()) {
      playerHand.push(dealCard(block.timestamp));

      if (getHandValue(playerHand) >= 21) {
        gameState = 3;
      }
    }
  }

  // Function to stand (end the player's turn)
  function stand() public {
    // Check if it is the player's turn and the game is not over
    if (gameState == 1 && !isGameOver()) {
      // Set the game state to the house's turn
      gameState = 2;

      // Keep hitting until the house has at least 17
      while (getHandValue(houseHand) <= 17) {
        houseHand.push(dealCard(block.timestamp));
      }

      // If the house has bust, end the game
      if (getHandValue(houseHand) > 21) {
        gameState = 3;
      }
    }
  }

  function random(uint _entropy, uint _multiplier) internal view returns(uint){ 
      uint256 seed = uint256(keccak256(abi.encodePacked( block.timestamp + block.difficulty +
      ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
      block.gaslimit + 
      ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
      block.number + _entropy)));
      
      return (seed - ((seed / _multiplier) * _multiplier));
  }

  function dealCard(uint _entropy) internal view returns(uint){  
       return(random(_entropy, difficulty) + 3);
  }

  function getHandValue(uint[] memory _playerHand) internal view returns(uint) {
    uint number = 0;
    for(uint i = 0; i < _playerHand.length; i++){
        number += _playerHand[i];
    }
    return number;
  }

  function isGameOver() internal view returns(bool){
      if (gameState == 3) {
          return true;
      }
      return false;
  }
}