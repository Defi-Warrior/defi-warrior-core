pragma solidity =0.5.16;
import './DefiWarriorPair.sol';

contract CalculateInitCode {
    function getInitHash() public pure returns(bytes32){
        bytes memory bytecode = type(DefiWarriorPair).creationCode;
        return keccak256(abi.encodePacked(bytecode));
    }
}