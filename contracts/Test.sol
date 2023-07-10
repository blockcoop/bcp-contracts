// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ICoop.sol";
import "./interfaces/IGroups.sol";
import "./interfaces/IVoting.sol";

contract Test {
    address factoryAddress;
    address groupsAddress;
    address votingAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _taskCount;

    address constant CURRENCY = 0x6e557F271447FD2aA420cbafCdCD66eCDD5A71A8;

    mapping(uint => Task) tasks;

    enum TaskStatus {
        Invalid, // default
        Proposed,
        Cancelled,
        Started,
        Failed,
        Completed
    }

    struct Task {
        address creator;
        address blockcoop;
        uint8 groupId;
        string title;
        string details;
        string taskType;
        uint participationDeadline;
        uint taskDuration;
        uint taskDeadline;
        address[] participants;
        mapping(address => uint) applicationProposal; // blockcoop address maps to completionProposal
        address[] selectedParticipants;
        uint reward;
        // uint completionProposal;
        mapping(address => bool) rewardClaimed;
        TaskStatus status;
    }

    constructor(address factory, address groups, address voting) {
        factoryAddress = factory;
        groupsAddress = groups;
        votingAddress = voting;
    }

    function createTask(address blockcoop, uint8 groupId, string memory title, string memory taskType, string memory details, uint32 participationDeadline, uint32 taskDuration, uint reward) public returns (uint taskId) {
        require(IFactory(factoryAddress).isValidCoop(blockcoop), "invalid blockcoop");
        address account = ICoop(blockcoop).getAccount(msg.sender);
        require(IGroups(groupsAddress).existsCoopGroup(blockcoop, groupId), "invalid blockcoop group");
        require(participationDeadline > block.timestamp, "invalid participation deadline");
        require(taskDuration > 0, "invalid task duration");

        _taskCount.increment();
        taskId = _taskCount.current();

        Task storage task = tasks[taskId];
        task.creator = account;
        task.blockcoop = blockcoop;
        task.groupId = groupId;
        task.title = title;
        task.taskType = taskType;
        task.details = details;
        task.participationDeadline = participationDeadline;
        task.taskDuration = taskDuration;
        task.reward = reward;
        task.status = TaskStatus.Proposed;

        // emit TaskCreated(taskId, account, blockcoop, groupId);
    }

    function participate(uint taskId, string memory application) public returns (uint proposalId) {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.participationDeadline > block.timestamp, "participation deadline expired");
        address account = ICoop(task.blockcoop).getAccount(msg.sender);
        require(task.applicationProposal[account] == 0, "already applied");
        require(IGroups(groupsAddress).isGroupMember(account, task.groupId), "not allowed");
        string memory title = string(abi.encodePacked('Paricipation for ',task.title));
        proposalId = IVoting(votingAddress).createProposal(msg.sender, task.blockcoop, task.groupId, title, application, block.timestamp + 120, task.participationDeadline);

        task.participants.push(account);
        task.applicationProposal[account] = proposalId;
        // emit Participated(taskId, account);
    }

}