pragma solidity >=0.5.16;

import './libraries/ERC721.sol';
import './libraries/ERC721Enumerable.sol';
import './libraries/ERC721Metadata.sol';
import './libraries/Ownable.sol';

contract BodyPart is ERC721, ERC721Enumerable, ERC721Metadata, Ownable {

    enum BodyType {
        Eye,
        Leg,
        Foot,
        Arm,
        Hand,
        Ear,
        Hair,
        Hat,
        Body,
        Nose,
        Cheek,
        Chest,
        Eyebrown,
        Teeth
    }

    // list of addresses that are able to mint new character
    mapping(address => bool) miners;

    mapping(uint => uint[10]) attributes;
    // 0 = type
    // 1 = rarity
    // 2 = skillId
    // 3 - 9: reseverd

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {}

    function updateMiner(address _miner, bool _allowed) external onlyOwner {
        miners[_miner] = _allowed;
    }

    function mint(address _to, uint _skillId, uint _rarity, uint _bodyType) external {
        require(miners[msg.sender], "caller is not miner");
        require(_bodyType <= 13, "Invalid body type");
        uint256 tokenId = totalSupply();
        _safeMint(_to, tokenId);

        uint256[10] memory att;
        att[0] = _bodyType;
        att[1] = _rarity;
        att[2] = _skillId;

        attributes[tokenId] = att;
    }

    function getBodyAttribute(uint tokenId) external view returns(uint[10] memory) {
        return attributes[tokenId];
    }

    function getBodyAttributes(uint256[] calldata ids) external view returns(uint256[10][] memory) {
        uint256[10][] memory atts = new uint256[10][](ids.length);
        for(uint i = 0; i < ids.length; i++) {
            atts[i] = attributes[ids[i]];
        }
        return atts;
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