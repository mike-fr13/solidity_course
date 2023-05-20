// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

contract People {

    struct Person {
        string nom;
        uint age;
    }

    Person[] public persons;

    function add( string calldata _nom, uint _age) public {
        Person memory toAdd = Person(_nom,_age);
        persons.push(toAdd);
    }

    function remove( ) public returns (  Person memory _last) {
        require(persons.length > 0, "No person to remove");
       _last = persons[persons.length -1];
        persons.pop();
    }
 
  

}