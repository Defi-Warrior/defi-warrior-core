pragma solidity =0.5.16;

import '../DefiWarriorERC20.sol';

contract ERC20 is DefiWarriorERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
