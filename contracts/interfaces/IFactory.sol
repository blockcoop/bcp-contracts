// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IFactory {
    function isValidCoop(address coopAddress) external view returns (bool);

    function getTokenURI(
        string memory name,
        string memory memberType
    ) external returns (string memory);

    function createAccount(
        address tokenContract,
        uint256 tokenId
    ) external returns (address);

    function account(
        address tokenContract,
        uint256 tokenId
    ) external view returns (address);
}
