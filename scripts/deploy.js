const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
    const gameContract = await gameContractFactory.deploy(
        ["Charmander", "Squirtle", "Bulbasaur"],
        ["https://cdn2.bulbagarden.net/upload/7/73/004Charmander.png",
        "https://cdn2.bulbagarden.net/upload/3/39/007Squirtle.png",
        "https://cdn2.bulbagarden.net/upload/thumb/2/21/001Bulbasaur.png/600px-001Bulbasaur.png" 
        ],
        [200, 200, 200], // HP
        [12, 10, 10],    // Dmg
        "Mewtwo",
        "https://cdn2.bulbagarden.net/upload/thumb/7/78/150Mewtwo.png/600px-150Mewtwo.png",
        400,
        20
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    // let txn;
    // txn = await gameContract.mintCharacterNFT(0);
    // await txn.wait();
// 
    // txn = await gameContract.mintCharacterNFT(1);
    // await txn.wait();
// 
    // txn = await gameContract.mintCharacterNFT(2);
    // await txn.wait()
    // 
    // let returnedTokenUri = await gameContract.tokenURI(1);
    // // console.log("Token URI:", returnedTokenUri); // nothing to print b/c nft isnt actually binded to the mapping?
    // txn = await gameContract.attackBoss();
    // await txn.wait(); 
// 
    // txn = await gameContract.attackBoss();
    // await txn.wait();
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }

};

runMain()