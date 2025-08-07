const express = require('express');
const axios = require('axios');
const ethers = require('ethers');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Contract setup
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL || "http://127.0.0.1:8545");
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const creditScoreAddress = process.env.CREDIT_SCORE_ADDRESS;
const creditScoreABI = [
    "function updateUserData(address user, uint256 tradingVolume, uint256 tradeCount) external"
];
const creditScore = new ethers.Contract(creditScoreAddress, creditScoreABI, wallet);

// OKX DEX API configuration
const OKX_API_KEY = process.env.OKX_API_KEY;
const OKX_BASE_URL = 'https://www.okx.com/api/v5/dex/aggregator';

// Fetch OKX trading data (simplified)
async function getOKXTradingData(userAddress) {
    try {
        // In production, use actual OKX API endpoints
        // For demo, return mock data based on address
        const mockData = {
            volume: userAddress.toLowerCase().includes('dead') ? 0 : 
                    Math.floor(Math.random() * 50000) * 1e6, // Random 0-50k USD
            tradeCount: Math.floor(Math.random() * 100) // Random 0-100 trades
        };
        
        // Actual OKX API call would be:
        // const response = await axios.get(`${OKX_BASE_URL}/trades`, {
        //     headers: { 'OK-ACCESS-KEY': OKX_API_KEY },
        //     params: { address: userAddress, chainId: 1 }
        // });
        
        return mockData;
    } catch (error) {
        console.error('Error fetching OKX data:', error);
        throw error;
    }
}

// Update credit score endpoint
app.post('/update-score/:address', async (req, res) => {
    try {
        const userAddress = req.params.address;
        
        // Fetch OKX trading data
        const tradingData = await getOKXTradingData(userAddress);
        
        // Update onchain
        const tx = await creditScore.updateUserData(
            userAddress,
            tradingData.volume,
            tradingData.tradeCount
        );
        
        await tx.wait();
        
        res.json({
            success: true,
            data: {
                address: userAddress,
                volume: tradingData.volume / 1e6, // Convert to USD
                tradeCount: tradingData.tradeCount,
                txHash: tx.hash
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get trading data endpoint
app.get('/trading-data/:address', async (req, res) => {
    try {
        const tradingData = await getOKXTradingData(req.params.address);
        res.json({
            volume: tradingData.volume / 1e6,
            tradeCount: tradingData.tradeCount
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});