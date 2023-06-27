// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IGroups {
    function existsCoopGroup(address, uint) external view returns (bool);
    function isGroupMember(address, uint) external view returns (bool);
    function isGroupModerator(address, uint) external view returns (bool);
    function getCoopGroups(address) external view returns (uint[] memory);
    function getGroupDetails(uint) external view returns (string memory, address[] memory, address[] memory);
    function getGroupMemberCount(uint) external view returns (uint);
    function getGroupModeratorCount(uint) external view returns (uint);
    function isCoopModerator(address blockcoop, address member) external view returns (bool);
    function getCoopModeratorCount(address blockcoop) external view returns (uint);
}