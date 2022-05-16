// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BlockCoop.sol";

contract CoopFactory is Ownable {
    BlockCoop private coop;
    mapping(string => bool) existingSymbols;
    address[] public coops;
    mapping (address => address[]) coopCreators;

    event CoopCreated(address indexed initiator, address coopAddress);

    function getCoopCount() public view returns (uint) {
        return coops.length;
    }

    function getCoopsByCreators(address _initiator) public view returns (address[] memory) {
        return coopCreators[_initiator];
    }

    function createCoop(string memory _name, string memory _symbol, uint32 _votingPeriod, uint32 _gracePeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee) public {
        require(existingSymbols[_symbol] == false, "duplicate symbol");
        existingSymbols[_symbol] = true;
        coop = new BlockCoop(_name, _symbol, msg.sender, _votingPeriod, _gracePeriod, _quorum, _supermajority, _membershipFee);
        coops.push(address(coop));

        emit CoopCreated(msg.sender, address(coop));
    }
}