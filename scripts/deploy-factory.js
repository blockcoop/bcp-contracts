async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0x073533d2C6B04067D42a2ED66BBEF7F842cAEcDF");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0x2ce6Bf32b724482430178286A60120B6a3FdeEc3