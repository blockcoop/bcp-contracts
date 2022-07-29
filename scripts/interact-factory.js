const { API_KEY, PRIVATE_KEY } = process.env;

const contract = require("../artifacts/contracts/Factory.sol/Factory.json");
const alchemyProvider = new ethers.providers.AlchemyProvider(network="ropsten", API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
const factoryContract = new ethers.Contract("0x2ce6Bf32b724482430178286A60120B6a3FdeEc3", contract.abi, signer);

async function main() {
    const uri = await factoryContract.createCoop("Test Coop", "TCP", 172800, 20, 60, 0, "India");
    console.log("The URI is: " + uri);
  }
  main();