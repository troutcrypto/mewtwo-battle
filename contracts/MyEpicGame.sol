// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


import "hardhat/console.sol";
import "./libraries/Base64.sol";

// Our contract inherits from ERC721, which is the standard NFT contract!
contract MyEpicGame is ERC721 {

    struct CharacterAttributes {
        uint charIdx;
        string name;
        string imageURI;        
        uint hp;
        uint maxHp;
        uint attackDmg;
    }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  // 0, 1, 2, 3, etc.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    CharacterAttributes[] defaultCharacters;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
        struct BigBoss {
            string name;
            string imageURI;
            uint hp;
            uint maxHp;
            uint attackDmg;
        }
        BigBoss public bigBoss;
    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;
    
    constructor(
        string[] memory charNames,
        string[] memory charURIs,
        uint[] memory charHp,
        uint[] memory charDmg,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDmg
        // Below, you can also see I added some special identifier symbols for our NFT.
        // This is the name and symbol for our token, ex Ethereum and ETH. I just call mine
        // Heroes and HERO. Remember, an NFT is just a token!
    )
        ERC721("Heroes", "HERO")
    {
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDmg: bossAttackDmg
        });
        console.log("Done initializing boss %s with HP %s, img%s.");
        for(uint i = 0; i < charNames.length; i += 1) {
        defaultCharacters.push(CharacterAttributes({
            charIdx: i,
            name: charNames[i],
            imageURI: charURIs[i],
            hp: charHp[i],
            maxHp: charHp[i],
            attackDmg: charDmg[i]
        }));
    
        CharacterAttributes memory c = defaultCharacters[i];
        
        // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
        console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }

        // I increment tokenIds here so that my first NFT has an ID of 1.
        // More on this in the lesson!
        _tokenIds.increment();
    }

    // Users would be able to hit this function and get their NFT based on the
    // characterId they send in!
    function mintCharacterNFT(uint _charIdx) external {
        // Get current tokenId (starts at 1 since we incremented in the constructor).
        uint256 newItemId = _tokenIds.current();
        // new item id = canonical id
        // create new nft thing -> get new id, increment id
        // map itemid -> character
        // map msg sender -> item id
        // The magical function! Assigns the tokenId to the caller's wallet address.
        _safeMint(msg.sender, newItemId);
    
        // We map the tokenId => their character attributes. More on this in
        // the lesson below.
        nftHolderAttributes[newItemId] = CharacterAttributes({
        charIdx: _charIdx,
        name: defaultCharacters[_charIdx].name,
        imageURI: defaultCharacters[_charIdx].imageURI,
        hp: defaultCharacters[_charIdx].hp,
        maxHp: defaultCharacters[_charIdx].hp,
        attackDmg: defaultCharacters[_charIdx].attackDmg
        });
    
        console.log("Minted NFT w/ tokenId %s and charIdx %s", newItemId, _charIdx);
        
        // Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender] = newItemId;
        console.log('Associating %s with item id: %s', msg.sender, newItemId);
        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _charIdx);
    }

    function attackBoss() public {
        uint nftTokeIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokeIdOfPlayer];
        console.log("Player with character %s attacking (player hp: %s, dmg: %s)", player.name, player.hp, player.attackDmg);
        console.log("Boss status | hp: %s, dmg: %s)", bigBoss.hp, bigBoss.attackDmg);

        require (
            player.hp > 0,
            "Error: character must have HP > 0!"
        );

        require (
            bigBoss.hp > 0,
            "Error: boss must have HP > 0!"
        );
        // player attacks the boss
        if (bigBoss.hp < player.attackDmg) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDmg;
        }

        // boss attacks player
        if (player.hp < bigBoss.attackDmg) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDmg;
        }

        console.log("Post attack summary:");
        console.log("Attacking player with character %s status (hp: %s, dmg: %s)", player.name, player.hp, player.attackDmg);
        console.log("Boss status | hp: %s, dmg: %s)", bigBoss.hp, bigBoss.attackDmg);
        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];
        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strDmg = Strings.toString(charAttributes.attackDmg);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Dmg", "value": ',
                        strDmg,'} ]}'
                    ) 
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }
    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // Get tokenId of the user's character NFT if the user has a tokenId in the mapping
        // else return empty character
        uint userNftTokenId = nftHolders[msg.sender];
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);
}