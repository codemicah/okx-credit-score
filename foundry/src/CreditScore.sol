// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CreditScore {
    // Simple credit score storage
    mapping(address => uint256) public scores;
    mapping(address => uint256) public lastUpdated;
    
    // OKX trading data
    mapping(address => uint256) public tradingVolume;
    mapping(address => uint256) public tradeCount;
    
    address public oracle;
    uint256 public constant MAX_SCORE = 1000;
    
    event ScoreUpdated(address indexed user, uint256 score);
    
    modifier onlyOracle() {
        require(msg.sender == oracle, "Only oracle");
        _;
    }
    
    constructor() {
        oracle = msg.sender;
    }
    
    function updateUserData(
        address user,
        uint256 _tradingVolume,
        uint256 _tradeCount
    ) external onlyOracle {
        tradingVolume[user] = _tradingVolume;
        tradeCount[user] = _tradeCount;
        
        // Simple scoring algorithm
        uint256 score = calculateScore(_tradingVolume, _tradeCount);
        scores[user] = score;
        lastUpdated[user] = block.timestamp;
        
        emit ScoreUpdated(user, score);
    }
    
    function calculateScore(
        uint256 _tradingVolume,
        uint256 _tradeCount
    ) public pure returns (uint256) {
        // Simple formula: 
        // - Trading volume (0-500 points): $1000 = 50 points
        // - Trade count (0-300 points): 10 trades = 30 points
        // - Base score: 200 points for having activity
        
        uint256 volumeScore = (_tradingVolume / 1000e6) * 50; // $1000 = 50 points
        if (volumeScore > 500) volumeScore = 500;
        
        uint256 tradeScore = _tradeCount * 3; // 1 trade = 3 points
        if (tradeScore > 300) tradeScore = 300;
        
        uint256 baseScore = (_tradingVolume > 0) ? 200 : 0;
        
        return baseScore + volumeScore + tradeScore;
    }
    
    function getScore(address user) external view returns (uint256) {
        return scores[user];
    }
}