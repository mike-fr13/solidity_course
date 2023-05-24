// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

interface interfaceB {
    function getNombre() external view returns (uint);
    function setNombre(uint _nombre) external;
}

contract B is interfaceB {
    uint monNombre;

    function getNombre() external view returns (uint) {
        return monNombre;
    }
    function setNombre(uint _nombre) external {
        monNombre=_nombre;
    }
    
}

contract A {

    interfaceB intB;

    constructor(interfaceB _intB) {
        intB = _intB;
    }

    function monGetNombre () external view returns (uint){
        return intB.getNombre();
    }

    function monSetNombre(uint _nb) external {
        intB.setNombre(_nb);
    }

}