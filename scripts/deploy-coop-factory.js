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

// CoopFactoryAddress: 0x1a07E67708BFF488b97C05D264656354db39A321