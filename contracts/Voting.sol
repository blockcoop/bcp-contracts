// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ICoop.sol";
import "./interfaces/IGroups.sol";

contract Voting {
    address factoryAddress;
    address groupsAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _proposalCount;

    mapping(uint => Proposal) proposals;
    mapping(address => uint[]) coopProposals;

    event ProposalCreated(
        uint proposalId,
        address indexed blockcoop,
        uint indexed group,
        address indexed creator
    );

    event Voted(uint proposalId, address indexed account);
    event ProposalProcessed(uint indexed proposalId, ProposalStatus status);

    enum Vote {
        Null,
        Yes,
        No
    }

    enum ProposalStatus {
        Invalid, // default
        Proposed,
        Active,
        Passed,
        Failed,
        Pending
    }

    struct Proposal {
        address creator;
        address blockcoop;
        uint8 groupId;
        string title;
        string details;
        uint startTime;
        uint endTime;
        uint yesVotes;
        uint noVotes;
        ProposalStatus status;
        mapping(address => Vote) votes;
    }

    constructor(address _factoryAddress, address _groupsAddress) {
        factoryAddress = _factoryAddress;
        groupsAddress = _groupsAddress;
    }

    function createProposal(
        address creator,
        address blockcoop,
        uint8 groupId,
        string memory title,
        string memory details,
        uint startTime,
        uint endTime
    ) public returns (uint proposalId) {
        require(
            IFactory(factoryAddress).isValidCoop(blockcoop),
            "invalid blockcoop"
        );
        address account = ICoop(blockcoop).getAccount(creator);
        require(
            IGroups(groupsAddress).existsCoopGroup(blockcoop, groupId),
            "invalid blockcoop group"
        );
        require(startTime > block.timestamp, "invalid voting start time");
        require(endTime > startTime, "invalid voting start time");
        _proposalCount.increment();

        proposalId = _proposalCount.current();

        Proposal storage proposal = proposals[proposalId];
        proposal.creator = account;
        proposal.blockcoop = blockcoop;
        proposal.groupId = groupId;
        proposal.title = title;
        proposal.details = details;
        proposal.startTime = startTime;
        proposal.endTime = endTime;
        proposal.status = ProposalStatus.Pending;

        coopProposals[blockcoop].push(proposalId);

        emit ProposalCreated(proposalId, blockcoop, groupId, account);
    }

    function getProposalStatus(
        uint proposalId
    ) public view returns (ProposalStatus) {
        if (proposalId == 0 || proposalId > _proposalCount.current()) {
            return ProposalStatus.Invalid;
        }
        Proposal storage proposal = proposals[proposalId];
        if (proposal.startTime > block.timestamp) {
            return ProposalStatus.Proposed;
        }
        if (proposal.endTime > block.timestamp) {
            return ProposalStatus.Active;
        }
        
        return proposal.status;
    }

    function processProposal(uint proposalId) public returns(ProposalStatus) {
        Proposal storage proposal = proposals[proposalId];
        address account = ICoop(proposal.blockcoop).getAccount(msg.sender);
        require(account == proposal.creator, "not allowed");
        ProposalStatus status = getProposalStatus(proposalId);
        require(status == ProposalStatus.Pending, "invalid status");

        uint8 quorum = ICoop(proposal.blockcoop).quorum();
        uint memberCount = IGroups(groupsAddress).getGroupMemberCount(
            proposal.groupId
        );
        if (
            (proposal.yesVotes + proposal.noVotes) <
            ((quorum * memberCount) / 100)
        ) {
            proposal.status = ProposalStatus.Failed;
        }
        if (proposal.yesVotes > proposal.noVotes) {
            proposal.status = ProposalStatus.Passed;
        } else {
            proposal.status = ProposalStatus.Failed;
        }
        
        emit ProposalProcessed(proposalId, proposal.status);
        return proposal.status;
    }

    function vote(uint proposalId, bool _vote) public {
        Proposal storage proposal = proposals[proposalId];
        require(
            proposal.startTime < block.timestamp &&
                proposal.endTime > block.timestamp,
            "proposal not active"
        );
        address account = ICoop(proposal.blockcoop).getAccount(msg.sender);
        require(proposal.votes[account] == Vote.Null, "already voted");

        require(
            IGroups(groupsAddress).isGroupMember(account, proposal.groupId),
            "not allowed"
        );

        if (_vote) {
            proposal.votes[account] = Vote.Yes;
            proposal.yesVotes = proposal.yesVotes + 1;
        } else {
            proposal.votes[account] = Vote.No;
            proposal.noVotes = proposal.noVotes + 1;
        }

        emit Voted(proposalId, account);
    }

    function getProposal(uint proposalId) public view returns (address creator, address blockcoop, uint8 groupId, string memory title, string memory details, uint startTime, uint endTime, uint yesVotes, uint noVotes) {
        Proposal storage proposal = proposals[proposalId];
        creator = proposal.creator;
        blockcoop = proposal.blockcoop;
        groupId = proposal.groupId;
        title = proposal.title;
        details = proposal.details;
        startTime = proposal.startTime;
        endTime = proposal.endTime;
        yesVotes = proposal.yesVotes;
        noVotes = proposal.noVotes;
    }

    function getCoopProposals(address coopAddress) public view returns (uint[] memory) {
        return coopProposals[coopAddress];
    }

    function isVoted(uint proposalId) public view returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        address account = ICoop(proposal.blockcoop).getAccount(msg.sender);
        return proposal.votes[account] != Vote.Null;
    }
}
