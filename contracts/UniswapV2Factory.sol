// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import '@chainlink/contracts/src/v0.5/interfaces/AggregatorV3Interface.sol';
import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';
import './interfaces/INFTFactory.sol';

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public admin;
    address public nftFactory;
    uint256 public MINIMUM_DEPOSIT = 300000;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));


    mapping(address => address) public getPriceFeed;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _admin, address _nftFactory) public {
        admin = _admin;
        nftFactory = _nftFactory;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function updateMinimumDeposit(uint256 newValue) external {
        require(msg.sender == admin, "Forbidden access");
        MINIMUM_DEPOSIT = newValue;
    }

    function createPair(address tokenA, address tokenB, address oracle0, address oracle1) external returns (address pair) {
        require(msg.sender == admin, "Error: Forbidden");
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1, nftFactory);
        set_priceFeeds(tokenA, tokenB, oracle0, oracle1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function set_priceFeeds(address token0, address token1, address oracle0, address oracle1) public {
        require(msg.sender == admin, 'Defi Warriror: FORBIDDEN');
        getPriceFeed[token0] = oracle0;
        getPriceFeed[token1] = oracle1;
    }
    
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function validate_amount(address token0, address token1, uint256 amount0In, uint256 amount1In) internal view returns (uint256) {
        AggregatorV3Interface priceFeed0 = AggregatorV3Interface(getPriceFeed[token0]);
        AggregatorV3Interface priceFeed1 = AggregatorV3Interface(getPriceFeed[token1]);

        int256 price0;
        int256 price1;

        (, price0, , ,) = priceFeed0.latestRoundData();
        (, price1, , ,) = priceFeed1.latestRoundData();

        uint256 left = (uint256(price0) * amount0In * 10000) / ((uint256(10)**priceFeed0.decimals()) * (uint256(10)**IUniswapV2Pair(token0).decimals()));
        uint256 right = (uint256(price1) * amount1In * 10000) / ((uint256(10)**priceFeed1.decimals()) * (uint256(10)**IUniswapV2Pair(token1).decimals()));
        return left + right;
    }

    // mint new NFT character
    function mintCharacter(address token0, address token1, uint256 amount0In, uint256 amount1In) external returns (uint256 characterId) {
        require(amount0In > 0 && amount1In > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');

        address pair = getPair[token0][token1];
        require(pair != address(0), "Invalid Pair");
        require(validate_amount(token0, token1, amount0In, amount1In) >= MINIMUM_DEPOSIT, 'Deposit amount < minimum deposit');

        safeTransferFrom(token0, msg.sender, admin, amount0In); // optimistically transfer tokens
        safeTransferFrom(token1, msg.sender, admin, amount1In); // optimistically transfer tokens

        IUniswapV2Pair(pair).approveFarm(msg.sender);

        return INFTFactory(nftFactory).mint(msg.sender, pair);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == admin, 'Defi Warriror: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setAdmin(address _admin) external {
        require(msg.sender == admin, 'Defi Warriror: FORBIDDEN');
        admin = _admin;
    }
}
