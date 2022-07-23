// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IFactory.sol";

contract Coop is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    bool transferLocked = false;

    address factoryAddress;
    address public coopInitiator;
    uint32 public votingPeriod;
    uint32 public quorum; // 1-100
    uint32 public supermajority;
    uint8 public status; // 1:PENDING, 2:ACTIVE, 3:CLOSED
    uint32 public created;
    uint public membershipFee;

    event CoopJoined(address indexed member);

    constructor(string memory _name, string memory _symbol, address _coopInitiator, uint32 _votingPeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee) ERC721 (_name, _symbol) {
        factoryAddress = msg.sender;
        coopInitiator = _coopInitiator;
        votingPeriod = _votingPeriod;
        quorum = _quorum;
        supermajority = _supermajority;
        membershipFee = _membershipFee;
        status = 2;
        
        MintNFT("Creator");
    }

    function setTransferLocked(bool _locked) private {
        transferLocked = _locked;
    }

    function MintNFT(string memory memberType) private {
        uint256 newItemId = _tokenIds.current();
        string memory finalTokenUri = IFactory(factoryAddress).getTokenURI(name(), memberType);

        setTransferLocked(false);
        _safeMint(msg.sender, newItemId);
        setTransferLocked(true);
        _setTokenURI(newItemId, finalTokenUri);
        _tokenIds.increment();
    }

    function joinCoop() public payable {
        require(balanceOf(msg.sender) == 0, "already a member");
        require(msg.value == membershipFee, "invalid membership fee");
        MintNFT("Member");
        IFactory(factoryAddress).addMember(msg.sender);
        emit CoopJoined(msg.sender);
    }
}