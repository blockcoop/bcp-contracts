async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b", "0x9074DFFdA5f957AFaB8b4198Fc22e799B6bC6eA6", "0xa8B8fc4d181E5eE87c1C7075ba08b0c6B9464598");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Tasks Address: 0x63Be59053324De6d48f532520BcAAAD5574C7ca1