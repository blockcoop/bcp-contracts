// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "./ProxyFactory.sol";
import "./interfaces/ICoop.sol";
import "./interfaces/ITokenURI.sol";
import "./libraries/MinimalProxyStore.sol";

contract Factory is ProxyFactory {
    address coopTemplate;
    address tokenURIAddress;
    address accountImplementation;
    address[] public coops;
    mapping(string => bool) existingSymbols;
    mapping(address => bool) validCoops;

    event CoopCreated(address indexed initiator, address coopAddress);
    event RestrictedCoopCreated(address indexed initiator, address coopAddress);
    event AccountCreated(address account, address indexed tokenContract, uint256 indexed tokenId);

    constructor(address _coopTemplate, address _tokenURI, address _accountImplementation) {
        coopTemplate = _coopTemplate;
        tokenURIAddress = _tokenURI;
        accountImplementation = _accountImplementation;
    }

    function createCoop(
        string memory _name,
        string memory _symbol,
        bool _isRestricted,
        uint8 _quorum,
        address _tokenAddress,
        string memory _country
    ) public {
        require(existingSymbols[_symbol] == false, "duplicate symbol");
        existingSymbols[_symbol] = true;
        bytes memory _data = abi.encodeCall(ICoop.initialize, (_name, _symbol, msg.sender, _isRestricted, _quorum, _tokenAddress, _country)); 
        address coop = deployMinimal(coopTemplate, _data);
        coops.push(coop);
        validCoops[coop] = true;
        if(_isRestricted) {
            emit RestrictedCoopCreated(msg.sender, coop);
        } else {
            emit CoopCreated(msg.sender, coop);
        }
    }

    function getCoopCount() public view returns (uint) {
        return coops.length;
    }

    function isValidCoop(address coopAddress) public view returns (bool) {
        return validCoops[coopAddress];
    }

    function getTokenURI(
        string memory name,
        string memory memberType
    ) public view returns (string memory) {
        string memory tokenURI = ITokenURI(tokenURIAddress).create(
            name,
            memberType
        );
        return tokenURI;
    }

    function createAccount(
        address tokenCollection,
        uint256 tokenId
    ) external returns (address) {
        return _createAccount(block.chainid, tokenCollection, tokenId);
    }

    function account(
        address tokenCollection,
        uint256 tokenId
    ) external view returns (address) {
        return _account(block.chainid, tokenCollection, tokenId);
    }

    function _createAccount(
        uint256 chainId,
        address tokenCollection,
        uint256 tokenId
    ) internal returns (address) {
        bytes memory encodedTokenData = abi.encode(
            chainId,
            tokenCollection,
            tokenId
        );
        bytes32 salt = keccak256(encodedTokenData);
        address accountProxy = MinimalProxyStore.cloneDeterministic(
            accountImplementation,
            encodedTokenData,
            salt
        );

        emit AccountCreated(accountProxy, tokenCollection, tokenId);

        return accountProxy;
    }

    function _account(
        uint256 chainId,
        address tokenCollection,
        uint256 tokenId
    ) internal view returns (address) {
        bytes memory encodedTokenData = abi.encode(
            chainId,
            tokenCollection,
            tokenId
        );
        bytes32 salt = keccak256(encodedTokenData);

        address accountProxy = MinimalProxyStore.predictDeterministicAddress(
            accountImplementation,
            encodedTokenData,
            salt
        );

        return accountProxy;
    }
}