// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IFactory {
    function addMember(address memberAddress) external;
    function isValidCoop(address coopAddress) external view returns (bool);
}