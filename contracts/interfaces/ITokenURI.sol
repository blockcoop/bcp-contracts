// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface ITokenURI {
    function create(string memory name, string memory memberType) external pure returns (string memory);
}