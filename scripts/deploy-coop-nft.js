async function main() {
    const CoopNFT = await ethers.getContractFactory("CoopNFT");
    const coopNFT = await CoopNFT.deploy();   
    console.log("CoopNFT Contract deployed to address:", coopNFT.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// TokenURIAddress: 0x073533d2C6B04067D42a2ED66BBEF7F842cAEcDF