// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract Fund is Script {
    function run() external {
        // Get the lending contract address from environment variables
        address lendingContract = vm.envAddress("LENDING_CONTRACT_ADDRESS");
        require(lendingContract != address(0), "LENDING_CONTRACT_ADDRESS not set");

        // Amount to fund in ether
        uint256 amount = 10 ether;

        vm.startBroadcast();

        // Send ETH to the contract
        (bool success, ) = payable(lendingContract).call{value: amount}("");
        require(success, "Failed to send Ether");

        vm.stopBroadcast();

        console.log("Successfully funded contract %s with %s ETH", lendingContract, amount / 1e18);
    }
}
