const hre = require("hardhat");

async function main() {
  const Factory = await hre.ethers.getContractFactory("ElectionFactory");
  const factory = await Factory.deploy(); // ❌ deploy() karna hota hai, deployed() nahi
  await factory.waitForDeployment(); // ✅ New ethers v6 me ye syntax use hota hai
  console.log("Factory Contract deployed at:", await factory.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
