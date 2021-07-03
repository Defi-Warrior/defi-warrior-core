pragma solidity >= 0.5.16;

import './ERC721Base.sol';
import './ERC721Enumerable.sol';
import './ERC721Metadata.sol';
import '../libraries/Ownable.sol';

contract NFTWarriror is ERC721Base, ERC721Enumerable, ERC721Metadata, Ownable {

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

  constructor() public {
  }

  /**
   * @dev Method to check if an asset identified by the given id exists under this DAR.
   * @return uint256 the assetId
   */
  function exists(uint256 assetId) external view returns (bool) {
    return _exists(assetId);
  }

  function _exists(uint256 assetId) internal view returns (bool) {
    return _holderOf[assetId] != address(0);
  }

  function decimals() external pure returns (uint256) {
    return 0;
  }

  function mint(address tokenOwner, address _origin) onlyOwner external returns (uint256) {
    uint totalSupply = _totalSupply();
    _generate(totalSupply, tokenOwner);
    attributes[totalSupply].origin = _origin;
    return totalSupply;
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
      require(_exists(tokenId), "ERC721: operator query for nonexistent token");
      address tokenOwner = _ownerOf(tokenId);
      return (spender == tokenOwner || _getApprovedAddress(tokenId) == spender || _isApprovedForAll(tokenOwner, spender));
  }

  function burn(uint256 tokenId) public {
      require(_isApprovedOrOwner(msg.sender, tokenId));
      _destroy(tokenId);
  }

  function originOf(uint256 tokenId) external view returns (address origin) {
      return attributes[tokenId].origin;
  }

}
