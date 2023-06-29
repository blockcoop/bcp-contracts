async function main() {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy("0x7D7D2FeAB2F8613bBA6a290D1E4dcE05878bb1FE", "0x4E28F12815477e71Bba92EA263916db17c2c40bb");   
    console.log("Voting Contract deployed to address:", voting.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Voting address : 0x89b408B262b0D2C3Ba49AB27FC9207c57ba68cF1