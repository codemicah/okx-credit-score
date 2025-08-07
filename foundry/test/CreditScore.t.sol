// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CreditScore.sol";

contract CreditScoreTest is Test {
    CreditScore public creditScore;
    address public oracle;
    address public user1;
    address public user2;
    address public nonOracle;

    event ScoreUpdated(address indexed user, uint256 score);

    function setUp() public {
        oracle = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nonOracle = makeAddr("nonOracle");

        creditScore = new CreditScore();
        
        // Verify oracle is set correctly
        assertEq(creditScore.oracle(), oracle);
    }

    // Test constructor
    function testConstructor() public {
        assertEq(creditScore.oracle(), address(this));
        assertEq(creditScore.MAX_SCORE(), 1000);
    }

    // Test calculateScore function - pure function testing
    function testCalculateScore_ZeroValues() public {
        uint256 score = creditScore.calculateScore(0, 0);
        assertEq(score, 0); // No base score for zero volume
    }

    function testCalculateScore_BaseScore() public {
        uint256 score = creditScore.calculateScore(1e6, 1); // $1 volume, 1 trade
        assertEq(score, 200 + 0 + 3); // Base (200) + Volume (0) + Trades (3)
        assertEq(score, 203);
    }

    function testCalculateScore_VolumeScoring() public {
        // Test volume scoring: $1000 = 50 points
        uint256 score1 = creditScore.calculateScore(1000e6, 0); // $1000 volume
        assertEq(score1, 200 + 50 + 0); // Base + Volume + Trades
        assertEq(score1, 250);

        uint256 score2 = creditScore.calculateScore(10000e6, 0); // $10000 volume
        assertEq(score2, 200 + 500 + 0); // Volume capped at 500
        assertEq(score2, 700);
    }

    function testCalculateScore_TradeCountScoring() public {
        // Test trade count: 1 trade = 3 points
        uint256 score1 = creditScore.calculateScore(1e6, 10); // 10 trades
        assertEq(score1, 200 + 0 + 30); // Base + Volume + Trades
        assertEq(score1, 230);

        uint256 score2 = creditScore.calculateScore(1e6, 100); // 100 trades
        assertEq(score2, 200 + 0 + 300); // Trades capped at 300
        assertEq(score2, 500);

        uint256 score3 = creditScore.calculateScore(1e6, 200); // 200 trades (over cap)
        assertEq(score3, 200 + 0 + 300); // Still capped at 300
        assertEq(score3, 500);
    }

    function testCalculateScore_MaxScore() public {
        // Test maximum possible score
        uint256 score = creditScore.calculateScore(50000e6, 200); // High volume and trades
        assertEq(score, 200 + 500 + 300); // Base + Max Volume + Max Trades
        assertEq(score, 1000);
        assertEq(score, creditScore.MAX_SCORE());
    }

    function testCalculateScore_MixedScenarios() public {
        // Realistic trading scenarios
        uint256 score1 = creditScore.calculateScore(5000e6, 25); // $5000, 25 trades
        assertEq(score1, 200 + 250 + 75);
        assertEq(score1, 525);

        uint256 score2 = creditScore.calculateScore(500e6, 5); // $500, 5 trades
        assertEq(score2, 200 + 25 + 15);
        assertEq(score2, 240);
    }

    // Test updateUserData function
    function testUpdateUserData_Success() public {
        uint256 volume = 2000e6; // $2000
        uint256 trades = 20;
        uint256 expectedScore = 200 + 100 + 60; // 360

        vm.expectEmit(true, false, false, true);
        emit ScoreUpdated(user1, expectedScore);

        creditScore.updateUserData(user1, volume, trades);

        assertEq(creditScore.scores(user1), expectedScore);
        assertEq(creditScore.tradingVolume(user1), volume);
        assertEq(creditScore.tradeCount(user1), trades);
        assertEq(creditScore.lastUpdated(user1), block.timestamp);
    }

    function testUpdateUserData_MultipleUsers() public {
        // Update user1
        creditScore.updateUserData(user1, 1000e6, 10);
        assertEq(creditScore.scores(user1), 280); // 200 + 50 + 30

        // Update user2
        creditScore.updateUserData(user2, 3000e6, 30);
        assertEq(creditScore.scores(user2), 440); // 200 + 150 + 90

        // Verify user1 data unchanged
        assertEq(creditScore.scores(user1), 280);
        assertEq(creditScore.tradingVolume(user1), 1000e6);
        assertEq(creditScore.tradeCount(user1), 10);
    }

    function testUpdateUserData_UpdateExistingUser() public {
        // Initial update
        creditScore.updateUserData(user1, 1000e6, 10);
        assertEq(creditScore.scores(user1), 280);

        // Update same user with new data
        uint256 newVolume = 5000e6;
        uint256 newTrades = 50;
        uint256 newExpectedScore = 200 + 250 + 150; // 600

        vm.expectEmit(true, false, false, true);
        emit ScoreUpdated(user1, newExpectedScore);

        creditScore.updateUserData(user1, newVolume, newTrades);

        assertEq(creditScore.scores(user1), newExpectedScore);
        assertEq(creditScore.tradingVolume(user1), newVolume);
        assertEq(creditScore.tradeCount(user1), newTrades);
    }

    function testUpdateUserData_OnlyOracle() public {
        vm.startPrank(nonOracle);
        
        vm.expectRevert("Only oracle");
        creditScore.updateUserData(user1, 1000e6, 10);
        
        vm.stopPrank();
    }

    function testUpdateUserData_ZeroAddress() public {
        // Should allow zero address (testing edge case)
        creditScore.updateUserData(address(0), 1000e6, 10);
        assertEq(creditScore.scores(address(0)), 280);
    }

    // Test getScore function
    function testGetScore_InitiallyZero() public {
        assertEq(creditScore.getScore(user1), 0);
        assertEq(creditScore.getScore(user2), 0);
        assertEq(creditScore.getScore(address(0)), 0);
    }

    function testGetScore_AfterUpdate() public {
        creditScore.updateUserData(user1, 2000e6, 20);
        assertEq(creditScore.getScore(user1), 360); // 200 + 100 + 60

        // Other users still zero
        assertEq(creditScore.getScore(user2), 0);
    }

    // Test storage mappings directly
    function testStorageMappings() public {
        creditScore.updateUserData(user1, 1500e6, 15);

        // Test all public mappings
        assertEq(creditScore.scores(user1), 320); // 200 + 75 + 45
        assertEq(creditScore.lastUpdated(user1), block.timestamp);
        assertEq(creditScore.tradingVolume(user1), 1500e6);
        assertEq(creditScore.tradeCount(user1), 15);
    }

    // Test timestamp updates
    function testTimestampUpdates() public {
        uint256 startTime = block.timestamp;
        
        creditScore.updateUserData(user1, 1000e6, 10);
        assertEq(creditScore.lastUpdated(user1), startTime);

        // Move time forward and update again
        vm.warp(startTime + 1 days);
        creditScore.updateUserData(user1, 2000e6, 20);
        assertEq(creditScore.lastUpdated(user1), startTime + 1 days);
    }

    // Test event emissions
    function testEventEmissions() public {
        uint256 expectedScore = 280; // 200 + 50 + 30

        vm.expectEmit(true, false, false, true);
        emit ScoreUpdated(user1, expectedScore);

        creditScore.updateUserData(user1, 1000e6, 10);
    }

    // Fuzz tests
    function testFuzz_CalculateScore(uint256 volume, uint256 trades) public {
        // Bound inputs to reasonable ranges to avoid overflow
        volume = bound(volume, 0, 1000000e6); // Up to $1M
        trades = bound(trades, 0, 10000); // Up to 10k trades

        uint256 score = creditScore.calculateScore(volume, trades);

        // Score should never exceed maximum
        assertTrue(score <= creditScore.MAX_SCORE());

        // If volume > 0, should have base score
        if (volume > 0) {
            assertTrue(score >= 200);
        } else {
            assertEq(score, 0);
        }
    }

    function testFuzz_UpdateUserData(address user, uint256 volume, uint256 trades) public {
        // Bound inputs
        vm.assume(user != address(0)); // Avoid zero address for cleaner testing
        volume = bound(volume, 1, 1000000e6);
        trades = bound(trades, 0, 10000);

        uint256 expectedScore = creditScore.calculateScore(volume, trades);

        creditScore.updateUserData(user, volume, trades);

        assertEq(creditScore.getScore(user), expectedScore);
        assertEq(creditScore.tradingVolume(user), volume);
        assertEq(creditScore.tradeCount(user), trades);
        assertEq(creditScore.lastUpdated(user), block.timestamp);
    }

    // Edge case tests
    function testEdgeCase_MaxUint256Values() public {
        // Test with maximum values (should not overflow with Solidity 0.8+)
        uint256 maxVolume = type(uint256).max;
        uint256 maxTrades = type(uint256).max;

        // This should not revert due to overflow protection in 0.8+
        uint256 score = creditScore.calculateScore(maxVolume, maxTrades);
        assertEq(score, 1000); // Should be capped at MAX_SCORE
    }

    function testEdgeCase_PrecisionBoundaries() public {
        // Test around precision boundaries
        uint256 score999 = creditScore.calculateScore(999e6, 0); // Just under $1000
        uint256 score1000 = creditScore.calculateScore(1000e6, 0); // Exactly $1000
        uint256 score1001 = creditScore.calculateScore(1001e6, 0); // Just over $1000

        assertEq(score999, 200 + 49 + 0); // 249 (999/1000 * 50 = 49.95 -> 49)
        assertEq(score1000, 200 + 50 + 0); // 250
        assertEq(score1001, 200 + 50 + 0); // 250 (1001/1000 * 50 = 50.05 -> 50)
    }
}