// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SimpleLending.sol";
import "../src/CreditScore.sol";

contract SimpleLendingTest is Test {
    SimpleLending public lending;
    CreditScore public creditScore;
    address public owner;
    address public user1;
    address public user2;
    address public lowScoreUser;

    event LoanIssued(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        lowScoreUser = makeAddr("lowScoreUser");

        // Deploy CreditScore first
        creditScore = new CreditScore();

        // Deploy SimpleLending with CreditScore address
        lending = new SimpleLending(address(creditScore));

        // Add some initial liquidity to the contract
        vm.deal(address(lending), 10 ether);

        // Set up users with different credit scores
        creditScore.updateUserData(user1, 5000e6, 50); // Good score: ~650
        creditScore.updateUserData(user2, 10000e6, 100); // Excellent score: 1000
        creditScore.updateUserData(lowScoreUser, 100e6, 1); // Low score: ~208
    }

    // Test constructor
    function testConstructor() public {
        assertEq(address(lending.creditScore()), address(creditScore));
        assertEq(lending.owner(), owner);
        assertEq(lending.MIN_SCORE(), 300);
        assertEq(lending.LOAN_DURATION(), 30 days);
        assertEq(lending.ETH_PRICE_IN_USD(), 3000);
    }

    // Test deposit function
    function testDeposit() public {
        uint256 initialBalance = address(lending).balance;
        uint256 depositAmount = 1 ether;

        vm.deal(user1, depositAmount);
        vm.startPrank(user1);

        lending.deposit{value: depositAmount}();

        vm.stopPrank();

        assertEq(address(lending).balance, initialBalance + depositAmount);
        assertEq(lending.getBalance(), initialBalance + depositAmount);
    }

    function testDepositFromMultipleUsers() public {
        uint256 initialBalance = address(lending).balance;

        // User1 deposits
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        lending.deposit{value: 1 ether}();

        // User2 deposits
        vm.deal(user2, 2 ether);
        vm.prank(user2);
        lending.deposit{value: 0.5 ether}();

        assertEq(address(lending).balance, initialBalance + 1.5 ether);
    }

    // Test withdraw function
    function testWithdraw_OnlyOwner() public {
        uint256 withdrawAmount = 1 ether;
        uint256 initialBalance = address(lending).balance;
        uint256 ownerInitialBalance = owner.balance;

        lending.withdraw(withdrawAmount);

        assertEq(address(lending).balance, initialBalance - withdrawAmount);
        assertEq(owner.balance, ownerInitialBalance + withdrawAmount);
    }

    function testWithdraw_NonOwner() public {
        vm.startPrank(user1);

        vm.expectRevert("Not the owner");
        lending.withdraw(1 ether);

        vm.stopPrank();
    }

    function testWithdraw_InsufficientBalance() public {
        uint256 contractBalance = address(lending).balance;
        uint256 withdrawAmount = contractBalance + 1 ether;

        vm.expectRevert("Insufficient balance");
        lending.withdraw(withdrawAmount);
    }

    function testWithdraw_ExactBalance() public {
        uint256 contractBalance = address(lending).balance;
        uint256 ownerInitialBalance = owner.balance;

        lending.withdraw(contractBalance);

        assertEq(address(lending).balance, 0);
        assertEq(owner.balance, ownerInitialBalance + contractBalance);
    }

    // Test getBalance function
    function testGetBalance() public {
        uint256 expectedBalance = address(lending).balance;
        assertEq(lending.getBalance(), expectedBalance);

        // Add more funds and test again
        vm.deal(address(lending), expectedBalance + 5 ether);
        assertEq(lending.getBalance(), expectedBalance + 5 ether);
    }

    // Test borrow function
    function testBorrow_Success() public {
        uint256 user1Score = creditScore.getScore(user1);
        assertTrue(user1Score >= lending.MIN_SCORE());

        uint256 expectedCreditLimit = user1Score * 10 * 1e6; // Score * $10
        uint256 expectedLoanAmountUSD = expectedCreditLimit / 2; // 50% of limit
        uint256 expectedLoanAmountETH = (expectedLoanAmountUSD * 1e12) / lending.ETH_PRICE_IN_USD();

        uint256 userInitialBalance = user1.balance;
        uint256 contractInitialBalance = address(lending).balance;

        vm.expectEmit(true, false, false, true);
        emit LoanIssued(user1, expectedLoanAmountUSD);

        vm.prank(user1);
        lending.borrow();

        // Check loan was recorded
        (uint256 amount, uint256 dueDate, bool repaid) = lending.loans(user1);
        assertEq(amount, expectedLoanAmountUSD);
        assertEq(dueDate, block.timestamp + lending.LOAN_DURATION());
        assertFalse(repaid);

        // Check ETH was transferred
        assertEq(user1.balance, userInitialBalance + expectedLoanAmountETH);
        assertEq(address(lending).balance, contractInitialBalance - expectedLoanAmountETH);
    }

    function testBorrow_HighScoreUser() public {
        uint256 user2Score = creditScore.getScore(user2); // Should be 1000 (max)
        assertEq(user2Score, 1000);

        uint256 expectedCreditLimit = 1000 * 10 * 1e6; // $10,000
        uint256 expectedLoanAmountUSD = expectedCreditLimit / 2; // $5,000
        uint256 expectedLoanAmountETH = (expectedLoanAmountUSD * 1e12) / 3000; // ~1.67 ETH

        vm.prank(user2);
        lending.borrow();

        (uint256 amount, , ) = lending.loans(user2);
        assertEq(amount, expectedLoanAmountUSD);
        assertEq(user2.balance, expectedLoanAmountETH);
    }

    function testBorrow_ScoreTooLow() public {
        uint256 lowScore = creditScore.getScore(lowScoreUser);
        assertTrue(lowScore < lending.MIN_SCORE());

        vm.startPrank(lowScoreUser);

        vm.expectRevert("Score too low");
        lending.borrow();

        vm.stopPrank();

        // Verify no loan was created
        (uint256 amount, , ) = lending.loans(lowScoreUser);
        assertEq(amount, 0);
    }

    function testBorrow_ExistingLoan() public {
        // First borrow
        vm.prank(user1);
        lending.borrow();

        // Try to borrow again
        vm.startPrank(user1);

        vm.expectRevert("Existing loan");
        lending.borrow();

        vm.stopPrank();
    }

    function testBorrow_InsufficientContractFunds() public {
        // Drain the contract
        uint256 contractBalance = address(lending).balance;
        lending.withdraw(contractBalance);
        assertEq(address(lending).balance, 0);

        vm.startPrank(user1);

        vm.expectRevert("Insufficient funds in contract");
        lending.borrow();

        vm.stopPrank();
    }

    function testBorrow_AfterRepayment() public {
        // First borrow
        vm.prank(user1);
        lending.borrow();

        // Get loan details
        (uint256 amount, , ) = lending.loans(user1);
        uint256 repayAmountETH = (amount * 1e12) / lending.ETH_PRICE_IN_USD();

        // Repay
        vm.deal(user1, repayAmountETH);
        vm.prank(user1);
        lending.repay{value: repayAmountETH}();

        // Should be able to borrow again
        vm.prank(user1);
        lending.borrow();

        // Verify new loan exists
        (uint256 newAmount, , bool repaid) = lending.loans(user1);
        assertGt(newAmount, 0);
        assertFalse(repaid);
    }

    // Test repay function
    function testRepay_Success() public {
        // First borrow
        vm.prank(user1);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(user1);
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        uint256 contractInitialBalance = address(lending).balance;

        // Repay
        vm.deal(user1, repayAmountETH);

        vm.expectEmit(true, false, false, true);
        emit LoanRepaid(user1, loanAmount);

        vm.prank(user1);
        lending.repay{value: repayAmountETH}();

        // Check loan is marked as repaid
        (, , bool repaid) = lending.loans(user1);
        assertTrue(repaid);

        // Check contract received the payment
        assertEq(address(lending).balance, contractInitialBalance + repayAmountETH);
    }

    function testRepay_NoLoan() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        vm.expectRevert("No loan");
        lending.repay{value: 1 ether}();

        vm.stopPrank();
    }

    function testRepay_AlreadyRepaid() public {
        // Borrow and repay
        vm.prank(user1);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(user1);
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();

        vm.deal(user1, repayAmountETH);
        vm.prank(user1);
        lending.repay{value: repayAmountETH}();

        // Try to repay again
        vm.deal(user1, repayAmountETH);
        vm.startPrank(user1);

        vm.expectRevert("Already repaid");
        lending.repay{value: repayAmountETH}();

        vm.stopPrank();
    }

    function testRepay_InsufficientPayment() public {
        // Borrow
        vm.prank(user1);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(user1);
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        uint256 insufficientAmount = repayAmountETH - 1;

        vm.deal(user1, insufficientAmount);
        vm.startPrank(user1);

        vm.expectRevert("Insufficient payment");
        lending.repay{value: insufficientAmount}();

        vm.stopPrank();
    }

    function testRepay_ExactPayment() public {
        vm.prank(user1);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(user1);
        uint256 exactRepayAmount = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();

        vm.deal(user1, exactRepayAmount);
        vm.prank(user1);
        lending.repay{value: exactRepayAmount}();

        (, , bool repaid) = lending.loans(user1);
        assertTrue(repaid);
    }

    function testRepay_OverPayment() public {
        vm.prank(user1);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(user1);
        uint256 repayAmountETH = (loanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        uint256 overpayAmount = repayAmountETH + 0.1 ether;

        vm.deal(user1, overpayAmount);
        vm.prank(user1);
        lending.repay{value: overpayAmount}();

        (, , bool repaid) = lending.loans(user1);
        assertTrue(repaid);
    }

    // Test loan structure and calculations
    function testLoanCalculations() public {
        uint256 userScore = 600;
        
        // Update user with specific score
        creditScore.updateUserData(user1, 4000e6, 40); // Should give ~600 score
        uint256 actualScore = creditScore.getScore(user1);

        vm.prank(user1);
        lending.borrow();

        (uint256 loanAmountUSD, uint256 dueDate, bool repaid) = lending.loans(user1);

        uint256 expectedCreditLimit = actualScore * 10 * 1e6;
        uint256 expectedLoanAmount = expectedCreditLimit / 2;

        assertEq(loanAmountUSD, expectedLoanAmount);
        assertEq(dueDate, block.timestamp + 30 days);
        assertFalse(repaid);
    }

    // Test multiple users borrowing
    function testMultipleUsersBorrowing() public {
        uint256 contractInitialBalance = address(lending).balance;

        // User1 borrows
        vm.prank(user1);
        lending.borrow();

        (uint256 loan1Amount, , ) = lending.loans(user1);
        uint256 loan1ETH = (loan1Amount * 1e12) / lending.ETH_PRICE_IN_USD();

        // User2 borrows
        vm.prank(user2);
        lending.borrow();

        (uint256 loan2Amount, , ) = lending.loans(user2);
        uint256 loan2ETH = (loan2Amount * 1e12) / lending.ETH_PRICE_IN_USD();

        // Check contract balance decreased by both loans
        assertEq(address(lending).balance, contractInitialBalance - loan1ETH - loan2ETH);

        // Check both loans exist
        assertGt(loan1Amount, 0);
        assertGt(loan2Amount, 0);
    }

    // Test receive function
    function testReceiveFunction() public {
        uint256 initialBalance = address(lending).balance;
        uint256 sendAmount = 1 ether;

        vm.deal(user1, sendAmount);
        vm.prank(user1);
        (bool success, ) = address(lending).call{value: sendAmount}("");

        assertTrue(success);
        assertEq(address(lending).balance, initialBalance + sendAmount);
    }

    // Test ERC20-like functions (should return empty/zero values)
    function testERC20StubFunctions() public {
        assertEq(lending.decimals(), 0);
        assertEq(lending.symbol(), "");
        assertEq(lending.name(), "");
        assertEq(lending.balanceOf(user1), 0);
        assertEq(lending.totalSupply(), 0);
        assertFalse(lending.supportsInterface(bytes4(0x12345678)));
    }

    // Integration test with changing credit scores
    function testBorrowingWithScoreChanges() public {
        // Initial score allows borrowing
        uint256 initialScore = creditScore.getScore(user1);
        assertTrue(initialScore >= lending.MIN_SCORE());

        vm.prank(user1);
        lending.borrow();

        (uint256 initialLoanAmount, , ) = lending.loans(user1);
        assertGt(initialLoanAmount, 0);

        // Repay the loan
        uint256 repayAmountETH = (initialLoanAmount * 1e12) / lending.ETH_PRICE_IN_USD();
        vm.deal(user1, repayAmountETH);
        vm.prank(user1);
        lending.repay{value: repayAmountETH}();

        // Increase credit score
        creditScore.updateUserData(user1, 20000e6, 200); // Higher score
        uint256 newScore = creditScore.getScore(user1);
        assertTrue(newScore > initialScore);

        // Borrow again with higher limit
        vm.prank(user1);
        lending.borrow();

        (uint256 newLoanAmount, , ) = lending.loans(user1);
        assertGt(newLoanAmount, initialLoanAmount);
    }

    // Fuzz tests
    function testFuzz_BorrowWithDifferentScores(uint256 volume, uint256 trades) public {
        volume = bound(volume, 1000e6, 100000e6); // $1k to $100k
        trades = bound(trades, 10, 1000); // 10 to 1000 trades

        address fuzzUser = makeAddr("fuzzUser");
        creditScore.updateUserData(fuzzUser, volume, trades);

        uint256 score = creditScore.getScore(fuzzUser);

        if (score >= lending.MIN_SCORE()) {
            uint256 contractBalance = address(lending).balance;
            uint256 expectedLoanUSD = (score * 10 * 1e6) / 2;
            uint256 expectedLoanETH = (expectedLoanUSD * 1e12) / lending.ETH_PRICE_IN_USD();

            if (contractBalance >= expectedLoanETH) {
                vm.prank(fuzzUser);
                lending.borrow();

                (uint256 loanAmount, , bool repaid) = lending.loans(fuzzUser);
                assertEq(loanAmount, expectedLoanUSD);
                assertFalse(repaid);
            }
        }
    }

    // Test edge cases
    function testEdgeCase_MinimumScore() public {
        // Create user with exactly minimum score (300)
        address minScoreUser = makeAddr("minScoreUser");
        creditScore.updateUserData(minScoreUser, 1000e6, 0); // Should give exactly 250, need to adjust
        
        // Adjust to get exactly 300
        creditScore.updateUserData(minScoreUser, 2000e6, 0); // 200 + 100 + 0 = 300

        uint256 score = creditScore.getScore(minScoreUser);
        assertEq(score, 300);

        vm.prank(minScoreUser);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(minScoreUser);
        assertEq(loanAmount, 1500e6); // 300 * 10 / 2 = $1500
    }

    function testEdgeCase_MaximumScore() public {
        // User2 should have max score (1000)
        uint256 maxScore = creditScore.getScore(user2);
        assertEq(maxScore, 1000);

        vm.prank(user2);
        lending.borrow();

        (uint256 loanAmount, , ) = lending.loans(user2);
        assertEq(loanAmount, 5000e6); // 1000 * 10 / 2 = $5000
    }

    function testEdgeCase_LoanDueDate() public {
        uint256 borrowTime = block.timestamp;
        
        vm.prank(user1);
        lending.borrow();

        (, uint256 dueDate, ) = lending.loans(user1);
        assertEq(dueDate, borrowTime + 30 days);
    }
}