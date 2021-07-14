pragma solidity >=0.5.16;

import './libraries/ERC721.sol';
import './libraries/ERC721Enumerable.sol';
import './libraries/ERC721Metadata.sol';
import './libraries/Ownable.sol';

contract NFTWarrior is ERC721, ERC721Enumerable, ERC721Metadata, Ownable {
    enum WarriorState {SLEEPING, WAITING, FIGHTING}

    enum Weapon {NONE, SWORD, SHIELD}

    struct Attribute {
        // num single match and tournament match the NFT has joined
        uint256 singleMatch;
        uint256 tournamentMatch;
        // the address of token this NFT is represent for
        address origin;
        WarriorState state;
    }

    address public router;

    mapping(uint256 => Attribute) public attributes;
    // mapping from lptoken -> user address -> allowed to farm or not
    mapping(address => mapping(address => bool)) public allowedToFarm;

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    function mint(address tokenOwner, address _origin) external returns (uint256) {
        require(msg.sender == router, "NFTWarrior: Forbidden");
        uint256 tokenId = totalSupply();
        _mint(tokenOwner, tokenId);
        attributes[tokenId].origin = _origin;
        allowedToFarm[_origin][tokenOwner] = true;
        return tokenId;
    }

    function burn(uint256 tokenId) external {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    function originOf(uint256 tokenId) external view returns (address origin) {
        return attributes[tokenId].origin;
    }
}
