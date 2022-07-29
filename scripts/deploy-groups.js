async function main() {
    const Groups = await ethers.getContractFactory("Groups");
    const groups = await Groups.deploy("0x2ce6Bf32b724482430178286A60120B6a3FdeEc3");   
    console.log("Groups Contract deployed to address:", groups.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// GroupsAddress: 0x9Ad238728Ee8Fb5416c17f788690252162851aCE