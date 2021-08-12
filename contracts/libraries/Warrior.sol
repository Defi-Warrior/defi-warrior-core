pragma solidity ^0.5.0;

contract Warrior {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    // only this address able to call farming related functions
    address public gemFactory;

    // mapping from user address => plannetId => num warrior in that plannet
    mapping(address => mapping(uint256 => uint256)) public numWarriorInPlannet;

    // mapping to check which plannet user is farming
    mapping(address => mapping(uint256 => bool)) public isFarming;

    // list of available plannet, will be updated when the game progress
    mapping(uint => bool) validPlannet;

    // mapping from tokenId to atrtibutes
    mapping(uint256 => uint256[25]) public attributes;
    // 0: plannet
    // 1: tribe
    // 2: health
    // 3: critRate
    // 4: critMultiplier
    // 5: skillDamage
    // 6: attack
    // 7 -> 24: reserved fields

    function getWarriors(uint256[] calldata ids) external view returns(uint256[25][] memory) {
        uint256[25][] memory atts = new uint256[25][](ids.length);
        for(uint i = 0; i < ids.length; i++) {
            atts[i] = attributes[ids[i]];
        }
        return atts;
    }

    function getWarriorAt(uint256 index) external view returns(uint256[25] memory) {
        return attributes[index];
    }

    function startFarming(address user, uint256 plannet) external {
        require(msg.sender == gemFactory, "Sender must be GemFactory");
        require(validPlannet[plannet], "Invalid Plannet");
        isFarming[user][plannet] = true;
    }

    function stopFarming(address user, uint256 plannet) external {
        require(msg.sender == gemFactory, "Sender must be GemFactory");
        require(validPlannet[plannet], "Invalid Plannet");
        isFarming[user][plannet] = false;
    }
}