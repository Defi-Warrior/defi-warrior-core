pragma solidity >=0.5.16;
pragma experimental ABIEncoderV2;


import './libraries/ERC721.sol';
import './libraries/ERC721Enumerable.sol';
import './libraries/ERC721Metadata.sol';
import './libraries/Ownable.sol';

contract DefiWarrior is ERC721, ERC721Enumerable, ERC721Metadata, Ownable {

    address public router;
    address public gemFactory;

    uint256 maxTribe = 5;
    
    mapping(uint => bool) validPlannet;

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
        // genesis plannets
        validPlannet[0] = true;
        validPlannet[1] = true;
        validPlannet[2] = true;
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    function setGemFactory(address _gemFactory) external onlyOwner {
        gemFactory = _gemFactory;
    }

    function setMaxTribe(uint256 _maxTribe) external onlyOwner {
        maxTribe = _maxTribe;
    }

    function updatePlannet(uint256 _plannetIdx, bool _allowed) external onlyOwner {
        validPlannet[_plannetIdx] = _allowed;
    }

    function mint(address tokenOwner, uint256 plannet) external returns (uint256) {
        require(msg.sender == router, "Defi Warrior: Forbidden");
        require(validPlannet[plannet], "Invalid plannet value");

        uint256 tokenId = totalSupply();

        _safeMint(tokenOwner, tokenId);

        numWarriorInClan[tokenOwner][plannet] += 1;

        uint32 random = uint32(block.timestamp % 2**32);

        attributes.push(Attribute({
            plannet: plannet,
            tribe: random % maxTribe,
            health: 100 + random % 50,
            critRate: 50 + random % 25,
            critMultiplier: 150 + random % 50,
            skill: random % 51 + random % 99,
            attack: random % 74 + random % 76
        }));

        return tokenId;
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

    function burn(uint256 tokenId) external {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    function getWarriors(uint256[] calldata ids) external view returns(Attribute[] memory) {
        Attribute[] memory atts = new Attribute[](ids.length);
        for(uint i = 0; i < ids.length; i++) {
            atts[i] = attributes[ids[i]];
        }
        return atts;
    }
}
