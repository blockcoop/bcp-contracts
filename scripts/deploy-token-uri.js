async function main() {
    const TokenURI = await ethers.getContractFactory("TokenURI");
    const tokenURI = await TokenURI.deploy();   
    console.log("TokenURI Contract deployed to address:", tokenURI.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// TokenURI address : 0x6046F5Cae674c603D8c0D83E3C858De7Dcf38750