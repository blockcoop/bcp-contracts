const { RINKEBY_API_KEY, PRIVATE_KEY } = process.env;

const contract = require("../artifacts/contracts/CoopNFT.sol/CoopNFT.json");
const alchemyProvider = new ethers.providers.AlchemyProvider(network="rinkeby", RINKEBY_API_KEY);
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
const coopContract = new ethers.Contract("0x008FFa9740b0e2Ff481557C74eA0f6F27fe09c03", contract.abi, signer);

async function main() {
    const uri = await coopContract.tokenURI(0);
    console.log("The URI is: " + uri);
  }
  main();