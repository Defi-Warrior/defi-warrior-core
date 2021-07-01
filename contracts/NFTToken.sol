// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libraries/Ownable.sol";
import "./interfaces/ERC721.sol";
import "./interfaces/ERC721EnumerableSimple.sol";


enum WarriorState {SLEEPING, WAITING, FIGHTING}

enum Weapon {NONE, SWORD, SHIELD}

interface IWarrior {
    function deposit(uint256 amount, uint256 matchId) external;
    function fight() external;
    function claimReward() external;
}
struct Attribute {
    // num single match and tournament match the NFT has joined
    uint256 singleMatch;
    uint256 tournamentMatch;
    // the address of token this NFT is represent for
    address origin;
    WarriorState state;
}

contract NFTToken is ERC721EnumerableSimple, Ownable {
    // Maximum amount of NFTToken in existance. Ever.
    // uint public constant MAX_NFTTOKEN_SUPPLY = 10000;

    // The provenance hash of all NFTToken. (Root hash of all NFTToken hashes concatenated)
    string public constant METADATA_PROVENANCE_HASH =
        "F5E8F9752F537EB428B0DC3A3A0F6B3646417E6FBD79AEC314D19D41AC48AF25";

    // Bsae URI of NFTToken's metadata
    string private baseURI;

    // Mapping token ID to its external attributes
    mapping (uint256 => Attribute) public attriubtes;

    constructor() ERC721("Defi Warriror", "FIWA") {}

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

    function mint(address owner, address _origin) public onlyOwner {
        uint _totalSupply = totalSupply();
        _safeMint(owner, _totalSupply);
        attriubtes[_totalSupply].origin = _origin;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory __baseURI) public onlyOwner {
        baseURI = __baseURI;
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _burn(tokenId);
    }
}
