pragma solidity >=0.5.16;

import './interfaces/IERC20.sol';
import './libraries/Ownable.sol';
import './libraries/ECDSA.sol';


interface DefiWarrior {
    function mint(address tokenOwner, uint256[30] calldata _attributes) external returns (uint256);
    function getAttribute(uint256 tokenId) external returns (uint256[30] memory);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function sync(uint256 tokenId, uint256[30] calldata _attributes) external;
    function ownerOf(uint256 tokenId) external returns(address);
}


contract EvolutionWarrior is Ownable {

    struct UpgradeCost {
        uint256 tokenAmount;
        uint256 level;
    }

    using ECDSA for bytes32;

    DefiWarrior public WARRIOR;
    IERC20 public GEM;

    event ForkingToken(uint256 fromTokenId, uint256 newTokenId, uint256[30] attributes);
    event EvolveWarrior(uint256 tokenId, uint256[30] attributes);

    // Mitigating Replay Attacks
    mapping(address => mapping(uint256 => bool)) seenNonces;

    uint public limitForking = 5;
    uint public evolutionLimit = 5;

    mapping(uint => UpgradeCost) public evolutionCosts;
    mapping(uint => UpgradeCost) public forkingCosts;


    constructor (DefiWarrior _warrior, address _gem) public {
        WARRIOR = _warrior;
        GEM = IERC20(_gem);

        evolutionCosts[0] = UpgradeCost(1000 * 10 * GEM.decimals(), 10);
        evolutionCosts[1] = UpgradeCost(2000 * 10 * GEM.decimals(), 20);
        evolutionCosts[2] = UpgradeCost(3000 * 10 * GEM.decimals(), 30);

        forkingCosts[0] = UpgradeCost(1000 * 10 * GEM.decimals(), 30);
        forkingCosts[1] = UpgradeCost(3000 * 10 * GEM.decimals(), 30);
        forkingCosts[2] = UpgradeCost(6000 * 10 * GEM.decimals(), 30);
    }

    function setWarrior(DefiWarrior _warrior) external onlyOwner {
        WARRIOR = _warrior;
    }

    function setGem(address _gem) external onlyOwner {
        GEM = IERC20(_gem);
    }

    function setEvolutionLimit(uint _evolutionLimit) external onlyOwner {
        evolutionLimit = _evolutionLimit;
    }

    function setLimitForking(uint _limitForking) external onlyOwner {
        limitForking = _limitForking;
    }

    function updateForkingCost(uint256 time, uint256 cost, uint256 level) external onlyOwner {
        forkingCosts[time] = UpgradeCost(cost, level);
    }

    function updateEvolutionCost(uint256 time, uint256 cost, uint256 level) external onlyOwner {
        evolutionCosts[time] = UpgradeCost(cost, level);
    }

    modifier verifySignature(uint256 tokenId, uint256 nonce, uint256[30] memory _attributes, bytes memory signature) {
        // This recreates the message hash that was signed on the client.
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, tokenId, nonce, _attributes));
        bytes32 messageHash = hash.toEthSignedMessageHash();
        // Verify that the message's signer is the owner of the order
        require(messageHash.recover(signature) == owner(), "Invalid signature");
        require(!seenNonces[msg.sender][nonce], "Used nonce");
        seenNonces[msg.sender][nonce] = true;
        _;
    }

    function fork(uint256 tokenId, uint256 tokenCost, uint256[30] memory _attributes) internal {
        GEM.transferFrom(msg.sender, address(this), tokenCost);

        uint256 newTokenId = WARRIOR.mint(msg.sender, _attributes);
        // burn father warrior
        WARRIOR.safeTransferFrom(msg.sender, address(0x0), tokenId);

        emit ForkingToken(tokenId, newTokenId, _attributes);
    }

    function forkWarrior(uint256 tokenId, uint256 nonce, bytes calldata signature, uint256[30] calldata _attributes
            ) external verifySignature(tokenId, nonce, _attributes, signature) {
        require(WARRIOR.ownerOf(tokenId) == msg.sender, "Caller is not owner");
        uint forkCount = WARRIOR.getAttribute(tokenId)[5];
        uint warriorLevel = WARRIOR.getAttribute(tokenId)[2];
        UpgradeCost memory upgradeCost = forkingCosts[forkCount];

        require(forkCount < limitForking && warriorLevel >= upgradeCost.level, "Fork exceed limit or level < requirement");

        fork(tokenId, upgradeCost.tokenAmount, _attributes);
    }

    function evolve(uint256 tokenId, uint256 tokenCost, uint256[30] memory _attributes) internal {
        GEM.transferFrom(msg.sender, address(this), tokenCost);
        // Upgrade attribute
        WARRIOR.sync(tokenId, _attributes);

        emit EvolveWarrior(tokenId, _attributes);
    }

    function upgradeLevel(uint256 tokenId, uint256 nonce, bytes calldata signature, uint256[30] calldata _attributes
            ) external verifySignature(tokenId, nonce, _attributes, signature) {
        require(WARRIOR.ownerOf(tokenId) == msg.sender, "Caller is not owner");

        uint warriorLevel = WARRIOR.getAttribute(tokenId)[2];
        uint evolveCount = WARRIOR.getAttribute(tokenId)[6];
        UpgradeCost memory upgradeCost = evolutionCosts[evolveCount];

        require(evolveCount < evolutionLimit && warriorLevel >= upgradeCost.level, "Evolve exceed limit or level < requirement");

        evolve(tokenId, upgradeCost.tokenAmount, _attributes);
    }

    function withdraw(address to) external onlyOwner {
        GEM.transfer(to, GEM.balanceOf(address(this)));
    }
}
