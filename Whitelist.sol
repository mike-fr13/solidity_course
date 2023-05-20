// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

contract Whitelist {

     mapping(address => bool) whitelist;
     event Authorized(address _address);
     event EthReceived(address _address, uint _value);

    constructor (){
        whitelist[msg.sender] = true;
    }

     modifier isWhiteListed() {
        require (whitelist[msg.sender],"You are not authorized");
        _;
     }

     function authorize(address _address) public isWhiteListed {
            whitelist[_address] = true;
            emit Authorized(_address);
     }


    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    fallback() external payable {
       emit EthReceived(msg.sender, msg.value);
     }


}