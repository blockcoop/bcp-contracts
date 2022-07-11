async function main() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();   
    console.log("Factory Contract deployed to address:", factory.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0xA88ed925dfd96aeB4B0f580fec02Bb2eB21aA9FF