// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IFactory.sol";

contract Coop is ERC20 {
    address factoryAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _groupCount;

    uint initialMint = 100 ether;

    address public coopInitiator;
    uint32 public votingPeriod;
    uint32 public quorum; // 1-100
    uint32 public supermajority;
    uint8 public status; // 1:PENDING, 2:ACTIVE, 3:CLOSED
    uint32 public created;
    uint public membershipFee;

    mapping(uint => string) groups;
    mapping(address => uint) members;
    mapping(address => uint) moderators;
    mapping(uint => uint) groupMemberCount;
    mapping(uint => uint) groupModeratorCount;

    event CoopJoined(address indexed member, uint groupId);
    event ModeratorAssigned(address indexed member, uint groupId);
    event GroupCreated(string groupName);

    constructor(string memory _name, string memory _symbol, address _coopInitiator, uint32 _votingPeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee) ERC20(_name, _symbol) {
        factoryAddress = msg.sender;
        coopInitiator = _coopInitiator;
        votingPeriod = _votingPeriod;
        quorum = _quorum;
        supermajority = _supermajority;
        membershipFee = _membershipFee;
        status = 2;

        _groupCount.increment();
        groups[_groupCount.current()] = "Default";
        
        members[_coopInitiator] = _groupCount.current();
        groupMemberCount[_groupCount.current()] = 1;

        moderators[_coopInitiator] = _groupCount.current();
        groupModeratorCount[_groupCount.current()] = 1;

        _mint(_coopInitiator, initialMint);
    }

    function createGroup(string memory groupName) public {
        require(msg.sender == coopInitiator, "not allowed");
        _groupCount.increment();
        groups[_groupCount.current()] = groupName;
        emit GroupCreated(groupName);
    }

    function joinCoop(uint groupId) public payable {
        require(_groupCount.current() >= groupId, "invalid group");
        require(members[msg.sender] == 0, "already a member");
        require(msg.value == membershipFee, "invalid membership fee");
        members[msg.sender] = groupId;
        groupMemberCount[groupId] = groupMemberCount[groupId] + 1;
        _mint(msg.sender, initialMint);
        IFactory(factoryAddress).addMember(msg.sender);
        emit CoopJoined(msg.sender, groupId);
    }

    function assignGroupModerator(address member, uint groupId) public {
        require(msg.sender == coopInitiator, "not allowed");
        require(members[member] != groupId, "different group");
        moderators[member] = groupId;
        groupModeratorCount[groupId] = groupModeratorCount[groupId] + 1;
        emit ModeratorAssigned(member, groupId);
    }

    // to check is_member pass groupId = 1
    function isGroupMember(address member, uint groupId) public view returns (bool) {
        if(groupId == 1) {
            if(members[member] == 0) {
                return false;
            } else {
                return true;
            }
        } else {
            if(members[member] == groupId) {
                return true;
            } else {
                return false;
            }    
        }
    } 

    function isModerator(address member, uint groupId) public view returns (bool) {
        if(moderators[member] == groupId) {
            return true;
        } else {
            return false;
        }
    }

    function getMemberCount(uint groupId) public view returns (uint) {
        return groupMemberCount[groupId];
    }

    function getModeratorCount(uint groupId) public view returns (uint) {
        return groupModeratorCount[groupId];
    }
}