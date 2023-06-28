async function main() {
    const Groups = await ethers.getContractFactory("Groups");
    const groups = await Groups.deploy("0x3f80F22C01f5923F1047d968f88f10bb5eD88d25");   
    console.log("Groups Contract deployed to address:", groups.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Groups address : 0x5A8fC85577d4e9A9b5CA51A2f69ECD66A2F80BAb