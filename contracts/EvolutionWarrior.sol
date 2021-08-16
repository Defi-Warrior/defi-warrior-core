pragma solidity >=0.5.16;

import './interfaces/IERC20.sol';
import './libraries/Ownable.sol';
import './DefiWarrior.sol';
import './libraries/ECDSA.sol';
import './libraries/SafeMath.sol';

contract EvolutionWarrior is Ownable {
    using ECDSA for bytes32;
    using SafeMath for uint256;

    DefiWarrior public WARRIOR;
    IERC20 public GEM;

    event ForkingToken(uint256 tokenId, uint256[25] attributes);
    event EvolutionToken(uint256 tokenId, uint256[25] attributes);

    // Forking from token
    mapping (uint256 => uint256[]) public forkingTokens;

    // Evoluation from token
    mapping (uint256 => mapping(address => uint256[25])) public evolutionTokens;

    // Mitigating Replay Attacks
    mapping(address => mapping(uint256 => bool)) seenNonces;

    uint public gemNeeded = 1000;
    uint public limitForking = 5;


    constructor (DefiWarrior _warrior, address _gem) public {
        WARRIOR = _warrior;
        GEM = IERC20(_gem);
    }

    function setWarrior(DefiWarrior _warrior) external onlyOwner {
        WARRIOR = _warrior;
    }

    function setGem(address _gem) external onlyOwner {
        GEM = IERC20(_gem);
    }

    function setLimitForking(uint _limitForking) external onlyOwner {
        limitForking = _limitForking;
    }

    modifier conditionEvolution(uint256 tokenId, uint256 nonce, bytes memory signature) {
        // This recreates the message hash that was signed on the client.
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, nonce, tokenId));
        bytes32 messageHash = hash.toEthSignedMessageHash();

        // Verify that the message's signer is the owner of the order
        address signer = messageHash.recover(signature);
        require(signer == owner());

        require(!seenNonces[msg.sender][nonce]);
        seenNonces[msg.sender][nonce] = true;
        _;
    }

    function forking(uint256 tokenId, uint256 nonce, bytes calldata signature, uint256[25] calldata _attributes
            ) external conditionEvolution(tokenId, nonce, signature) {
        // Check condition forking one tokenId following on limitForking
        require(forkingTokens[tokenId].length < limitForking);
        uint256 tokenMint = WARRIOR.mint(msg.sender, _attributes);
        forkingTokens[tokenId].push(tokenMint);
        emit ForkingToken(tokenId, _attributes);
    }

    function upgradeLevel(uint256 tokenId, uint256 amount, uint256 nonce, bytes calldata signature, 
            uint256[25] calldata _attributes
            ) external conditionEvolution(tokenId, nonce, signature) {
        // Check payment for upgrade level
        uint256 allowance = GEM.allowance(msg.sender, address(this));
        require(allowance >= gemNeeded, "Check the token allowance");
        GEM.transferFrom(msg.sender, address(this), amount);
        // Upgrade level
        WARRIOR.upgradeLevel(tokenId, _attributes);
        emit EvolutionToken(tokenId, _attributes);
    }
}
