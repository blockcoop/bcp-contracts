// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces_old/IFactory.sol";
import "../interfaces_old/IMultiSigWallet.sol";

contract Coop_Old is ERC721URIStorage {
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
    string public country;

    event CoopJoined(address indexed member);

    constructor(string memory _name, string memory _symbol, address _coopInitiator, uint32 _votingPeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee, string memory _country) ERC721 (_name, _symbol) {
        factoryAddress = msg.sender;
        coopInitiator = _coopInitiator;
        votingPeriod = _votingPeriod;
        quorum = _quorum;
        supermajority = _supermajority;
        membershipFee = _membershipFee;
        country = _country;
        status = 2;
        
        MintNFT(_coopInitiator, "Creator");
    }

    function setTransferLocked(bool _locked) private {
        transferLocked = _locked;
    }

    function MintNFT(address member, string memory memberType) private {
        uint256 newItemId = _tokenIds.current();
        string memory _name = name();
        string memory finalTokenUri = IFactory(factoryAddress).getTokenURI(_name, memberType);
        // string memory finalTokenUri = "0xa8da7eB9ED0629dE63cA5D7150a74e1AFbEfAac0";

        setTransferLocked(false);
        _safeMint(member, newItemId);
        setTransferLocked(true);
        _setTokenURI(newItemId, finalTokenUri);
        _tokenIds.increment();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(!transferLocked, "not allowed");
    }

    function joinCoop() public payable {
        require(balanceOf(msg.sender) == 0, "already a member");
        require(msg.value == membershipFee, "invalid membership fee");
        MintNFT(msg.sender, "Member");
        IFactory(factoryAddress).addMember(msg.sender);
        if(msg.value > 0) {
            IMultiSigWallet(IFactory(factoryAddress).walletAddress()).deposit(msg.value);
        }
        emit CoopJoined(msg.sender);
    }

    function getCoopSize() public view returns (uint) {
        return _tokenIds.current();
    }
}