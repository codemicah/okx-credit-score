// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CreditScore.sol";
import "../src/SimpleLending.sol";

/**
 * @title TestHelper
 * @dev Helper contract for common test utilities and setup functions
 * Provides reusable functions for test contracts to avoid code duplication
 */
contract TestHelper is Test {
    // Standard test addresses
    address constant ALICE =
        address(0x1111111111111111111111111111111111111111);
    address constant BOB = address(0x2222222222222222222222222222222222222222);
    address constant CHARLIE =
        address(0x3333333333333333333333333333333333333333);
    address constant DAVE = address(0x4444444444444444444444444444444444444444);
    address constant EVE = address(0x5555555555555555555555555555555555555555);

    // Standard test scenarios
    struct TestUser {
        address addr;
        uint256 tradingVolume; // in USD with 6 decimals
        uint256 tradeCount;
        uint256 expectedScore;
        bool eligible; // eligible to borrow
        string name;
    }

    event ScoreUpdated(address indexed user, uint256 score);
    event LoanIssued(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);

    function getStandardTestUsers() internal pure returns (TestUser[5] memory) {
        return [
            TestUser({
                addr: ALICE,
                tradingVolume: 25000e6, // $25k
                tradeCount: 150,
                expectedScore: 1000, // Max score
                eligible: true,
                name: "Alice (Excellent)"
            }),
            TestUser({
                addr: BOB,
                tradingVolume: 8000e6, // $8k
                tradeCount: 40,
                expectedScore: 720, // 200 + 400 + 120
                eligible: true,
                name: "Bob (Good)"
            }),
            TestUser({
                addr: CHARLIE,
                tradingVolume: 1200e6, // $1.2k
                tradeCount: 34,
                expectedScore: 362, // 200 + 60 + 102
                eligible: true,
                name: "Charlie (Average)"
            }),
            TestUser({
                addr: DAVE,
                tradingVolume: 200e6, // $200
                tradeCount: 5,
                expectedScore: 225, // 200 + 10 + 15
                eligible: false,
                name: "Dave (Poor)"
            }),
            TestUser({
                addr: EVE,
                tradingVolume: 0, // No activity
                tradeCount: 0,
                expectedScore: 0,
                eligible: false,
                name: "Eve (None)"
            })
        ];
    }

    function setupStandardUsers(CreditScore creditScore) internal {
        TestUser[5] memory users = getStandardTestUsers();

        for (uint i = 0; i < users.length; i++) {
            if (users[i].tradingVolume > 0 || users[i].tradeCount > 0) {
                creditScore.updateUserData(
                    users[i].addr,
                    users[i].tradingVolume,
                    users[i].tradeCount
                );

                // Verify score calculation
                uint256 actualScore = creditScore.getScore(users[i].addr);
                assertEq(
                    actualScore,
                    users[i].expectedScore,
                    string(
                        abi.encodePacked("Score mismatch for ", users[i].name)
                    )
                );
            }
        }
    }

    function fundUsers(address[] memory users, uint256 amount) internal {
        for (uint i = 0; i < users.length; i++) {
            vm.deal(users[i], amount);
        }
    }

    function fundUser(address user, uint256 amount) internal {
        vm.deal(user, amount);
    }

    function calculateExpectedLoanAmount(
        uint256 creditScore
    ) internal pure returns (uint256) {
        if (creditScore < 300) return 0;
        return (creditScore * 10 * 1e6) / 2; // Credit limit * 50%
    }

    function calculateRepayAmountETH(
        uint256 loanAmountUSD,
        uint256 ethPriceUSD
    ) internal pure returns (uint256) {
        return (loanAmountUSD * 1e12) / ethPriceUSD;
    }

    function deployTestContracts()
        internal
        returns (CreditScore, SimpleLending)
    {
        CreditScore creditScore = new CreditScore();
        SimpleLending lending = new SimpleLending(address(creditScore));

        // Fund lending contract
        vm.deal(address(lending), 100 ether);

        return (creditScore, lending);
    }

    function deployAndSetupTestContracts()
        internal
        returns (CreditScore, SimpleLending)
    {
        (
            CreditScore creditScore,
            SimpleLending lending
        ) = deployTestContracts();
        setupStandardUsers(creditScore);
        return (creditScore, lending);
    }

    // Assertion helpers
    function assertLoanState(
        SimpleLending lending,
        address user,
        uint256 expectedAmount,
        bool expectedRepaidStatus,
        string memory message
    ) internal {
        (uint256 amount, uint256 dueDate, bool repaid) = lending.loans(user);

        assertEq(
            amount,
            expectedAmount,
            string(abi.encodePacked(message, " - amount"))
        );
        assertEq(
            repaid,
            expectedRepaidStatus,
            string(abi.encodePacked(message, " - repaid status"))
        );

        if (expectedAmount > 0 && !expectedRepaidStatus) {
            assertGt(
                dueDate,
                block.timestamp,
                string(
                    abi.encodePacked(message, " - due date should be in future")
                )
            );
        }
    }

    function assertNoLoan(
        SimpleLending lending,
        address user,
        string memory message
    ) internal {
        assertLoanState(lending, user, 0, false, message);
    }

    function assertActiveLoan(
        SimpleLending lending,
        address user,
        uint256 expectedAmount,
        string memory message
    ) internal {
        assertLoanState(lending, user, expectedAmount, false, message);
    }

    function assertRepaidLoan(
        SimpleLending lending,
        address user,
        uint256 expectedAmount,
        string memory message
    ) internal {
        assertLoanState(lending, user, expectedAmount, true, message);
    }

    // Helper to execute full borrow-repay cycle
    function executeBorrowRepayyCycle(
        SimpleLending lending,
        address user,
        string memory userLabel
    ) internal returns (uint256 loanAmount) {
        uint256 userInitialBalance = user.balance;
        uint256 contractInitialBalance = address(lending).balance;

        // Borrow
        vm.prank(user);
        lending.borrow();

        (loanAmount, , ) = lending.loans(user);
        uint256 loanETH = calculateRepayAmountETH(
            loanAmount,
            lending.ETH_PRICE_IN_USD()
        );

        // Verify borrow worked
        assertEq(
            user.balance,
            userInitialBalance + loanETH,
            string(abi.encodePacked(userLabel, " should receive ETH"))
        );
        assertEq(
            address(lending).balance,
            contractInitialBalance - loanETH,
            string(
                abi.encodePacked(
                    "Contract should have less ETH after ",
                    userLabel,
                    " borrow"
                )
            )
        );

        // Fund user for repayment
        vm.deal(user, loanETH);

        // Repay
        vm.prank(user);
        lending.repay{value: loanETH}();

        // Verify repay worked
        assertRepaidLoan(
            lending,
            user,
            loanAmount,
            string(abi.encodePacked(userLabel, " loan should be repaid"))
        );
        assertEq(
            address(lending).balance,
            contractInitialBalance,
            string(
                abi.encodePacked(
                    "Contract balance should be restored after ",
                    userLabel,
                    " repay"
                )
            )
        );
    }

    // Score calculation verification
    function verifyScoreCalculation(
        CreditScore creditScore,
        uint256 volume,
        uint256 trades,
        uint256 expectedScore
    ) internal {
        uint256 calculatedScore = creditScore.calculateScore(volume, trades);
        assertEq(calculatedScore, expectedScore, "Score calculation mismatch");
    }

    // Event testing helpers
    function expectScoreUpdatedEvent(
        address user,
        uint256 expectedScore
    ) internal {
        vm.expectEmit(true, false, false, true);
        emit ScoreUpdated(user, expectedScore);
    }

    function expectLoanIssuedEvent(
        address borrower,
        uint256 expectedAmount
    ) internal {
        vm.expectEmit(true, false, false, true);
        emit LoanIssued(borrower, expectedAmount);
    }

    function expectLoanRepaidEvent(
        address borrower,
        uint256 expectedAmount
    ) internal {
        vm.expectEmit(true, false, false, true);
        emit LoanRepaid(borrower, expectedAmount);
    }

    // Gas testing helper
    function measureGas(
        address target,
        bytes memory data
    ) internal returns (uint256 gasUsed) {
        uint256 gasStart = gasleft();
        (bool success, ) = target.call(data);
        require(success, "Gas measurement call failed");
        gasUsed = gasStart - gasleft();
    }

    // Time manipulation helpers
    function skipTime(uint256 seconds_) internal {
        vm.warp(block.timestamp + seconds_);
    }

    function skipDays(uint256 days_) internal {
        skipTime(days_ * 1 days);
    }

    // Balance helpers
    function getETHBalance(address account) internal view returns (uint256) {
        return account.balance;
    }

    function getContractBalance(
        address contractAddr
    ) internal view returns (uint256) {
        return contractAddr.balance;
    }

    // Debugging helpers
    function logUserState(
        CreditScore creditScore,
        SimpleLending lending,
        address user,
        string memory label
    ) internal view {
        uint256 score = creditScore.getScore(user);
        uint256 volume = creditScore.tradingVolume(user);
        uint256 trades = creditScore.tradeCount(user);
        uint256 lastUpdated = creditScore.lastUpdated(user);

        (uint256 loanAmount, uint256 dueDate, bool repaid) = lending.loans(
            user
        );

        console.log("=== %s State ===", label);
        console.log("Address:", user);
        console.log("ETH Balance:", user.balance);
        console.log("Credit Score:", score);
        console.log("Trading Volume:", volume);
        console.log("Trade Count:", trades);
        console.log("Last Updated:", lastUpdated);
        console.log("Loan Amount:", loanAmount);
        console.log("Due Date:", dueDate);
        console.log("Repaid:", repaid);
        console.log("===============");
    }
}
