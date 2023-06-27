// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ITokenURI {
    function addMember(address memberAddress) external;
    function isValidCoop(address coopAddress) external view returns (bool);
    function create(string memory name, string memory memberType) external pure returns (string memory);
}