// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable {

     mapping(address => bool) whitelist;
     mapping(address => bool) blacklist;
     event Whitelisted(address _address);
     event Blacklisted(address _address);

    constructor (){
        whitelist[msg.sender] = true;
    }

    modifier notWhitelisted(address _address) {
        require(!whitelist[_address],"l'adresse est deja ds la whitelist");
        _;
    }

    modifier notBlacklisted(address _address) {
        require(!blacklist[_address],"l'adresse est deja ds la blacklist");
        _;
    }

    function authorize(address _address) public onlyOwner() notWhitelisted(_address) notBlacklisted(_address) {
            whitelist[_address] = true;
            emit Whitelisted(_address);
     }

    function ban(address _address) public onlyOwner() notWhitelisted(_address) notBlacklisted(_address)  {
            blacklist[_address] = true;
            emit Blacklisted(_address);
     }

     function isWhitelisted(address _address) public view onlyOwner returns(bool) {
         return (whitelist[_address]);
     }

     function isBlacklisted(address _address) public view onlyOwner returns(bool) {
         return (blacklist[_address]);
     }


}