// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces_old/IGroups.sol";
import "../interfaces_old/IFactory.sol";

contract MultiSigWallet_old {
    using Counters for Counters.Counter;
    Counters.Counter private _txIds;

    address groupsContract;
    address factoryContract;
    uint public confirmationNeeded; // percent 10-100
    mapping(address => uint) balance;

    struct Transaction {
        address blockCoop;
        address to;
        uint value;
        bool executed;
        uint confirmations;
    }

    mapping(uint => mapping(address => bool)) isConfirmed;
    mapping(uint => Transaction) public transactions;
    mapping(address => uint[]) public coopTransactions;

    modifier onlyModerator(address _blockCoop) {
        require(IGroups(groupsContract).isCoopModerator(_blockCoop, msg.sender), "not moderator");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < _txIds.current(), "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    constructor(address _groupsContract, address _factoryContract, uint _confirmationNeeded) {
        groupsContract = _groupsContract;
        factoryContract = _factoryContract;
        confirmationNeeded = _confirmationNeeded;
    }

    function deposit(uint _amount) public payable {
        require(IFactory(factoryContract).isValidCoop(msg.sender), "invalid blockcoop");
        require(_amount > 0, "invalid amount");
        balance[msg.sender] = balance[msg.sender] + _amount;
    }

    function createTransaction(address _blockcoop, address _to, uint _amount) public onlyModerator(_blockcoop) {
        uint txIndex = _txIds.current();

        transactions[txIndex] = Transaction({
            blockCoop: _blockcoop,
            to: _to,
            value: _amount,
            executed: false,
            confirmations: 0
        });
        coopTransactions[_blockcoop].push(txIndex);
         _txIds.increment();
    }

    function confirmTransaction(uint _txIndex) public txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(IGroups(groupsContract).isCoopModerator(transaction.blockCoop, msg.sender), "not moderator");
        transaction.confirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
    }

    function executeTransaction(uint _txIndex) public txExists(_txIndex) notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require( (transaction.confirmations * 100) >= (confirmationNeeded * IGroups(groupsContract).getCoopModeratorCount(transaction.blockCoop)), "cannot execute tx" );

        transaction.executed = true;

        // (bool success, ) = transaction.to.call{value: transaction.value}(
        //     transaction.data
        // );
        payable(transaction.to).transfer(transaction.value);

    }

    function revokeConfirmation(uint _txIndex) public txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(IGroups(groupsContract).isCoopModerator(transaction.blockCoop, msg.sender), "not moderator");
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
        transaction.confirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;
    }

    function getTransactionCount() public view returns (uint) {
        return _txIds.current() - 1;
    }

    function getTransaction(uint _txIndex) public view returns (address blockcoop, address to, uint value, bool executed, uint confirmations) {
        Transaction storage transaction = transactions[_txIndex];
        return (
            transaction.blockCoop,
            transaction.to,
            transaction.value,
            transaction.executed,
            transaction.confirmations
        );
    }
}