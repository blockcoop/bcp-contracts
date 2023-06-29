async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0x7D7D2FeAB2F8613bBA6a290D1E4dcE05878bb1FE", "0x4E28F12815477e71Bba92EA263916db17c2c40bb", "0x89b408B262b0D2C3Ba49AB27FC9207c57ba68cF1");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Tasks address : 0xCEbE5cD9a3281B88a32D14B137A18AA9b39131cB