// Import the required libraries and modules
import { ethers } from "hardhat";
import { NFT } from "../typechain/NFT";

// Define the main function
async function main() {
  // Get the signer account from hardhat
  const [deployer] = await ethers.getSigners();

  // Log the deployer address
  console.log("Deploying the contract with the account:", deployer.address);

  // Get the balance of the deployer
  const balance = await deployer.getBalance();

  // Log the balance of the deployer
  console.log("Account balance:", balance.toString());

  // Get the NFT contract factory
  const NFT = await ethers.getContractFactory("NFT");

  // Deploy the NFT contract and wait for it to be mined
  const nft = await NFT.deploy() as NFT;
  await nft.deployed();

  // Log the address of the deployed contract
  console.log("NFT deployed to:", nft.address);
}

// Call the main function and catch any errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
