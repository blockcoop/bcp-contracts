async function main() {
    const CoopNFTFactory = await ethers.getContractFactory("CoopNFTFactory");
    const factory = await CoopNFTFactory.deploy();   
    console.log("CoopNFTFactory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0xac595152D545d8F7D29A60934c2e8Db4B9Fa2C36