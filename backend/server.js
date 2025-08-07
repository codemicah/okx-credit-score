const express = require("express");
const axios = require("axios");
const ethers = require("ethers");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// Contract setup
const provider = new ethers.providers.JsonRpcProvider(
  process.env.RPC_URL || "http://127.0.0.1:8545"
);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const creditScoreAddress = process.env.CREDIT_SCORE_ADDRESS;
const creditScoreABI = [
  "function updateUserData(address user, uint256 tradingVolume, uint256 tradeCount) external",
];
const creditScore = new ethers.Contract(
  creditScoreAddress,
  creditScoreABI,
  wallet
);

// OKX DEX API configuration
const OKX_API_KEY = process.env.OKX_API_KEY;
const OKX_BASE_URL =
  process.env.OKX_BASE_URL ||
  "https://web3.okx.com/api/v5/dex/post-transaction";
const CHAIN_ID = process.env.CHAIN_ID || "31337"; // Default to local dev chainId

async function getOKXTradingData(userAddress) {
  try {
    if (process.env.NODE_ENV !== "production") {
      const mockData = {
        volume: userAddress.toLowerCase().includes("dead")
          ? 0
          : Math.floor(Math.random() * 50000) * 1e6, // Random 0-50k USD
        tradeCount: Math.floor(Math.random() * 100), // Random 0-100 trades
      };
      return mockData;
    }

    // Production: Use actual OKX API
    const response = await axios.get(
      `${OKX_BASE_URL}/transactions-by-address`,
      {
        headers: {
          "OK-ACCESS-KEY": OKX_API_KEY,
          "OK-ACCESS-SIGN": process.env.OKX_API_SIGN,
          "OK-ACCESS-TIMESTAMP": new Date(),
          "OK-ACCESS-PASSPHRASE": process.env.OKX_API_PASSPHRASE,
          "Content-Type": "application/json",
        },
        params: {
          address: userAddress,
          chains: CHAIN_ID,
          limit: "100", // Get up to 100 recent transactions
        },
      }
    );

    // Process response to calculate trading metrics
    let totalVolume = 0;
    let tradeCount = 0;

    if (response.data?.data?.[0]?.transactionList) {
      const transactions = response.data.data[0].transactionList;
      tradeCount = transactions.length;

      // Sum up transaction amounts for volume
      transactions.forEach((tx) => {
        if (tx.amount) {
          totalVolume += parseFloat(tx.amount) || 0;
        }
      });
    }

    return {
      volume: totalVolume,
      tradeCount: tradeCount,
    };
  } catch (error) {
    console.error("Error fetching OKX data:", error);
    throw error;
  }
}

// Update credit score endpoint
app.post("/update-score/:address", async (req, res) => {
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
        txHash: tx.hash,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get trading data endpoint
app.get("/trading-data/:address", async (req, res) => {
  try {
    const tradingData = await getOKXTradingData(req.params.address);
    res.json({
      volume: tradingData.volume / 1e6,
      tradeCount: tradingData.tradeCount,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
