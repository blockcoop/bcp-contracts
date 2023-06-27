const { API_KEY, PRIVATE_KEY } = process.env;

const contract = require("../artifacts/contracts/CoopNFTFactory.sol/CoopNFTFactory.json");
const alchemyProvider = new ethers.providers.AlchemyProvider(network="ropsten", API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
const factoryContract = new ethers.Contract("0xec812AcFb32E765d2d792aEF9AdA8e588458e234", contract.abi, signer);

async function main() {
    const coop = await factoryContract.createCoop("Test Coop", "TCP", 172800, 20, 60, 0, "India");
    console.log("The Coop is: " + coop.address);
  }
  main();