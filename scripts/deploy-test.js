async function main() {
    const Test = await ethers.getContractFactory("Test");
    const test = await Test.deploy("0xDeA07B136308caaB8Ae43b6AfC942c7fdE1b827b", "0x9074DFFdA5f957AFaB8b4198Fc22e799B6bC6eA6", "0x53906C1DebD46428E45Dab339B5e638c18da205c");   
    console.log("Test Contract deployed to address:", test.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Tasks Address: 0xfEE29Af27Bc35558E7B35575b4f797209E568181