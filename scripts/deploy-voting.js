async function main() {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy("0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b", "0x9074DFFdA5f957AFaB8b4198Fc22e799B6bC6eA6");   
    console.log("Voting Contract deployed to address:", voting.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Voting Address: 0x53906C1DebD46428E45Dab339B5e638c18da205c