const { API_KEY, PRIVATE_KEY } = process.env;

const contract = require("../artifacts/contracts/TokenURI.sol/TokenURI.json");
const alchemyProvider = new ethers.providers.AlchemyProvider(network="ropsten", API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
const tokenURIContract = new ethers.Contract("0x073533d2C6B04067D42a2ED66BBEF7F842cAEcDF", contract.abi, signer);

async function main() {
    const uri = await tokenURIContract.create("Shashank", "Creator");
    console.log("The URI is: " + uri);
  }
  main();