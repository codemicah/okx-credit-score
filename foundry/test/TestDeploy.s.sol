// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/CreditScore.sol";
import "../src/SimpleLending.sol";

/**
 * @title TestDeploy
 * @dev Deployment script for testing environment with pre-configured test scenarios
 * This script deploys contracts and sets up test data for comprehensive testing
 */
contract TestDeploy is Script, Test {
    CreditScore public creditScore;
    SimpleLending public lending;
    
    // Test addresses - using deterministic addresses for consistency
    address public constant ALICE = address(0x1111111111111111111111111111111111111111);
    address public constant BOB = address(0x2222222222222222222222222222222222222222);
    address public constant CHARLIE = address(0x3333333333333333333333333333333333333333);
    address public constant DAVE = address(0x4444444444444444444444444444444444444444);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying contracts...");
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy CreditScore contract
        creditScore = new CreditScore();
        console.log("CreditScore deployed at:", address(creditScore));
        console.log("Oracle set to:", creditScore.oracle());

        // Deploy SimpleLending contract
        lending = new SimpleLending(address(creditScore));
        console.log("SimpleLending deployed at:", address(lending));
        console.log("Lending owner:", lending.owner());

        // Fund the lending contract with initial liquidity
        uint256 initialFunding = 50 ether;
        lending.deposit{value: initialFunding}();
        console.log("Funded lending contract with:", initialFunding);
        console.log("Lending contract balance:", address(lending).balance);

        // Set up test users with different credit profiles
        setupTestUsers();

        // Verify deployment
        verifyDeployment();

        vm.stopBroadcast();

        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("CreditScore:", address(creditScore));
        console.log("SimpleLending:", address(lending));
        console.log("Initial Funding:", initialFunding);
        console.log("Test Users Set Up: 4");
        console.log("Deployment Complete!");
    }

    function setupTestUsers() internal {
        console.log("\nSetting up test users...");

        // Alice: Excellent trader (max score)
        creditScore.updateUserData(ALICE, 25000e6, 150); // $25k volume, 150 trades
        uint256 aliceScore = creditScore.getScore(ALICE);
        console.log("Alice score:", aliceScore);

        // Bob: Good trader  
        creditScore.updateUserData(BOB, 8000e6, 40); // $8k volume, 40 trades
        uint256 bobScore = creditScore.getScore(BOB);
        console.log("Bob score:", bobScore);

        // Charlie: Average trader (barely eligible)
        creditScore.updateUserData(CHARLIE, 1200e6, 34); // $1.2k volume, 34 trades
        uint256 charlieScore = creditScore.getScore(CHARLIE);
        console.log("Charlie score:", charlieScore);

        // Dave: Poor trader (ineligible)
        creditScore.updateUserData(DAVE, 200e6, 5); // $200 volume, 5 trades
        uint256 daveScore = creditScore.getScore(DAVE);
        console.log("Dave score:", daveScore, "(ineligible)");

        console.log("Test users configured successfully");
    }

    function verifyDeployment() internal view {
        console.log("\nVerifying deployment...");

        // Verify CreditScore contract
        require(creditScore.oracle() != address(0), "Oracle not set");
        require(creditScore.MAX_SCORE() == 1000, "Invalid max score");
        
        // Verify SimpleLending contract
        require(address(lending.creditScore()) == address(creditScore), "Invalid credit score reference");
        require(lending.owner() != address(0), "Owner not set");
        require(lending.MIN_SCORE() == 300, "Invalid min score");
        require(lending.LOAN_DURATION() == 30 days, "Invalid loan duration");
        require(lending.ETH_PRICE_IN_USD() == 3000, "Invalid ETH price");

        // Verify contract has funds
        require(address(lending).balance > 0, "Lending contract not funded");

        // Verify test users have scores
        require(creditScore.getScore(ALICE) >= 300, "Alice score invalid");
        require(creditScore.getScore(BOB) >= 300, "Bob score invalid");
        require(creditScore.getScore(CHARLIE) >= 300, "Charlie score invalid");
        require(creditScore.getScore(DAVE) < 300, "Dave should be ineligible");

        console.log("All verifications passed");
    }

    // Helper function to get deployment addresses (for use in tests)
    function getDeploymentAddresses() external view returns (address, address) {
        return (address(creditScore), address(lending));
    }

    // Helper function to get test user addresses
    function getTestUsers() external pure returns (address[4] memory) {
        return [ALICE, BOB, CHARLIE, DAVE];
    }
}