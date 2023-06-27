// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ICoop {
    function coopInitiator() external view returns (address);
    function votingPeriod() external view returns (uint32);
    function quorum() external view returns (uint32);
    function supermajority() external view returns (uint32);

    function balanceOf(address) external view returns (uint256);
}