// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./MyToken.sol";

contract CrowdSale {
    uint publicRate = 200;
    MyToken public token;

    constructor (uint _initSupply) {
        token = new MyToken (_initSupply);
    }
     

    receive() external payable {
        require (msg.value > 0.5 ether,"minimum deposit is 0.5 ether");
        distribute(msg.value);
    }

    function distribute( uint _ETHvalue) internal{
        uint tokenAmountToSend = _ETHvalue*publicRate;
        token.transfer(msg.sender, tokenAmountToSend);
        
    }

}

    