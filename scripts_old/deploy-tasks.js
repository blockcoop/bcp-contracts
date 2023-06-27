async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0x524c0a9bbe74Ddd0E6C5067B59390521A96cf4F1", "0x3cbc9F00856D16B9aCDf4a9c82514001f8849213");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// TasksAddress: 0x2C48A17E43c72b17941f817ae62D5bF30d1C5F15