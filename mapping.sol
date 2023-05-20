// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18;

contract Moyenne {

     mapping(address => uint[]) notesDesEleves;

     function addNote(address _eleve, uint note) public{
         uint[] storage notes = notesDesEleves[_eleve];
         notes.push(note);
     }

    function moyenne(address _eleve) public view returns (uint) {
        uint[] memory notes = notesDesEleves[_eleve];
        uint somme = 0;
        for(uint i=0; i<notes.length;i++) {
            somme += notes[i];
        }
        return (somme/notes.length);
    }

}