async function main() {
    const Groups = await ethers.getContractFactory("Groups");
    const groups = await Groups.deploy("0x7D7D2FeAB2F8613bBA6a290D1E4dcE05878bb1FE");   
    console.log("Groups Contract deployed to address:", groups.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Groups address : 0x4E28F12815477e71Bba92EA263916db17c2c40bb