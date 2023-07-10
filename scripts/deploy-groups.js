async function main() {
    const Groups = await ethers.getContractFactory("Groups");
    const groups = await Groups.deploy("0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b");   
    console.log("Factory Contract deployed to address:", groups.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Groups Address: 0x9074DFFdA5f957AFaB8b4198Fc22e799B6bC6eA6