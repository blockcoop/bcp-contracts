// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CoopNFT.sol";

contract CoopNFTFactory {
    CoopNFT private coop;
    mapping(string => bool) existingSymbols;
    address[] public coops;
    mapping (address => bool) validCoops;

    function createCoop(string memory _name, string memory _symbol, uint32 _votingPeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee, string memory _country) public {
        require(existingSymbols[_symbol] == false, "duplicate symbol");
        existingSymbols[_symbol] = true;
        coop = new CoopNFT(_name, _symbol, msg.sender, _votingPeriod, _quorum, _supermajority, _membershipFee, _country);
        coops.push(address(coop));
        validCoops[address(coop)] = true;
    }

    function isValidCoop(address coopAddress) public view returns (bool) {
        return validCoops[coopAddress];
    }
}