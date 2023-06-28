// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface ICoop {
    function initialize(address factory, string memory _name, string memory _symbol, address _coopInitiator, bool _isRestricted, uint8 _quorum, address _tokenAddress, string memory _country) external;
    function coopInitiator() external view returns (address);
    function quorum() external view returns (uint8);
    function balanceOf(address) external view returns (uint256);
    function getAccount(address) external view returns (address);
}