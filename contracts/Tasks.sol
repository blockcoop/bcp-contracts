// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/ICoop.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IGroups.sol";

contract Tasks {
    address factoryAddress;
    address groupsAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _taskCount;

    mapping (uint => Task) tasks;
    mapping (address => uint[]) coopTasks;
    mapping (address => uint[]) createdTasks;
    mapping (address => uint[]) participatedTasks;

    event TaskCreated(uint indexed taskId, address indexed creator);
    event Participated(uint indexed taskId, address participant);
    event Voted(uint indexed taskId, address member);
    event VotedTaskCompletion(uint indexed taskId, address member);
    event TaskVoteProcessed(uint indexed taskId, address creator, TaskStatus status);
    event TaskCompletionProcessed(uint indexed taskId, address creator, TaskStatus status);

    enum Vote {
        Null,
        Yes,
        No
    }

    enum TaskStatus {
        Invalid, // default
        Proposed,
        Voted,
        NotAccepted, // in voting
        Cancelled,
        Started,
        Failed,
        Completed
    }

    struct Task {
        address creator;
        address blockcoop;
        uint8 groupId;
        string details;
        TaskStatus status;
        uint32 votingDeadline;
        uint32 taskDeadline;
        uint yesVotes;
        uint noVotes;
        mapping (address => Vote) votes;
        mapping (address => bool) isParticipant;
        address[] participants;
        uint yesVotesCompletion;
        uint noVotesCompletion;
        mapping (address => Vote) completionVotes;
    }

    constructor(address _factoryAddress, address _groupsAddress) {
        factoryAddress = _factoryAddress;
        groupsAddress = _groupsAddress;
    }

    function createTask(address _blockcoop, uint8 _groupId, string memory _details, uint32 _votingDeadline, uint32 _taskDeadline) public {
        require(IFactory(factoryAddress).isValidCoop(_blockcoop), "invalid blockcoop");
        require(ICoop(_blockcoop).balanceOf(msg.sender) > 0, "not member");
        require(IGroups(groupsAddress).existsCoopGroup(_blockcoop, _groupId), "invalid blockcoop group");
        require(_votingDeadline > block.timestamp, "invalid voting deadline");
        require(_taskDeadline > _votingDeadline, "invalid task deadline");
        _taskCount.increment();
        Task storage task = tasks[_taskCount.current()];
        task.creator = msg.sender;
        task.blockcoop = _blockcoop;
        task.groupId = _groupId;
        task.details = _details;
        task.status = TaskStatus.Proposed;
        task.votingDeadline = _votingDeadline;
        task.taskDeadline = _taskDeadline;
        coopTasks[_blockcoop].push(_taskCount.current());
        createdTasks[msg.sender].push(_taskCount.current());
        emit TaskCreated(_taskCount.current(), msg.sender);
    }

    function participate(uint _taskId) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.votingDeadline > block.timestamp, "not allowed");
        require(task.isParticipant[msg.sender] == false, "already participated");
        require(IGroups(groupsAddress).isGroupMember(msg.sender, task.groupId), "not allowed");
        task.isParticipant[msg.sender] = true;
        task.participants.push(msg.sender);
        participatedTasks[msg.sender].push(_taskId);
        emit Participated(_taskId, msg.sender);
    }

    function vote(uint _taskId, bool _vote) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.votes[msg.sender] == Vote.Null, "already voted");
        require(task.votingDeadline >= block.timestamp, "voting closed");

        require(IGroups(groupsAddress).isGroupMember(msg.sender, task.groupId), "not allowed");

        if(_vote) {
            task.votes[msg.sender] = Vote.Yes;
            task.yesVotes = task.yesVotes + 1;
        } else {
            task.votes[msg.sender] = Vote.No;
            task.noVotes = task.noVotes + 1;
        }
        emit Voted(_taskId, msg.sender);
    }

    function processTaskVoting(uint _taskId) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.votingDeadline < block.timestamp, "voting not yet closed");
        require(msg.sender == task.creator, "not allowed");

        uint members = IGroups(groupsAddress).getGroupMemberCount(task.groupId);
        uint quorum = ICoop(task.blockcoop).quorum();
        uint supermajority = ICoop(task.blockcoop).supermajority();
        uint minVotes = members * quorum / 100;
        
        if((task.yesVotes + task.noVotes) > minVotes) {
            uint minYesVotes = (task.yesVotes + task.noVotes) * supermajority / 100;
            if(task.yesVotes >= minYesVotes) {
                task.status = TaskStatus.Started;
            } else {
                task.status = TaskStatus.Cancelled;
            }
        } else {
            task.status = TaskStatus.NotAccepted;
        }
        emit TaskVoteProcessed(_taskId, msg.sender, task.status);
    }

    function voteTaskCompletion(uint _taskId, bool _vote) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Started, "invalid task status");
        require(task.completionVotes[msg.sender] == Vote.Null, "already voted");
        require(task.taskDeadline < block.timestamp, "task deadline not yet closed");
        require(IGroups(groupsAddress).isGroupModerator(msg.sender, task.groupId), "not allowed");

        if(_vote) {
            task.completionVotes[msg.sender] = Vote.Yes;
            task.yesVotesCompletion = task.yesVotesCompletion + 1;
        } else {
            task.completionVotes[msg.sender] = Vote.No;
            task.noVotesCompletion = task.noVotesCompletion + 1;
        }
        emit VotedTaskCompletion(_taskId, msg.sender);
    }

    function processTaskCompletion(uint _taskId) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Started, "invalid task status");
        require((task.taskDeadline + 604800) < block.timestamp, "voting not yet closed"); // taskdeadline + 7days
        require(msg.sender == task.creator, "not allowed");

        if(task.yesVotesCompletion > task.noVotesCompletion) {
            task.status = TaskStatus.Completed;
        } else {
            task.status = TaskStatus.Failed;
        }
        emit TaskCompletionProcessed(_taskId, msg.sender, task.status);
    }

    function getTask(uint taskId) public view returns (address creator, address blockcoop, uint groupId, string memory details, TaskStatus taskStatus, uint32 votingDeadline, uint32 taskDeadline, address[] memory participants) {
        Task storage task = tasks[taskId];
        creator = task.creator;
        blockcoop = task.blockcoop;
        groupId = task.groupId;
        details = task.details;
        taskStatus = task.status;
        votingDeadline = task.votingDeadline;
        taskDeadline = task.taskDeadline;
        participants = task.participants;
    }

    function getCoopTasks(address _coopAddress) public view returns (uint[] memory) {
        return coopTasks[_coopAddress];
    }

    function getCreatedTasks(address _member) public view returns (uint[] memory) {
        return createdTasks[_member];
    }

    function getParticipatedTasks(address _member) public view returns (uint[] memory) {
        return participatedTasks[_member];
    }

    function isVoted(uint taskId) public view returns (bool) {
        Task storage task = tasks[taskId];
        return task.votes[msg.sender] != Vote.Null;
    }

    function isTaskCompletionVoted(uint taskId) public view returns (bool) {
        Task storage task = tasks[taskId];
        return task.completionVotes[msg.sender] != Vote.Null;
    }
}
