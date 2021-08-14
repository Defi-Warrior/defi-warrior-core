pragma solidity >=0.5.16;

import './interfaces/IERC20.sol';
import './libraries/ERC721.sol';
import './libraries/ERC721Enumerable.sol';
import './libraries/ERC721Metadata.sol';
import './libraries/Ownable.sol';

contract DefiWarrior is Warrior, ERC721, ERC721Enumerable, ERC721Metadata, Ownable {

    // token that user need to pay
    address public currency;

    // amount of currency user need to pay to mint new warrior
    uint256 public WARRIOR_PRICE = 1000000000000000000;

    // num warrior that is allowed to buy using FIWA token
    uint256 constant public NUM_GENESIS_WARRIOR = 1000;

    // list of addresses that are able to mint new character
    mapping(address => bool) miners;

        constructor (string memory name, 
                     string memory symbol, 
                     address _currency, 
                     address _gemFactory) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
        // genesis plannets: 0 = BTC, 1 = ETH
        validPlannet[0] = true;
        validPlannet[1] = true;
        currency = _currency;
        gemFactory = _gemFactory;
    }

    function setWarriorPrice(uint _price) external onlyOwner {
        WARRIOR_PRICE = _price;
    }

    function setCurrency(address _currency) external onlyOwner {
        currency = _currency;
    }

    function updateMiner(address _miner, bool _allowed) external onlyOwner {
        miners[_miner] = _allowed;
    }

    function setGemFactory(address _gemFactory) external onlyOwner {
        gemFactory = _gemFactory;
    }

    // add more plannet to the pool
    function addPlannet(uint256 _plannetIdx) external onlyOwner {
        validPlannet[_plannetIdx] = true;
    }

    // mint a warrior that is belong to a specific plannet, the rest attribute are random
    function mintByUser(address tokenOwner, uint256 plannet) external returns (uint256) {
        require(validPlannet[plannet], "Invalid plannet value");

        uint256 tokenId = totalSupply();

        if (tokenId >= NUM_GENESIS_WARRIOR) {
            require(miners[msg.sender], "Caller is not miner");
        }

        IERC20(currency).transferFrom(msg.sender, owner(), WARRIOR_PRICE);

        _safeMint(tokenOwner, tokenId);

        numWarriorInPlannet[tokenOwner][plannet] += 1;

        uint32 random = uint32(block.timestamp % 2**32);

        uint256[25] memory att;
        att[0] = plannet;
        // class
        att[1] = random % 10;
        // level
        att[2] = 1;
        // health
        att[3] = 50 + random % 25;
        // defense
        att[4] =  random % 75 + random % 25;
        // power
        att[5] = 60 + random % 40;
        // crit rate
        att[6] = 70 + random % 30;
         // crit damage
        att[7] = 25 + random % 31;

        attributes[tokenId] = att;

        return tokenId;
    }

    // a more convinient function to mint a warrior with deterministic attibutes
    function mint(address tokenOwner, uint256[25] calldata _attribute) external returns (uint256) {
        uint plannet = _attribute[0];
        require(miners[msg.sender], "Caller is not miner");
        require(validPlannet[plannet], "Invalid plannet value");

        uint256 tokenId = totalSupply();

        _safeMint(tokenOwner, tokenId);

        numWarriorInPlannet[tokenOwner][plannet] += 1;

        attributes[tokenId] = _attribute;

        return tokenId;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        uint256 plannet = attributes[tokenId][0];
        require(!isFarming[from][plannet] || numWarriorInPlannet[from][plannet] > 1, "You must withdraw all LP token from Farming first");

        ERC721.safeTransferFrom(from, to, tokenId, "");

        numWarriorInPlannet[from][plannet] = numWarriorInPlannet[from][plannet] - 1;
        numWarriorInPlannet[to][plannet] += 1;
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        uint256 plannet = attributes[tokenId][0];
        require(!isFarming[from][plannet] || numWarriorInPlannet[from][plannet] > 1, "You must withdraw all LP token from Farming first");

        ERC721.transferFrom(from, to, tokenId);

        numWarriorInPlannet[from][plannet] = numWarriorInPlannet[from][plannet] - 1;
        numWarriorInPlannet[to][plannet] += 1;
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint[](0); // Return an empty array
        } else {
            uint[] memory result = new uint[](tokenCount);
            for (uint index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }
}
