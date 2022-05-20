// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ICoopFactory.sol";
// import "./CoopToken.sol";

contract BlockCoop  is ERC20 {
    address factoryAddress;
    address public coopInitiator;
    uint32 public votingPeriod;
    uint32 public gracePeriod;
    uint32 public quorum; // 1-100
    uint32 public supermajority;
    uint8 public status; // 1:PENDING, 2:ACTIVE, 3:CLOSED
    uint32 public created;
    uint public membershipFee;

    using Counters for Counters.Counter;
    Counters.Counter private _taskCount;

    uint initialMint = 100 ether;

    mapping (address => uint) shares; // memberAddress => shares
    address[] members;
    mapping (uint => Task) tasks;

    event CoopJoined(address indexed member);
    event TaskCreated(uint indexed taskId, address indexed creator);
    event Participated(uint indexed taskId, address participant);
    event Voted(uint indexed taskId, address member);
    event TaskStatusUpdated(uint indexed taskId, TaskStatus status);
    event StatusUpdated(uint8 status);

    enum Vote {
        Null,
        Yes,
        No
    }

    enum TaskStatus {
        Proposed,
        Voted,
        Cancelled,
        Started,
        Failed,
        Completed
    }

    struct Task {
        address creator;
        string details;
        TaskStatus status;
        uint32 VotingDeadline;
        uint32 taskDeadline;
        uint yesVotes;
        uint noVotes;
        mapping (address => Vote) votes;
        mapping (address => bool) isParticipants;
        address[] participants;
    }

    constructor(string memory _name, string memory _symbol, address _coopInitiator, uint32 _votingPeriod, uint32 _gracePeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee) ERC20(_name, _symbol) {
        factoryAddress = msg.sender;
        coopInitiator = _coopInitiator;
        votingPeriod = _votingPeriod;
        gracePeriod = _gracePeriod;
        quorum = _quorum;
        supermajority = _supermajority;
        membershipFee = _membershipFee;

        shares[_coopInitiator] = initialMint;
        members.push(_coopInitiator);
        _mint(_coopInitiator, initialMint);
    }

    modifier onlyMember {
        require(shares[msg.sender] > 0, "not a member");
        _;
    }

    function joinCoop() public payable {
        require(shares[msg.sender] == 0, "already a member");
        require(msg.value == membershipFee, "invalid membership fee");
        shares[msg.sender] = initialMint;
        members.push(msg.sender);
        ICoopFactory(factoryAddress).addMember(msg.sender);
        _mint(msg.sender, initialMint);
    }

    function createTask(string memory _details, uint32 _votingDeadline, uint32 _taskDeadline) public onlyMember {
        require(_votingDeadline > block.timestamp, "invalid voting deadline");
        require(_taskDeadline > _votingDeadline, "invalid task deadline");
        _taskCount.increment();
        Task storage task = tasks[_taskCount.current()];
        task.creator = msg.sender;
        task.details = _details;
        task.status = TaskStatus.Proposed;
        task.VotingDeadline = _votingDeadline;
        task.taskDeadline = _taskDeadline;
    }

    function getTaskCount() public view returns (uint) {
        return _taskCount.current();
    }

    modifier taskExists(uint _taskId) {
        require(_taskId <= getTaskCount(), "task invalid");
        _;
    }

    function participate(uint _taskId) public taskExists(_taskId) {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed, "cannot participate");
        require(task.isParticipants[msg.sender] == false, "already participated");
        task.isParticipants[msg.sender] = true;
        task.participants.push(msg.sender);
    }

    function vote(uint _taskId, bool _vote) public onlyMember taskExists(_taskId) {
        Task storage task = tasks[_taskId];
        require(task.status == TaskStatus.Proposed);
        require(task.votes[msg.sender] == Vote.Null, "already voted");
        require(task.VotingDeadline >= block.timestamp, "voting closed");
        if(_vote) {
            task.votes[msg.sender] = Vote.Yes;
            task.yesVotes = task.yesVotes + 1;
        } else {
            task.votes[msg.sender] = Vote.No;
            task.noVotes = task.noVotes + 1;
        }
    }

    function getMembers() public view returns (address[] memory) {
        return members;
    }

    function getTask(uint _taskId) public view returns (address creator, string memory details, TaskStatus taskStatus, uint32 votingDeadline, uint32 taskDeadline, address[] memory participants) {
        Task storage task = tasks[_taskId];
        creator = task.creator;
        details = task.details;
        taskStatus = task.status;
        votingDeadline = task.VotingDeadline;
        taskDeadline = task.taskDeadline;
        participants = task.participants;
    }

}

