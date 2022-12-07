pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT 

contract Blackjack {
    uint public baseFee;
    uint private difficulty = 10;
    
    event GameStatus(address _player,string _winStatus,bool __winStatusBool,uint _total);
    
    mapping(address => Gamer) public game;
    struct Gamer  {
      uint userBaseFee;
      uint[] playerHand;
      uint[] houseHand;
      uint playerBet;
      uint gameState;  // The game's current state (0 = not started, 1 = player turn, 2 = house turn, 3 = game over)
    }

    function startGame() public payable{
      require(msg.value >= baseFee, "The bet must be at least the base fee");
      require(game[msg.sender].gameState == 3 || game[msg.sender].gameState == 0);
      game[msg.sender].playerBet = msg.value;
      // Deal the initial cards to the player and the house
      game[msg.sender].playerHand.push(dealCard(block.timestamp));
      game[msg.sender].playerHand.push(dealCard(block.difficulty));
      game[msg.sender].houseHand.push(dealCard(block.number));
      game[msg.sender].houseHand.push(dealCard(block.gaslimit));
      game[msg.sender].gameState = 1;
    }

    function hit() public returns(uint){
      uint newCard = dealCard(block.timestamp);
      if (game[msg.sender].gameState == 1) {
        game[msg.sender].playerHand.push(newCard);

        if (getHandValue(game[msg.sender].playerHand) >= 21) {
          game[msg.sender].gameState = 3;
          isGameOver();
        }
      }
      return newCard;
    }

    // Function to stand (end the player's turn)
    function stand() public {
      // Check if it is the player's turn and the game is not over
      if (game[msg.sender].gameState == 1 && !isGameOver()) {
        // Set the game state to the house's turn
        game[msg.sender].gameState = 2;

        // Keep hitting until the house has at least 17
        while (getHandValue(game[msg.sender].houseHand) <= 17) {
          game[msg.sender].houseHand.push(dealCard(block.timestamp));
        }

        // If the house has bust, end the game
        if (getHandValue(game[msg.sender].houseHand) > 21) {
          game[msg.sender].gameState = 3;
          isGameOver();
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
    function getHandValue() public view returns(uint) {
      uint number = 0;
      for(uint i = 0; i < game[msg.sender].playerHand.length; i++){
        number += game[msg.sender].playerHand[i];
      }
      return number;
    }
    function reset()internal {
        game[msg.sender].playerHand = [0,0];
        game[msg.sender].houseHand = [0,0];
        game[msg.sender].playerBet = 0; 
    }
    
    function isGameOver() internal returns(bool){
      if (game[msg.sender].gameState == 3 &&  getHandValue(game[msg.sender].playerHand) == 21) {
        emit GameStatus(msg.sender,"You Win",true,getHandValue(game[msg.sender].playerHand));
        reset();
        return true;
      } else if (game[msg.sender].gameState == 3 && getHandValue(game[msg.sender].playerHand) > getHandValue(game[msg.sender].houseHand) &&  getHandValue(game[msg.sender].playerHand) <= 21) {
        emit GameStatus(msg.sender,"You Win",true,getHandValue(game[msg.sender].playerHand));
        reset();
        return true;
      } else {
        emit GameStatus(msg.sender,"You Loose",false,getHandValue(game[msg.sender].playerHand));
        reset();
        return false;
    }
  }
}