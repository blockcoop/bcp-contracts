async function main() {
    const Groups = await ethers.getContractFactory("Groups");
    const groups = await Groups.deploy("0xCe9B9A9df64458622b149F39f61f5a60391638a0");   
    console.log("Factory Contract deployed to address:", groups.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Groups Address: 0x44bdc26f86FD65Ce6Da276C0AbB0EFd31E3Caa51