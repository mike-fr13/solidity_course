pragma solidity >=0.8.18;


import "https://github.com/smartcontractkit/chainlink-brownie-contracts/blob/main/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomGenerator is VRFConsumerBase {
    
    bytes32 public reqId;
    uint256 public randomNumber;

    constructor(address _vrfCoordinator, address _link) VRFConsumerBase(_vrfCoordinator, _link)  {
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        reqId = requestId;
        randomNumber = randomness;
    }
}