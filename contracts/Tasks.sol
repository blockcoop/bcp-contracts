// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ICoop.sol";
import "./interfaces/IGroups.sol";
import "./interfaces/IVoting.sol";

contract Tasks {
    address factoryAddress;
    address groupsAddress;
    address votingAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _taskCount;

    address constant CURRENCY = 0x6e557F271447FD2aA420cbafCdCD66eCDD5A71A8;

    mapping(uint => Task) tasks;

    event TaskCreated(uint taskId, address indexed account, address indexed blockcoop, uint groupId);
    event Participated(uint indexed taskId, address indexed account);

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

        emit TaskCreated(taskId, account, blockcoop, groupId);
    }

    function getTask(uint taskId) public view returns (address creator, address blockcoop, uint8 groupId, string memory title, string memory taskType, string memory details, uint participationDeadline, uint taskDuration, uint taskDeadline, uint reward, TaskStatus status) {
        Task storage task = tasks[taskId];
        creator = task.creator;
        blockcoop = task.blockcoop;
        groupId = task.groupId;
        title = task.title;
        taskType = task.taskType;
        details = task.details;
        participationDeadline = task.participationDeadline;
        taskDuration = task.taskDuration;
        taskDeadline = task.taskDeadline;
        reward = task.reward;
        status = task.status;
    }

    function getParticipants(uint taskId) public view returns (address[] memory) {
        Task storage task = tasks[taskId];
        return task.participants;
    }

    function getSelectedParticipants(uint taskId) public view returns (address[] memory) {
        Task storage task = tasks[taskId];
        return task.selectedParticipants;
    }

    function getApplicationProposal(uint taskId, address applicant) public view returns (uint) {
        Task storage task = tasks[taskId];
        return task.applicationProposal[applicant];
    }

    function isRewardClaimed(uint taskId, address participant) public view returns (bool) {
        Task storage task = tasks[taskId];
        return task.rewardClaimed[participant];
    }

    function participate(uint taskId, string memory application) public {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.participationDeadline > block.timestamp, "participation deadline expired");
        address account = ICoop(task.blockcoop).getAccount(msg.sender);
        require(task.applicationProposal[account] == 0, "already applied");
        require(IGroups(groupsAddress).isGroupMember(account, task.groupId), "not allowed");
        string memory title = string(abi.encodePacked('Paricipation for ',task.title));
        uint proposalId = IVoting(votingAddress).createProposal(msg.sender, task.blockcoop, task.groupId, title, application, block.timestamp + 150, task.participationDeadline);

        task.participants.push(account);
        task.applicationProposal[account] = proposalId;

        emit Participated(taskId, account);
    }

    function processTask(uint taskId) public {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.participationDeadline < block.timestamp, "participation deadline not over");
        uint proposalStatus;
        address account = ICoop(task.blockcoop).getAccount(msg.sender);
        require(task.creator == account, "not allowed");
        if(task.participants.length > 0) {
            for(uint i = 0; i < task.participants.length; i++) {
                proposalStatus = IVoting(votingAddress).getProposalStatus(task.applicationProposal[task.participants[i]]);
                if(proposalStatus == 3) {
                    task.selectedParticipants.push(task.participants[i]);
                }
            }
            if(task.selectedParticipants.length > 0) {
                task.status = TaskStatus.Started;
                task.taskDeadline = block.timestamp + task.taskDuration;
            } else {
                task.status = TaskStatus.Cancelled;
            }
        } else {
            task.status = TaskStatus.Cancelled;
        }
    }

    function createCompletionProposal(uint taskId, string memory details, uint duration) public {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Started, "invalid task status");
        require(task.taskDeadline < block.timestamp, "not yet completed");
        require(task.applicationProposal[task.blockcoop] == 0, "completion proposal already created");
        address account = ICoop(task.blockcoop).getAccount(msg.sender);
        require(task.creator == account, "not allowed");
        string memory title = string(abi.encodePacked('Completion of ',task.title));
        uint proposalId = IVoting(votingAddress).createProposal(msg.sender, task.blockcoop, task.groupId, title, details, block.timestamp + 150, block.timestamp + duration);
        task.applicationProposal[task.blockcoop] = proposalId;
    }

    function processTaskCompletion(uint taskId) public {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Started, "invalid task status");
        require(task.taskDeadline < block.timestamp, "not yet completed");
        require(task.applicationProposal[task.blockcoop] > 0, "completion proposal not yet created");
        address account = ICoop(task.blockcoop).getAccount(msg.sender);
        require(task.creator == account, "not allowed");
        uint proposalStatus = IVoting(votingAddress).getProposalStatus(task.applicationProposal[task.blockcoop]);
        require(proposalStatus != 2, "proposal is still active");
        if(proposalStatus == 3) {
            require(IERC20(CURRENCY).transferFrom(msg.sender, address(this), task.reward), "reward amount failed");
            task.status = TaskStatus.Completed;
        } else {
            task.status = TaskStatus.Failed;
        }
    }

    function claimReward(uint taskId) public {
        Task storage task = tasks[taskId];
        require(task.status == TaskStatus.Completed, "task not completed");
        address account = ICoop(task.blockcoop).getAccount(msg.sender);
        require(inArray(task.selectedParticipants, account), "not allowed");
        require(!task.rewardClaimed[account], "already claimed");
        uint amount = task.reward / task.selectedParticipants.length;
        require(IERC20(CURRENCY).transfer(account, amount), "reward transfer failed");
        task.rewardClaimed[account] = true;
    }

    function inArray(address[] memory heystack, address niddle) private pure returns (bool) {
        for(uint i = 0; i < heystack.length; i++) {
            if(heystack[i] == niddle) {
                return true;
            }
        }
        return false;
    }
}