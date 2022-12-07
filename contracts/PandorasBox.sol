pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT 
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./SHARE.sol";
import "./BlackJack.sol";
import "hardhat/console.sol";
// 1M EXECUTIONS @0.25each = min 1,000 | max $250,000
//Jackpot - 95% .        1/1M    min win: $1000      | max win: $250,000 1x
//4/5     - 5%           1/100k  min win: $50        | max win: $25,000 10x
//3/5     - 0.5%         1/10k   min win: $5         | max win: $1250 100x

contract PandorasBox is Blackjack,XRCSHARE{
    uint public dificulty=10;
    uint public entrapy;
    uint public Spins=0;
    uint public Cycles=1;

    uint public previousJackpotTime;
    uint public previous2ndPrizeTime;
    uint public previous3rdPrizeTime;

    constructor(string memory _name,string memory _symbol,uint _totalSupply,uint _baseFee,string memory URI) payable XRCSHARE(_name,_symbol,_totalSupply, URI){
        baseFee = _baseFee;
        entrapy = _baseFee**_totalSupply**(block.timestamp);
        console.log(address(this));
    }

    modifier Fee{
        require(msg.value >= baseFee,"not enough funds to activate game");
        _;
    }

    function Spin(string memory _input)public payable Fee returns(uint,uint,uint,uint,uint,bool){
        uint _entrapy = random(uint256(keccak256(abi.encodePacked(_input))),1000000);
        entrapy = random(uint256(keccak256(abi.encodePacked(_input))),_entrapy);

        uint entrapy1 = random(uint256(keccak256(abi.encodePacked(entrapy))), dificulty);
        uint entrapy2 = random(uint256(keccak256(abi.encodePacked(block.timestamp+entrapy))), dificulty);
        uint entrapy3 = random(uint256(keccak256(abi.encodePacked(block.coinbase)))+entrapy, dificulty);
        uint entrapy4 = random(uint256(keccak256(abi.encodePacked(block.number+entrapy))), dificulty);
        uint entrapy5 = random(uint256(keccak256(abi.encodePacked(block.gaslimit+entrapy))), dificulty);

        refund(payable(msg.sender), baseFee, msg.value);
        
        bool win = winConditions(entrapy1,entrapy2,entrapy3,entrapy4,entrapy5,payable(msg.sender));
        //console.log(entrapy1,entrapy2,entrapy3,entrapy4,entrapy5,win);
        return (entrapy1,entrapy2,entrapy3,entrapy4,entrapy5,win);
    }

    function winConditions(uint _entrapy1,uint _entrapy2, uint _entrapy3, uint _entrapy4, uint _entrapy5,address payable _user)internal returns(bool){
        uint _entrapy = random(uint256(keccak256(abi.encodePacked(entrapy))),dificulty);
        if(_entrapy1 == _entrapy && _entrapy2 == _entrapy && _entrapy3 == _entrapy && _entrapy4 == _entrapy && _entrapy5 == _entrapy){
            _user.transfer((address(this).balance/100) * 95);
            Spins=0;
            Cycles++;
            return true;
        }
        Spins++;
        return false;
    }
    
    function refund(address payable _buyer, uint _total,uint _amount)internal returns(uint) {
        if(_amount > _total){
            _buyer.transfer(_amount - _total);
            return (_amount - _total);
        }
        return _amount;
    }
}