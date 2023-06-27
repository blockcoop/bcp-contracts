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

// TokenURIAddress: 0x62Edd78F3a9638Eaa3c442224Fc48c3082F67516