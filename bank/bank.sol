// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

contract MyBank {

    mapping (address => uint) internal _balances;

    modifier positive (uint _val) {
        require (_val >0, "le montant doit etre positif");
        _;
    }
    modifier notNullAdress(address _addrToCheck) {
        require(_addrToCheck != address(0) ,"l'adresse ne doit pas etre nulle");
        _;
    }

    function deposit(uint _amount) public positive (_amount){
        _balances[msg.sender] += _amount;
    }

    function tranfer(address _recipient, uint _amount) public positive (_amount) notNullAdress (_recipient) {
        require (_balances[msg.sender]>= _amount, "solde insuffisant");
        _balances[msg.sender] -= _amount;
        _balances[_recipient] += _amount;
  }

    function balanceof (address _account) public view returns (uint) {
        return _balances[_account];
    }


}