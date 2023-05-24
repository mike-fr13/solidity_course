// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract CompteEpargne is Ownable {

    uint numDepot;
    mapping(uint => uint) listeDepots;
    uint public firstDepositDate;

    uint delayWithdraw = 12 weeks;

    error CompteEpargne_MustWait(string errorMsg);

    constructor() {
    }

    function setDelay(uint _delay) external onlyOwner() {
        delayWithdraw = _delay;
    }

    function sendMoney() external payable onlyOwner(){
        require (msg.value >0, "le depot doit etre positif");
        if (firstDepositDate==0) {
            firstDepositDate = block.timestamp;
        }
        numDepot ++;
        listeDepots[numDepot] = msg.value;
    }

    function withdraw() external onlyOwner{
        if (block.timestamp > firstDepositDate +  delayWithdraw) {
            
        (bool sent, ) = owner().call{value: address(this).balance }("");

        //require revert to ce qui a été fai ds la fonction
        if (!sent) {
            revert CompteEpargne_MustWait("erreur lors du withdraw");
        } 
        //require(sent,"msg");

        firstDepositDate = 0;
        } else {
            revert CompteEpargne_MustWait("le delai de withdraw n'est pas respoecte");
        }
    }


    

}