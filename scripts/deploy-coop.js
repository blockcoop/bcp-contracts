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

// Coop Address: 0xaBC4c4Faa33BFA2cb2645398206d435522Cd4c24