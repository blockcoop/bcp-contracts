async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0x62Edd78F3a9638Eaa3c442224Fc48c3082F67516");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0x524c0a9bbe74Ddd0E6C5067B59390521A96cf4F1