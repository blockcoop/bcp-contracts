async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b", "0x9074DFFdA5f957AFaB8b4198Fc22e799B6bC6eA6", "0x53906C1DebD46428E45Dab339B5e638c18da205c");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Tasks Address: 0xc0718a66ca6ec3c813B3F9A6444d3090b595C572