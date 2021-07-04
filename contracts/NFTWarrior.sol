pragma solidity >=0.5.16;

import './libraries/ERC721.sol';
import './libraries/ERC721Enumerable.sol';
import './libraries/ERC721Metadata.sol';
import './libraries/Ownable.sol';

contract NFTWarriror is ERC721, ERC721Enumerable, ERC721Metadata, Ownable {
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

    mapping(uint256 => Attribute) public attributes;

    function mint(address tokenOwner, address _origin) external onlyOwner returns (uint256) {
        uint256 tokenId = totalSupply();
        _mint(tokenOwner, tokenId);
        attributes[tokenId].origin = _origin;
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
