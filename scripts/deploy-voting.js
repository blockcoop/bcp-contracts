async function main() {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy("0x3f80F22C01f5923F1047d968f88f10bb5eD88d25", "0x5A8fC85577d4e9A9b5CA51A2f69ECD66A2F80BAb");   
    console.log("Voting Contract deployed to address:", voting.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Voting address : 0x9dE2eCedE5e83e621278a7DC6D16f3142f931b19