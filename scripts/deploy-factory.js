async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0xBa2D599C9476CF31Ebf1B07838cF0D29AC7B609A", "0x6046F5Cae674c603D8c0D83E3C858De7Dcf38750", "0xc6F31D742F030d7DafC740cCacca92D7ABCb02D4");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Factory Address: 0xCe9B9A9df64458622b149F39f61f5a60391638a0