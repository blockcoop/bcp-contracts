const { ethers, upgrades } = require('hardhat');

async function main () {
  const Coop = await ethers.getContractFactory('Coop');
  console.log('Deploying Coop...');
  const coop = await upgrades.deployProxy(Coop, ['0xaE6C70f4310288DEd80B5D70ac44fDBfE87caEEf', 'Blockcoop', 'COOP', '0x5C2cc3d2b67272191944E112700c880B8958CE9c', true, 100, '0x0000000000000000000000000000000000000000', 'India'], { initializer: 'initialize' });
  await coop.deployed();
  console.log('Coop deployed to:', coop.address);
}

main();