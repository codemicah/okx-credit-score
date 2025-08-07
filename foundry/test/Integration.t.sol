// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CreditScore.sol";
import "../src/SimpleLending.sol";

contract IntegrationTest is Test {
    CreditScore public creditScore;
    SimpleLending public lending;
    
    address public oracle;
    address public lendingOwner;
    address public alice;
    address public bob;
    address public charlie;
    address public dave;

    event ScoreUpdated(address indexed user, uint256 score);
    event LoanIssued(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);

    function setUp() public {
        // Set up accounts
        oracle = address(this); // Test contract acts as oracle
        lendingOwner = address(this); // Test contract acts as lending owner
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        dave = makeAddr("dave");

        // Deploy contracts
        creditScore = new CreditScore();
        lending = new SimpleLending(address(creditScore));

        // Fund the lending contract
        vm.deal(address(lending), 100 ether);

        // Verify initial setup
        assertEq(creditScore.oracle(), oracle);
        assertEq(lending.owner(), lendingOwner);
        assertEq(address(lending.creditScore()), address(creditScore));
    }

    // Test complete user journey: score update -> borrow -> repay
    function testCompleteUserJourney() public {
        // Step 1: User starts with no credit score
        assertEq(creditScore.getScore(alice), 0);
        
        // Step 2: Oracle updates user's trading data (simulating OKX DEX data)
        uint256 tradingVolume = 5000e6; // $5,000 trading volume
        uint256 tradeCount = 25; // 25 trades
        uint256 expectedScore = 200 + 250 + 75; // Base + Volume + Trades = 525

        vm.expectEmit(true, false, false, true);
        emit ScoreUpdated(alice, expectedScore);

        creditScore.updateUserData(alice, tradingVolume, tradeCount);

        // Verify score was calculated and stored correctly
        assertEq(creditScore.getScore(alice), expectedScore);
        assertEq(creditScore.tradingVolume(alice), tradingVolume);
        assertEq(creditScore.tradeCount(alice), tradeCount);
        assertEq(creditScore.lastUpdated(alice), block.timestamp);

        // Step 3: User borrows based on credit score
        uint256 creditLimit = expectedScore * 10 * 1e6; // $5,250
        uint256 expectedLoanUSD = creditLimit / 2; // $2,625 (50% of limit)
        uint256 expectedLoanETH = (expectedLoanUSD * 1e12) / lending.ETH_PRICE_IN_USD(); // ~0.875 ETH

        uint256 aliceInitialBalance = alice.balance;
        uint256 contractInitialBalance = address(lending).balance;

        vm.expectEmit(true, false, false, true);
        emit LoanIssued(alice, expectedLoanUSD);

        vm.prank(alice);
        lending.borrow();

        // Verify loan was issued correctly
        (uint256 loanAmount, uint256 dueDate, bool repaid) = lending.loans(alice);
        assertEq(loanAmount, expectedLoanUSD);
        assertEq(dueDate, block.timestamp + lending.LOAN_DURATION());
        assertFalse(repaid);

        // Verify ETH was transferred
        assertEq(alice.balance, aliceInitialBalance + expectedLoanETH);
        assertEq(address(lending).balance, contractInitialBalance - expectedLoanETH);

        // Step 4: User repays the loan
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        
        vm.expectEmit(true, false, false, true);
        emit LoanRepaid(alice, loanAmount);

        vm.prank(alice);
        lending.repay{value: repayAmountETH}();

        // Verify loan was repaid
        (, , bool finalRepaidStatus) = lending.loans(alice);
        assertTrue(finalRepaidStatus);

        // Verify contract received repayment
        assertEq(address(lending).balance, contractInitialBalance);
    }

    // Test multiple users with different credit profiles
    function testMultipleUserScenarios() public {
        // Alice: High-volume, high-frequency trader (excellent score)
        creditScore.updateUserData(alice, 25000e6, 150); // Should get max score (1000)
        uint256 aliceScore = creditScore.getScore(alice);
        assertEq(aliceScore, 1000);

        // Bob: Medium-volume trader (good score)
        creditScore.updateUserData(bob, 8000e6, 40); // Should get ~690 score
        uint256 bobScore = creditScore.getScore(bob);
        assertEq(bobScore, 200 + 400 + 120); // 720

        // Charlie: Low-volume trader (barely eligible)
        creditScore.updateUserData(charlie, 1000e6, 34); // Should get ~352 score
        uint256 charlieScore = creditScore.getScore(charlie);
        assertEq(charlieScore, 200 + 50 + 102); // 352

        // Dave: Very low activity (ineligible)
        creditScore.updateUserData(dave, 200e6, 5); // Should get ~225 score (below min)
        uint256 daveScore = creditScore.getScore(dave);
        assertEq(daveScore, 200 + 10 + 15); // 225
        assertTrue(daveScore < lending.MIN_SCORE());

        // All eligible users borrow
        vm.prank(alice);
        lending.borrow();

        vm.prank(bob);
        lending.borrow();

        vm.prank(charlie);
        lending.borrow();

        // Dave should fail to borrow
        vm.startPrank(dave);
        vm.expectRevert("Score too low");
        lending.borrow();
        vm.stopPrank();

        // Verify loan amounts are proportional to scores
        (uint256 aliceLoan, , ) = lending.loans(alice);
        (uint256 bobLoan, , ) = lending.loans(bob);
        (uint256 charlieLoan, , ) = lending.loans(charlie);
        (uint256 daveLoan, , ) = lending.loans(dave);

        assertEq(aliceLoan, 5000e6); // 1000 * 10 / 2
        assertEq(bobLoan, 3600e6); // 720 * 10 / 2
        assertEq(charlieLoan, 1760e6); // 352 * 10 / 2
        assertEq(daveLoan, 0); // No loan issued

        assertTrue(aliceLoan > bobLoan);
        assertTrue(bobLoan > charlieLoan);
    }

    // Test score updates affecting existing borrowers
    function testScoreUpdateImpactOnExistingLoans() public {
        // Set initial score for Alice
        creditScore.updateUserData(alice, 3000e6, 30); // Initial score ~440
        uint256 initialScore = creditScore.getScore(alice);

        // Alice borrows based on initial score
        vm.prank(alice);
        lending.borrow();

        (uint256 initialLoanAmount, , ) = lending.loans(alice);
        assertEq(initialLoanAmount, 2200e6); // 440 * 10 / 2

        // Repay initial loan
        uint256 repayAmount = (initialLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        vm.deal(alice, repayAmount);
        vm.prank(alice);
        lending.repay{value: repayAmount}();

        // Oracle updates Alice's score (she's been more active)
        creditScore.updateUserData(alice, 10000e6, 80); // Higher activity
        uint256 newScore = creditScore.getScore(alice);
        assertTrue(newScore > initialScore);

        // Alice borrows again with new, higher score
        vm.prank(alice);
        lending.borrow();

        (uint256 newLoanAmount, , ) = lending.loans(alice);
        assertTrue(newLoanAmount > initialLoanAmount);
        
        uint256 expectedNewLoanAmount = (newScore * 10 * 1e6) / 2;
        assertEq(newLoanAmount, expectedNewLoanAmount);
    }

    // Test oracle role and security
    function testOracleSecurityIntegration() public {
        address maliciousActor = makeAddr("malicious");
        
        // Malicious actor cannot update scores
        vm.startPrank(maliciousActor);
        vm.expectRevert("Only oracle");
        creditScore.updateUserData(alice, 1000000e6, 1000); // Fake high score
        vm.stopPrank();

        // Oracle can update scores
        creditScore.updateUserData(alice, 2000e6, 20);
        assertEq(creditScore.getScore(alice), 340); // 200 + 100 + 60

        // User can borrow based on legitimate score
        vm.prank(alice);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(alice);
        assertEq(loanAmount, 1700e6); // 340 * 10 / 2
    }

    // Test lending contract owner functions
    function testLendingOwnerFunctionsIntegration() public {
        uint256 initialBalance = address(lending).balance;
        
        // Owner can withdraw funds
        uint256 withdrawAmount = 10 ether;
        uint256 ownerInitialBalance = lendingOwner.balance;
        
        lending.withdraw(withdrawAmount);
        
        assertEq(address(lending).balance, initialBalance - withdrawAmount);
        assertEq(lendingOwner.balance, ownerInitialBalance + withdrawAmount);

        // Non-owner cannot withdraw
        vm.startPrank(alice);
        vm.expectRevert("Not the owner");
        lending.withdraw(1 ether);
        vm.stopPrank();

        // Anyone can deposit
        vm.deal(alice, 5 ether);
        vm.prank(alice);
        lending.deposit{value: 2 ether}();
        
        assertEq(address(lending).balance, initialBalance - withdrawAmount + 2 ether);
    }

    // Test contract interaction limits and edge cases
    function testContractLimitsIntegration() public {
        // Drain most of the lending contract funds
        uint256 contractBalance = address(lending).balance;
        lending.withdraw(contractBalance - 1 ether); // Leave only 1 ETH

        // Set up a user with high score
        creditScore.updateUserData(alice, 15000e6, 100); // High score = large loan
        uint256 aliceScore = creditScore.getScore(alice);

        uint256 expectedLoanUSD = (aliceScore * 10 * 1e6) / 2;
        uint256 expectedLoanETH = (expectedLoanUSD * 1e12) / lending.ETH_PRICE_IN_USD();

        // Contract doesn't have enough funds for the full loan
        assertTrue(expectedLoanETH > 1 ether);

        vm.startPrank(alice);
        vm.expectRevert("Insufficient funds in contract");
        lending.borrow();
        vm.stopPrank();

        // Add funds back and user should be able to borrow
        vm.deal(address(lending), 100 ether);

        vm.prank(alice);
        lending.borrow(); // Should succeed now

        (uint256 loanAmount, , ) = lending.loans(alice);
        assertEq(loanAmount, expectedLoanUSD);
    }

    // Test time-based scenarios
    function testTimeSensitiveScenarios() public {
        uint256 startTime = block.timestamp;

        // Update score and borrow
        creditScore.updateUserData(alice, 3000e6, 30);
        assertEq(creditScore.lastUpdated(alice), startTime);

        vm.prank(alice);
        lending.borrow();

        (uint256 loanAmount, uint256 dueDate, ) = lending.loans(alice);
        assertEq(dueDate, startTime + lending.LOAN_DURATION());

        // Fast forward time but before due date
        vm.warp(startTime + 15 days); // Halfway through loan term

        // User can still repay normally
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        vm.deal(alice, repayAmountETH);
        vm.prank(alice);
        lending.repay{value: repayAmountETH}();

        (, , bool repaid) = lending.loans(alice);
        assertTrue(repaid);

        // Fast forward past original due date
        vm.warp(startTime + 35 days);

        // Score can still be updated after loan completion
        creditScore.updateUserData(alice, 5000e6, 50);
        assertEq(creditScore.lastUpdated(alice), startTime + 35 days);
    }

    // Test complete protocol scenario with multiple interactions
    function testCompleteProtocolScenario() public {
        uint256 initialContractBalance = address(lending).balance;

        // Phase 1: Multiple users get scores and borrow
        creditScore.updateUserData(alice, 6000e6, 60); // Score: 650
        creditScore.updateUserData(bob, 4000e6, 40); // Score: 520

        vm.prank(alice);
        lending.borrow();
        
        vm.prank(bob);
        lending.borrow();

        (uint256 aliceLoanAmount, , ) = lending.loans(alice);
        (uint256 bobLoanAmount, , ) = lending.loans(bob);

        uint256 totalLoanedUSD = aliceLoanAmount + bobLoanAmount;
        uint256 totalLoanedETH = (aliceLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD() +
                                (bobLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD();

        assertEq(address(lending).balance, initialContractBalance - totalLoanedETH);

        // Phase 2: Alice repays, Bob doesn't (yet)
        uint256 aliceRepayAmount = (aliceLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        vm.deal(alice, aliceRepayAmount);
        vm.prank(alice);
        lending.repay{value: aliceRepayAmount}();

        // Phase 3: Alice gets score updated and borrows again
        creditScore.updateUserData(alice, 12000e6, 90); // Higher score: 830

        vm.prank(alice);
        lending.borrow();

        (uint256 aliceNewLoanAmount, , ) = lending.loans(alice);
        assertTrue(aliceNewLoanAmount > aliceLoanAmount); // Bigger loan due to higher score

        // Phase 4: Bob finally repays
        uint256 bobRepayAmount = (bobLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        vm.deal(bob, bobRepayAmount);
        vm.prank(bob);
        lending.repay{value: bobRepayAmount}();

        // Phase 5: Verify final state
        (, , bool aliceRepaidStatus) = lending.loans(alice);
        (, , bool bobRepaidStatus) = lending.loans(bob);
        
        assertFalse(aliceRepaidStatus); // Alice has new outstanding loan
        assertTrue(bobRepaidStatus); // Bob repaid his loan

        // Contract should have received both repayments and given out new loan
        uint256 aliceNewLoanETH = (aliceNewLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        uint256 expectedFinalBalance = initialContractBalance - aliceNewLoanETH;
        assertEq(address(lending).balance, expectedFinalBalance);
    }

    // Test error propagation between contracts
    function testErrorPropagationBetweenContracts() public {
        // Deploy lending contract with invalid credit score address
        SimpleLending invalidLending = new SimpleLending(address(0x123));

        // User tries to borrow, should fail when calling creditScore.getScore()
        vm.startPrank(alice);
        vm.expectRevert(); // Will revert when trying to call getScore on invalid address
        invalidLending.borrow();
        vm.stopPrank();
    }

    // Test gas optimization in integrated scenario
    function testGasOptimizationIntegration() public {
        // Set up user
        creditScore.updateUserData(alice, 3000e6, 30);

        // Measure gas for borrow operation
        vm.prank(alice);
        uint256 gasStart = gasleft();
        lending.borrow();
        uint256 gasUsed = gasStart - gasleft();

        // Gas usage should be reasonable (less than 100k gas)
        assertTrue(gasUsed < 100000);

        // Measure gas for repay operation
        (uint256 loanAmount, , ) = lending.loans(alice);
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        
        vm.deal(alice, repayAmountETH);
        vm.prank(alice);
        gasStart = gasleft();
        lending.repay{value: repayAmountETH}();
        gasUsed = gasStart - gasleft();

        // Repay should also be gas efficient
        assertTrue(gasUsed < 50000);
    }
}