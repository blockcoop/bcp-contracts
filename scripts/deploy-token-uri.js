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

// TokenURIAddress: 0x073533d2C6B04067D42a2ED66BBEF7F842cAEcDF