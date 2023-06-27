async function main() {
    const Account = await ethers.getContractFactory("Account");
    const account = await Account.deploy();   
    console.log("Account Contract deployed to address:", account.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Account address : 0xc6F31D742F030d7DafC740cCacca92D7ABCb02D4