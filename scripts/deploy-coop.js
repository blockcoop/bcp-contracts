async function main() {
    const Coop = await ethers.getContractFactory("Coop");
    const coop = await Coop.deploy("Test Coop1", "TCP1", "0xa8da7eB9ED0629dE63cA5D7150a74e1AFbEfAac0", 172800, 20, 60, 0, "India");   
    console.log("Coop Contract deployed to address:", coop.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });