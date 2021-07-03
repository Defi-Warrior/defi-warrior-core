pragma solidity >= 0.5.16;

interface ERC165 {
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
