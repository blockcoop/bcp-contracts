const { RINKEBY_API_KEY, PRIVATE_KEY } = process.env;

const contract = require("../artifacts/contracts/Coop.sol/Coop.json");
const alchemyProvider = new ethers.providers.AlchemyProvider(network="rinkeby", RINKEBY_API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
const coopContract = new ethers.Contract("0x88d014D86CeddC0BdA7ff41e0bA39055BE416Ca3", contract.abi, signer);

async function main() {
    const uri = await coopContract.tokenURI(0);
    console.log("The URI is: " + uri);
  }
  main();