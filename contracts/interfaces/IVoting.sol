// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IVoting {
    function createProposal (address creator, address blockcoop,
        uint8 groupId,
        string memory title,
        string memory details,
        uint startTime,
        uint endTime) external returns (uint proposalId);

    function getProposalStatus(
        uint proposalId
    ) external view returns (uint);

    function vote(uint proposalId, bool _vote) external;
}