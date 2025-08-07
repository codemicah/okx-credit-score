// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CreditScore.sol";
import "../src/SimpleLending.sol";

contract DeployLocal is Script {
    function run() external {
        // Use default Anvil private key for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy CreditScore contract first
        CreditScore creditScore = new CreditScore();
        console.log("CreditScore deployed at:", address(creditScore));

        // Deploy SimpleLending contract with CreditScore address
        SimpleLending simpleLending = new SimpleLending(address(creditScore));
        console.log("SimpleLending deployed at:", address(simpleLending));

        vm.stopBroadcast();
    }
}
