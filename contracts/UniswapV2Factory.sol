// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public admin;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    mapping(address => mapping(address => address)) public getPair;

    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    modifier onlyAdmin() {
        require(msg.sender == admin, 'Defi Warriror: FORBIDDEN');
        _;
    }

    constructor(address _admin) public {
        admin = _admin;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setPriceFeeds(address token0, address oracle0, address token1, address oracle1) onlyAdmin public {
        address pair = getPair[token0][token1];
        IUniswapV2Pair(pair).initPriceFeeds(oracle0, oracle1);
    }

    function setFeeTo(address _feeTo) external onlyAdmin {
        feeTo = _feeTo;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }
}
