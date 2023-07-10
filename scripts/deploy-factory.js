async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0xb6e36a0592c3c96Fda6Dcc1692C11f33Dd2CE33B", "0x6046F5Cae674c603D8c0D83E3C858De7Dcf38750", "0xc6F31D742F030d7DafC740cCacca92D7ABCb02D4");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Factory Address: 0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b