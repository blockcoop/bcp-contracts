async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0x662ab6Fc87cc28bD631Ac8BDad0E6eFe0208b4f9");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0xeC1B3dC4347B6aA4068332AAa53af70Cc8eAAc9F