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

// CoopFactoryAddress: 0x46fc6447cF708962BFcd1D0446289F2E1D297EB3