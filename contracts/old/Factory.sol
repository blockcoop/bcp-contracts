// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Coop.sol";
import "../interfaces_old/ITokenURI.sol";

contract Factory_old {
    address tokenURIAddress;
    address public walletAddress;
    address owner;
    Coop_Old private coop;
    mapping(string => bool) existingSymbols;
    address[] public coops;
    mapping (address => address[]) intiatorCoops;
    mapping (address => address[]) memberCoops;
    mapping (address => bool) validCoops;

    event CoopCreated(address indexed initiator, address coopAddress);

    constructor(address _tokenURIAddress) {
        owner = msg.sender;
        tokenURIAddress = _tokenURIAddress;
    }

    function getCoopCount() public view returns (uint) {
        return coops.length;
    }

    function getCoopsByCreator(address _initiator) public view returns (address[] memory) {
        return intiatorCoops[_initiator];
    }

    function getCoopsByMember(address _memberAddress) public view returns (address[] memory) {
        return memberCoops[_memberAddress];
    }

    function setWalletAddress(address _walletAddress) public {
        require(owner == msg.sender, "not allowed");
        walletAddress = _walletAddress;
    }

    function createCoop(string memory _name, string memory _symbol, uint32 _votingPeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee, string memory _country) public {
        require(existingSymbols[_symbol] == false, "duplicate symbol");
        existingSymbols[_symbol] = true;
        coop = new Coop_Old(_name, _symbol, msg.sender, _votingPeriod, _quorum, _supermajority, _membershipFee, _country);
        coops.push(address(coop));
        intiatorCoops[msg.sender].push(address(coop));
        memberCoops[msg.sender].push(address(coop));
        validCoops[address(coop)] = true;
        emit CoopCreated(msg.sender, address(coop));
    }

    function addMember(address memberAddress) public {
        require(validCoops[msg.sender], "not allowed");
        memberCoops[memberAddress].push(msg.sender);
    }

    function isValidCoop(address coopAddress) public view returns (bool) {
        return validCoops[coopAddress];
    }

    function getTokenURI(string memory name, string memory memberType) public view returns (string memory) {
        string memory tokenURI = ITokenURI(tokenURIAddress).create(name, memberType);
        return tokenURI;
    }
}