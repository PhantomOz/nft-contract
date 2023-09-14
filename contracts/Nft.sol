// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract NFT is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    
    // Define the NFT structure
    struct NFT {
        uint256 id; // The unique identifier of the NFT
        uint256 energy; // The energy level of the NFT (0-100)
        uint256 speed; // The speed level of the NFT (0-100)
        uint256 strength; // The strength level of the NFT (0-100)
        uint256 intelligence; // The intelligence level of the NFT (0-100)
        uint256 charisma; // The charisma level of the NFT (0-100)
        uint256 luck; // The luck level of the NFT (0-100)
    }
    
    // Store the NFTs in an array
    NFT[] public nfts;
    
    // Mapping from token ID to owner address
    mapping (uint256 => address) public owners;
    
    // Mapping from owner to number of owned token
    mapping (address => uint256) public balances;
    
    // Mapping from token ID to approved address
    mapping (uint256 => address) public approved;
    
    // Event to notify when a new NFT is minted
    event Minted(address indexed owner, uint256 indexed tokenId);
    
    // Event to notify when a random number is generated
    event RandomGenerated(uint256 indexed random);
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Goerli
     * Chainlink VRF Coordinator address: 0x3d2341ADb2D31f1c5530cDC622016af293177AE0
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x8d2a7baeb42f3e5e9bea4e75a1559a58477eafdd8c7f5fbcfa5b3f74d4df7d18
     */
    constructor() 
        VRFConsumerBase(
            0x3d2341ADb2D31f1c5530cDC622016af293177AE0, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        )
    {
        keyHash = 0x8d2a7baeb42f3e5e9bea4e75a1559a58477eafdd8c7f5fbcfa5b3f74d4df7d18;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }
    
    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        emit RandomGenerated(randomResult);
    }

    /**
     * Mint a new NFT with random traits
     */
    function mint() public {
        // Generate a random number from the current block number and timestamp
        uint256 seed = block.number + block.timestamp;
        
        // Request a random number from Chainlink VRF using the seed
        bytes32 requestId = getRandomNumber(seed);
        
        // Wait for the fulfillRandomness function to be called by the VRF Coordinator
        // This may take several blocks depending on the network congestion and gas price
        
        // Use the randomResult to generate traits for the new NFT
        uint256 newId = nfts.length; // The new NFT id is the current length of the array
        uint256 newEnergy = (randomResult % 100) + 1; // A random number between 1 and 100
        uint256 newSpeed = ((randomResult / 100) % 100) + 1; // A random number between 1 and 100
        uint256 newStrength = ((randomResult / 10000) % 100) + 1; // A random number between 1 and 100
        uint256 newIntelligence = ((randomResult / 1000000) % 100) + 1; // A random number between 1 and 100
        uint256 newCharisma = ((randomResult / 100000000) % 100) + 1; // A random number between 1 and 100
        uint256 newLuck = ((randomResult / 10000000000) % 100) + 1; // A random number between 1 and 100
        
        // Create the new NFT with the generated traits
        NFT memory newNFT = NFT(newId, newEnergy, newSpeed, newStrength, newIntelligence, newCharisma, newLuck);
        
        // Push the new NFT to the array
        nfts.push(newNFT);
        
        // Transfer the ownership of the new NFT to the caller of this function
        owners[newId] = msg.sender;
        
        // Increase the balance of the owner by 1
        balances[msg.sender] += 1;
        
        // Emit an event to notify that a new NFT is minted
        emit Minted(msg.sender, newId);
    }
    
    /**
     * Returns the total number of NFTs
     */
    function totalSupply() public view returns (uint256) {
        return nfts.length;
    }
    
    /**
     * Returns the owner of the NFT with the given id
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        return owners[tokenId];
    }
    
    /**
     * Returns the balance of the given address
     */
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }
    
    /**
     * Transfers the ownership of the NFT with the given id from the sender to the recipient
     */
    function transfer(address recipient, uint256 tokenId) public {
        require(owners[tokenId] == msg.sender, "You are not the owner of this NFT");
        
        // Transfer the ownership
        owners[tokenId] = recipient;
        
        // Decrease the balance of the sender by 1
        balances[msg.sender] -= 1;
        
        // Increase the balance of the recipient by 1
        balances[recipient] += 1;
    }
    
    /**
     * Approves the given address to transfer the NFT with the given id
     */
    function approve(address approved, uint256 tokenId) public {
        require(owners[tokenId] == msg.sender, "You are not the owner of this NFT");
        
        // Approve the address
        approved[tokenId] = approved;
    }
    
    /**
     * Returns the approved address for the NFT with the given id
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        return approved[tokenId];
    }
    
    /**
     * Transfers the ownership of the NFT with the given id from the owner to the recipient using an approved address
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(approved[tokenId] == msg.sender, "You are not approved to transfer this NFT");
        
        // Transfer the ownership
        owners[tokenId] = to;
        
        // Decrease the balance of the sender by 1
        balances[from] -= 1;
        
        // Increase the balance of the recipient by 1
        balances[to] += 1;
        
        // Clear the approval for this NFT
        approved[tokenId] = address(0);
    }
}
