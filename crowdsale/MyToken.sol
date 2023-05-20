// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

     constructor(uint _initialSupply) ERC20("MonToken","MTO"){
        _mint(msg.sender, _initialSupply);
    }
}