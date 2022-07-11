async function main() {
    const Tasks = await ethers.getContractFactory("Tasks");
    const tasks = await Tasks.deploy("0xA88ed925dfd96aeB4B0f580fec02Bb2eB21aA9FF");   
    console.log("Tasks Contract deployed to address:", tasks.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// CoopFactoryAddress: 0x351bFFb40544C541A84d3f578059a22e6575d3Bd