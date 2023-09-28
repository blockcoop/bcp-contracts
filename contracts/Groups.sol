// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ICoop.sol";

contract Groups {
    using Counters for Counters.Counter;
    Counters.Counter private _groupCount;

    address factoryAddress;
    mapping(address => uint[]) coopGroups;
    mapping(uint => Group) groups;

    event GroupCreated(address indexed coopAddress, address indexed creator, string groupName);
    event GroupJoined(address indexed coopAddress, uint indexed groupId, address indexed creator);
    event GroupModeratorAssigned(address indexed coopAddress, uint indexed groupId, address moderator);

    struct Group {
        string name;
        string description;
        address[] members;
        address[] moderators;
    }

    constructor(address _factoryAddress) {
        factoryAddress = _factoryAddress;
    }

    function createGroup(address blockcoop, string memory name, string memory description) public {
        bool isValidCoop = IFactory(factoryAddress).isValidCoop(blockcoop);
        require(isValidCoop == true, "invalid blockcoop");
        address coopInitiator = ICoop(blockcoop).coopInitiator();
        address account = ICoop(blockcoop).getAccount(msg.sender);
        require(coopInitiator == account, "not allowed");
        _groupCount.increment();
        uint groupId = _groupCount.current();
        address[] memory members;
        address[] memory moderators;
        Group memory group = Group(
            name,
            description,
            members,
            moderators
        );

        groups[groupId] = group;
        coopGroups[blockcoop].push(groupId);

        emit GroupCreated(blockcoop, account, name);
    }

    function joinGroup(address blockcoop, uint groupId) public {
        require(existsCoopGroup(blockcoop, groupId), "invalid blockcoop group");
        require(ICoop(blockcoop).balanceOf(msg.sender) > 0, "not a coop member");
        address account = ICoop(blockcoop).getAccount(msg.sender);
        require(isGroupMember(account, groupId) == false, "already a member");

        Group storage group = groups[groupId];
        group.members.push(account);

        emit GroupJoined(blockcoop, groupId, account);
    }

    function assignModerator(address blockcoop, uint groupId, address moderator) public {
        address account = ICoop(blockcoop).getAccount(msg.sender);
        require(ICoop(blockcoop).coopInitiator() == account, "not allowed");
        require(isGroupMember(moderator, groupId), "not a group member");
        require(!isGroupModerator(moderator, groupId), "already a group moderator");

        Group storage group = groups[groupId];
        group.moderators.push(moderator);

        emit GroupModeratorAssigned(account, groupId, moderator);
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

    function getGroupDetails(uint groupId) public view returns (string memory name, string memory description, address[] memory members, address[] memory moderator) {
        Group memory group = groups[groupId];
        return (group.name, group.description, group.members, group.moderators); 
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