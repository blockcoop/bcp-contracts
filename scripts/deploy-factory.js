async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0x8D2F0C678BF9CfAF7767268F74f13e9E6A4a2900","0xc6F31D742F030d7DafC740cCacca92D7ABCb02D4", "0x6046F5Cae674c603D8c0D83E3C858De7Dcf38750");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Factory Address: 0x3f80F22C01f5923F1047d968f88f10bb5eD88d25