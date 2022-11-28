pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT 
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./SHARE.sol";

contract CasinoRoyale is XRCSHARE{

    uint public baseFee=0;
    uint public dificulty=100;

    constructor(string memory _name,string memory _symbol,uint _totalSupply,string memory URI) payable XRCSHARE(_name,_symbol,_totalSupply, URI){}

    modifier Fee{
        require(msg.value>=baseFee,"not enough funds to activate game");
        _;
    }

    function Slots(string memory _entrapy)public payable Fee returns(uint,uint,uint,bool){
        uint entrapy1 = random(uint256(keccak256(abi.encodePacked(_entrapy))), dificulty);
        uint entrapy2 = random(uint256(keccak256(abi.encodePacked(block.timestamp))), dificulty);
        uint entrapy3 = random(uint256(keccak256(abi.encodePacked(block.coinbase))), dificulty);

        refund(payable(msg.sender), baseFee, msg.value);
        bool win = winCondition(entrapy1,entrapy2,entrapy3,payable(msg.sender));
        return (entrapy1,entrapy2,entrapy3,win);
    }

    function winCondition(uint _entrapy1,uint _entrapy2, uint _entrapy3,address payable _user)internal returns(bool){
        if(_entrapy1 == dificulty && _entrapy2 == dificulty && _entrapy3 == dificulty){
            _user.transfer((address(this).balance/100) * 95);
            return true;
        }
        return false;
    }

    function random(uint _entrapy, uint _multiplier) internal view returns(uint){ 
        uint256 seed = uint256(keccak256(abi.encodePacked( block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number + _entrapy)));
        
        return (seed - ((seed / _multiplier) * _multiplier));
    }
    function refund(address payable _buyer, uint _total,uint _amount)internal returns(uint) {
        if(_amount > _total){
            _buyer.transfer(_amount - _total);
            return (_amount - _total);
        }
        return _amount;
    }

}