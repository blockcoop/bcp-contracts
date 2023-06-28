// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./interfaces/ITokenURI.sol";
import "./libraries/MinimalProxyStore.sol";
import "./ProxyFactory.sol";
import "./interfaces/ICoop.sol";

contract Factory is ProxyFactory {
    address coopTemplate;
    address accountImplementation;
    address tokenURIAddress;
    mapping(string => bool) existingSymbols;
    address[] public coops;
    mapping(address => bool) validCoops;

    event CoopCreated(address indexed initiator, address coopAddress);
    event AccountCreated(address account, address indexed tokenContract, uint256 indexed tokenId);

    constructor(address _coopTemplate, address _accountImplementation, address _tokenURIAddress) {
        coopTemplate = _coopTemplate;
        accountImplementation = _accountImplementation;
        tokenURIAddress = _tokenURIAddress;
    }

    function getCoopCount() public view returns (uint) {
        return coops.length;
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
        bytes memory _data = abi.encodeCall(ICoop.initialize, (address(this), _name, _symbol, msg.sender, _isRestricted, _quorum, _tokenAddress, _country)); 
        address coop = deployMinimal(coopTemplate, _data);
        coops.push(address(coop));
        validCoops[address(coop)] = true;
        emit CoopCreated(msg.sender, address(coop));
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
