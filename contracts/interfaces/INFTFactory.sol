// SPDX-License-Identifier: MIT

pragma solidity >= 0.5.16;


interface INFTFactory {
    function mint(address owner, address _origin) external returns (uint256);

    function burn(uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function originOf(uint256 tokenId) external view returns (address origin);

    function allowedToFarm(address, address) external view returns (bool allowed);
}