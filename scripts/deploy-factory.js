async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0xaBC4c4Faa33BFA2cb2645398206d435522Cd4c24","0xc6F31D742F030d7DafC740cCacca92D7ABCb02D4", "0x6046F5Cae674c603D8c0D83E3C858De7Dcf38750");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Factory Address: 0x7D7D2FeAB2F8613bBA6a290D1E4dcE05878bb1FE