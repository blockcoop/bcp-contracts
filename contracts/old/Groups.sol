// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces_old/IFactory.sol";
import "../interfaces_old/ICoop.sol";

contract Groups_old {
    using Counters for Counters.Counter;
    Counters.Counter private _groupCount;

    address factoryAddress;
    mapping(address => uint[]) coopGroups;
    mapping(uint => Group) groups;

    event GroupCreated(address indexed coopAddress, address indexed creator, string groupName);
    event GroupJoined(address indexed creator, uint indexed groupId);
    event GroupModeratorAssigned(address indexed coopAddress, uint indexed groupId, address moderator);

    struct Group {
        string name;
        address[] members;
        address[] moderators;
    }

    constructor(address _factoryAddress) {
        factoryAddress = _factoryAddress;
    }

    function createGroup(address blockcoop, string memory name) public {
        bool isValidCoop = IFactory(factoryAddress).isValidCoop(blockcoop);
        require(isValidCoop == true, "invalid blockcoop");
        address coopInitiator = ICoop(blockcoop).coopInitiator();
        require(coopInitiator == msg.sender, "not allowed");
        _groupCount.increment();
        address[] memory members;
        address[] memory moderators;
        Group memory group = Group(
            name,
            members,
            moderators
        );

        groups[_groupCount.current()] = group;
        coopGroups[blockcoop].push(_groupCount.current());

        emit GroupCreated(blockcoop, msg.sender, name);
    }

    function joinGroup(address blockcoop, uint groupId) public {
        require(_groupCount.current() >= groupId, "invalid group");
        require(existsCoopGroup(blockcoop, groupId), "invalid blockcoop group");
        require(ICoop(blockcoop).balanceOf(msg.sender) > 0, "not a coop member");
        require(isGroupMember(msg.sender, groupId) == false, "already a member");

        Group storage group = groups[groupId];
        group.members.push(msg.sender);

        emit GroupJoined(msg.sender, groupId);
    }

    function assignModerator(address blockcoop, uint groupId, address moderator) public {
        require(ICoop(blockcoop).coopInitiator() == msg.sender, "not allowed");
        require(isGroupMember(moderator, groupId), "not a group member");
        require(!isGroupModerator(moderator, groupId), "already a group moderator");

        Group storage group = groups[groupId];
        group.moderators.push(moderator);

        emit GroupModeratorAssigned(msg.sender, groupId, moderator);
    }

    function existsCoopGroup(address blockcoop, uint groupId) public view returns (bool) {
        for (uint i = 0; i < coopGroups[blockcoop].length; i++) {
            if (coopGroups[blockcoop][i] == groupId) {
                return true;
            }
        }
        return false;
    }

    function isGroupMember(address member, uint groupId) public view returns (bool) {
        address[] memory members = groups[groupId].members;
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == member) {
                return true;
            }
        }
        return false;
    }

    function isGroupModerator(address member, uint groupId) public view returns (bool) {
        address[] memory moderators = groups[groupId].moderators;
        for (uint i = 0; i < moderators.length; i++) {
            if (moderators[i] == member) {
                return true;
            }
        }
        return false;
    }

    function getCoopGroups(address blockcoop) public view returns (uint[] memory) {
        return coopGroups[blockcoop];
    }

    function getGroupDetails(uint groupId) public view returns (string memory name, address[] memory members, address[] memory moderator) {
        Group memory group = groups[groupId];
        return (group.name, group.members, group.moderators); 
    }

    function getGroupMemberCount(uint groupId) public view returns (uint) {
        Group memory group = groups[groupId];
        return group.members.length;
    }

    function getGroupModeratorCount(uint groupId) public view returns (uint) {
        Group memory group = groups[groupId];
        return group.moderators.length;
    }

    function isCoopModerator(address blockcoop, address member) public view returns (bool) {
        uint[] memory groupIds = coopGroups[blockcoop];
        for (uint i = 0; i < groupIds.length; i++) {
            bool isModerator = isGroupModerator(member, groupIds[i]);
            if (isModerator) {
                return true;
            }
        }
        return false;
    }

    function getCoopModeratorCount(address blockcoop) public view returns (uint) {
        uint[] memory groupIds = coopGroups[blockcoop];
        uint count = 0;
        for (uint i = 0; i < groupIds.length; i++) {
            count = count + getGroupModeratorCount(groupIds[i]);
        }
        return count;
    }
}