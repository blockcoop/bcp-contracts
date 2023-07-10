const { expect } = require("chai");
const { ethers } = require("hardhat");

require("@nomiclabs/hardhat-waffle");

describe("Test", function() {
    let contract;
    let owner;

    beforeEach(async function () {
        const Test = await ethers.getContractFactory("Test");
        const test = await Test.deploy("0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b", "0x9074DFFdA5f957AFaB8b4198Fc22e799B6bC6eA6", "0x53906C1DebD46428E45Dab339B5e638c18da205c");
        contract = await test.deployed();
    
        [owner] = await ethers.getSigners();
    });

    it("Should add two numbers together and return the sum", async function () {
        const test = await contract.add(1, 5);
        expect(test).to.equal(6);
    });
})