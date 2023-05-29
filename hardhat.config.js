// require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
// require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const INFURA_PROJECT_ID = "";
const fs = require("fs");
const mnemonic = fs.readFileSync(".secret").toString().trim();


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.9", settings: { optimizer: { enabled: true, runs: 200 } } },
      { version: "0.7.6", settings: { optimizer: { enabled: true, runs: 200 } } },
      { version: "0.6.6", settings: { optimizer: { enabled: true, runs: 200 } } },
      { version: "0.5.16", settings: { optimizer: { enabled: true, runs: 200 } } },
      { version: "0.4.18", settings: { optimizer: { enabled: true, runs: 200 } } }
    ]
  },
  networks: {
    hardhat: {
      forking: {
        // url: "https://burned-empty-hexagon.bsc-testnet.quiknode.pro/20d143a35659beae8bfd53c7dde8882eae5802f9/",
        url: "https://bsc-mainnet.nodereal.io/v1/6a0b8214f2374badbd0ab2b61bc80395",
        // url: "https://burned-empty-hexagon.bsc-testnet.quiknode.pro/20d143a35659beae8bfd53c7dde8882eae5802f9/"
        // url: "https://convincing-radial-theorem.bsc.quiknode.pro/adba2cb16b72df0b5b28260a2a3e940c77131cb2/",
        // url: "https://open-platform.nodereal.io/dcb2090712d4496789d23eff341f2790/arbitrum-nitro/",
        // url: "https://serene-maximum-lake.arbitrum-mainnet.quiknode.pro/214c634c36a8e58b5458e66b4c9ba40303583424/"
        // url: "https://arb-mainnet.g.alchemy.com/v2/UuTx1M5WxfRRsQrLvJWsT8O_Bait9ajg"
        // blockNumber: 23914113
      },
      accounts: { mnemonic: mnemonic },
      blockGasLimit: 200_000_000,
      allowUnlimitedContractSize: true

    },
    ethereum: {
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: { mnemonic: mnemonic },
    },
    bsc: {
      url: "https://convincing-radial-theorem.bsc.quiknode.pro/adba2cb16b72df0b5b28260a2a3e940c77131cb2/",
      accounts: { mnemonic: mnemonic },
    },
    bsctestnet: {
      url: "https://burned-empty-hexagon.bsc-testnet.quiknode.pro/20d143a35659beae8bfd53c7dde8882eae5802f9/",
      accounts: { mnemonic: mnemonic },
    },
    arbitrum: {
      url: "https://open-platform.nodereal.io/dcb2090712d4496789d23eff341f2790/arbitrum-nitro/",
      accounts: { mnemonic: mnemonic },
    },
    heco: {
      url: "https://http-mainnet.hecochain.com",
      accounts: { mnemonic: mnemonic },
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: { mnemonic: mnemonic },
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: { mnemonic: mnemonic },
    },
    hecotestnet: {
      url: "https://http-testnet.hecochain.com",
      accounts: { mnemonic: mnemonic },
    },
    mumbai: {
      // url: 'https://rpc-mumbai.maticvigil.com',
      url: "https://rpc-mumbai.matic.today",
      accounts: { mnemonic: mnemonic },
    },
  },
  etherscan: {
    // apiKey: 'G6EIDPV3W4KUCR4R5DISJ5PP3AMRCFE4GU' // Ethereum
    apiKey: 'G6EIDPV3W4KUCR4R5DISJ5PP3AMRCFE4GU' // BSC
    // apiKey: "USDZ3V12NJ3RF4NCBQQYQ1N81KYS6IWYJA" // Arbitrum
    // apiKey: '' // HECO
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  mocha: {
    timeout: 2000000,
  },
};
