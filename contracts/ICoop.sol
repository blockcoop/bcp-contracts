// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ICoop {
    function coopInitiator() external view returns (address);
    function votingPeriod() external view returns (uint32);
    function quorum() external view returns (uint32);
    function supermajority() external view returns (uint32);

    // to check is_member pass groupId = 1
    function isGroupMember(address member, uint groupId) external view returns (bool);
    function isModerator(address member, uint groupId) external view returns (bool);
    function getMemberCount(uint groupId) external view returns (uint);
    function getModeratorCount(uint groupId) external view returns (uint);
}