async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0x3f80F22C01f5923F1047d968f88f10bb5eD88d25", "0x5A8fC85577d4e9A9b5CA51A2f69ECD66A2F80BAb", "0x9dE2eCedE5e83e621278a7DC6D16f3142f931b19");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Tasks address : 0xf83dF2DF9DC5F9E08DF7b2530f3c811ad659b1f2