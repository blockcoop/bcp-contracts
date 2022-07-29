async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0x2ce6Bf32b724482430178286A60120B6a3FdeEc3", "0x9Ad238728Ee8Fb5416c17f788690252162851aCE");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// TasksAddress: 0x3Ac7082d71F779d08e661Beb283C1cCDE2812919