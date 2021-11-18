// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-waffle');
require('dotenv').config();

module.exports = {
    solidity: '0.8.0',
    networks: {
        rinkeby: {
            url: process.env.STAGING_ALCHEMY_KEY,
            accounts: [process.env.PRIVATE_KEY],
        },
    },
    gas: "10000000",
    gasPrice: "10000000"
};

