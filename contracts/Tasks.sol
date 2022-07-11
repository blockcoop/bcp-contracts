// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./ICoop.sol";

contract Tasks {

    using Counters for Counters.Counter;
    Counters.Counter private _taskCount;

    address manager;
    mapping (uint => Task) tasks;

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

    function createTask(address _creator, address _blockcoop, uint8 _groupId, string memory _details, uint32 _votingDeadline, uint32 _taskDeadline) public {
        require(_votingDeadline > block.timestamp, "invalid voting deadline");
        require(_taskDeadline > _votingDeadline, "invalid task deadline");
        _taskCount.increment();
        Task storage task = tasks[_taskCount.current()];
        task.creator = _creator;
        task.blockcoop = _blockcoop;
        task.groupId = _groupId;
        task.details = _details;
        task.status = TaskStatus.Proposed;
        task.votingDeadline = _votingDeadline;
        task.taskDeadline = _taskDeadline;
        emit TaskCreated(_taskCount.current(), _creator);
    }

    function participate(uint _taskId) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.votingDeadline > block.timestamp, "not allowed");
        require(task.isParticipant[msg.sender] == false, "already participated");
        bool isGroupMember = ICoop(task.blockcoop).isGroupMember(msg.sender, task.groupId);
        require(isGroupMember == true, "not allowed");
        task.isParticipant[msg.sender] = true;
        task.participants.push(msg.sender);
        emit Participated(_taskId, msg.sender);
    }

    function vote(uint _taskId, bool _vote) public {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed, "invalid task status");
        require(task.votes[msg.sender] == Vote.Null, "already voted");
        require(task.votingDeadline >= block.timestamp, "voting closed");

        bool isGroupMember = ICoop(task.blockcoop).isGroupMember(msg.sender, task.groupId);
        require(isGroupMember == true, "not allowed");

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
        require(task.votingDeadline < block.timestamp, "voting not yet closed");
        require(msg.sender == task.creator, "not allowed");

        uint members = ICoop(task.blockcoop).getMemberCount(task.groupId);
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

        bool isModerator = ICoop(task.blockcoop).isModerator(msg.sender, task.groupId);
        require(isModerator == true, "not allowed");

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
        require((task.taskDeadline + 604800) < block.timestamp, "voting not yet closed"); // taskdeadline + 7days
        require(msg.sender == task.creator, "not allowed");

        if(task.yesVotesCompletion > task.noVotesCompletion) {
            task.status = TaskStatus.Completed;
        } else {
            task.status = TaskStatus.Failed;
        }
        emit TaskCompletionProcessed(_taskId, msg.sender, task.status);
    }
}
