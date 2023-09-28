async function main() {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy("0xCe9B9A9df64458622b149F39f61f5a60391638a0", "0x44bdc26f86FD65Ce6Da276C0AbB0EFd31E3Caa51");   
    console.log("Voting Contract deployed to address:", voting.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Voting Address: 0xD8B9451095DC4fa7B1f533300A37f9eFa1d67f04