pragma solidity >=0.5.16;

import './libraries/ERC721.sol';
import './libraries/ERC721Enumerable.sol';
import './libraries/ERC721Metadata.sol';
import './libraries/Ownable.sol';

contract DefiWarrior is ERC721, ERC721Enumerable, ERC721Metadata, Ownable {

    address public router;
    address public gemFactory;
    uint32 rangeTribe = 10;

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    function setGemFactoryr(address _gemFactory) external onlyOwner {
        gemFactory = _gemFactory;
    }

    function setRangeTribe(uint32 _value) external onlyOwner {
        rangeTribe = _value;
    }

    function mint(address tokenOwner, address origin) external returns (uint256) {
        require(msg.sender == router, "Defi Warrior: Forbidden");

        uint256 tokenId = totalSupply();

        _safeMint(tokenOwner, tokenId);

        numWarriorInClan[origin][tokenOwner] += 1;

        uint32 random = uint32(block.timestamp % 2**32);

        attributes.push(Attribute({
            singleMatch: 0,
            tournamentMatch: 0,
            origin: origin,
            tribe: random % rangeTribe,
            critRate: random % 100,
            skill: random % 51 + random % 99,
            attack: random % 74 + random % 76
        }));

        return tokenId;
    }

    function startFarming(address user, address lpToken) external {
        require(msg.sender == gemFactory, "Sender must be GemFactory");
        isFarming[user][lpToken] = true;
    }

    function stopFarming(address user, address lpToken) external {
        require(msg.sender == gemFactory, "Sender must be GemFactory");
        isFarming[user][lpToken] = false;
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

    function originOf(uint256 tokenId) external view returns (address origin) {
        return attributes[tokenId].origin;
    }
}
