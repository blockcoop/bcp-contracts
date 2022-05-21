async function main() {
    const CoopFactory = await ethers.getContractFactory("CoopFactory");
    const coopFactory = await CoopFactory.deploy();   
    console.log("CoopFactory Contract deployed to address:", coopFactory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0x52e08bc06526E79030D9DC3c5924fdA7b2d8d528