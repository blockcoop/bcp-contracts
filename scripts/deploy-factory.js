async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy("0xc6F31D742F030d7DafC740cCacca92D7ABCb02D4", "0x6046F5Cae674c603D8c0D83E3C858De7Dcf38750");   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Factory Address: 0x0eA97e9f0FFDa7e9f58dfF7AACEB70d8F19FD85E