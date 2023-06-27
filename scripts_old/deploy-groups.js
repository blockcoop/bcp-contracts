async function main() {
    const Groups = await ethers.getContractFactory("Groups");
    const groups = await Groups.deploy("0x524c0a9bbe74Ddd0E6C5067B59390521A96cf4F1");   
    console.log("Groups Contract deployed to address:", groups.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// GroupsAddress: 0x3cbc9F00856D16B9aCDf4a9c82514001f8849213