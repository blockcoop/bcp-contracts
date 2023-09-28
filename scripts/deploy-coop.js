async function main() {
  const Coop = await ethers.getContractFactory("Coop");
  const coop = await Coop.deploy();   
  console.log("Coop Contract deployed to address:", coop.address);
}
main()
  .then(() => process.exit(0))
  .catch(error => {
      console.error(error);
      process.exit(1);
  });

// Coop Address: 0xBa2D599C9476CF31Ebf1B07838cF0D29AC7B609A