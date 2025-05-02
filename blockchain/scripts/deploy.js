// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const Election = await hre.ethers.getContractFactory("Election");
  const election = await Election.deploy();
  await election.waitForDeployment();

  console.log(`Election Contract deployed to: ${election.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
