async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0x662ab6Fc87cc28bD631Ac8BDad0E6eFe0208b4f9