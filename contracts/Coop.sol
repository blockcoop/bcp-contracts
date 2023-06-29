// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ERC721.sol";
import "./interfaces/IFactory.sol";

contract Coop is ERC721, Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;

    address factoryAddress;
    address public coopInitiator;
    uint8 public status; // 1:PENDING, 2:ACTIVE, 3:CLOSED
    bool public isRestricted;
    uint8 public quorum; // 10 - 100
    uint256 public created;
    string public country;
    mapping(address => uint256) public ownedToken; // owner => tokenId
    address[] private invitedMembers;
    address public tokenAddress;

    event CoopJoined(address indexed member);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, string memory _symbol, address _coopInitiator, bool _isRestricted, uint8 _quorum, address _tokenAddress, string memory _country) initializer public {
        __ERC721_init(_name, _symbol);
        factoryAddress = msg.sender;
        isRestricted = _isRestricted;
        quorum = _quorum;
        tokenAddress = _tokenAddress;
        country = _country;
        created = block.timestamp;
        status = 2;
        
        address account = MintNFT(_coopInitiator, "Creator");
        coopInitiator = account;
        transferOwnership(coopInitiator);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function MintNFT(address member, string memory memberType) private returns (address account) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        string memory _name = name();
        string memory finalTokenUri = IFactory(factoryAddress).getTokenURI(_name, memberType);
        _safeMint(member, newItemId);
        _tokenURIs[newItemId] = finalTokenUri;
        // create token bound account
        account = IFactory(factoryAddress).createAccount(address(this), newItemId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        require(balanceOf(to) == 0, "already a member");
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
        ownedToken[from] = 0;
        ownedToken[to] = tokenId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireMinted(tokenId);
        return _tokenURIs[tokenId];
    }

    function inviteMember(address _member) public onlyOwner {
        require(isRestricted, "invite is not needed");
        require(isMemberInvited(_member) == false, "already invited");
        invitedMembers.push(_member);
    }

    function isMemberInvited(address _member) private view returns (bool) {
        for(uint i = 0; i < invitedMembers.length; i++) {
            if(invitedMembers[i] == _member) {
                return true;
            }
        }
        return false;
    }

    function joinCoop() public payable {
        require(balanceOf(msg.sender) == 0, "already a member");
        if(isRestricted) {
            require(isMemberInvited(msg.sender), "invite needed");
        }
        if(tokenAddress != address(0)) {
            require(IERC20(tokenAddress).balanceOf(msg.sender) > 0, "insufficient tokens");
        }
        address account = MintNFT(msg.sender, "Member");
        emit CoopJoined(account);
    }

    function totalSupply() public view returns (uint) {
        return _tokenIds.current();
    }

    function getAccount(address member) public view returns (address account) {
        uint tokenId = ownedToken[member];
        require(tokenId > 0, "not a member");
        account = IFactory(factoryAddress).account(address(this), tokenId);
    }
}