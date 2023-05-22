
pragma solidity >=0.8.18;


contract Random {

    uint private nonce;

    function random() public returns (uint256)  {
        nonce ++;
        return (uint256)(keccak256(abi.encodePacked(block.timestamp,msg.sender,nonce)));
    }

}

