// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable {

    function getAnsmwer() external view onlyOwner() returns (uint) {
        return (42)
;    }

}