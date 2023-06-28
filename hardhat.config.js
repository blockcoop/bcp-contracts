/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
require('hardhat-contract-sizer');

const { API_URL, PRIVATE_KEY, RINKEBY_API_URL, ARBITRUM_GOERLI_API_URL } = process.env;

module.exports = {
  solidity: "0.8.18",
  defaultNetwork: "arbitrumGoerli",
  networks: {
    hardhat: {},
    ropsten: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    rinkeby: {
      url: RINKEBY_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    arbitrumGoerli: {
      url: ARBITRUM_GOERLI_API_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    },
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
};
