async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0xCe9B9A9df64458622b149F39f61f5a60391638a0", "0x44bdc26f86FD65Ce6Da276C0AbB0EFd31E3Caa51", "0xD8B9451095DC4fa7B1f533300A37f9eFa1d67f04");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Tasks Address: 0xa1086Ff332960C80A2A72F7296437b114D096BEe