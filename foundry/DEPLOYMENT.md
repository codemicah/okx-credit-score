# Contract Deployment Guide

This guide explains how to deploy the CreditScore and SimpleLending contracts using Foundry.

## Prerequisites

1. Install Foundry if not already installed:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Set up environment variables by copying `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and add your:
   - Private key (without 0x prefix)
   - RPC URLs for your target networks
   - Etherscan API keys for contract verification

## Deployment Steps

### 1. Deploy to Local Network (Anvil)

Start a local Anvil node:

```bash
anvil
```

In another terminal, deploy to local network:

```bash
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

### 2. Deploy to Testnet (Sepolia)

```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### 3. Deploy to Mainnet Networks

#### Polygon

```bash
forge script script/Deploy.s.sol --rpc-url $POLYGON_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

#### Arbitrum

```bash
forge script script/Deploy.s.sol --rpc-url $ARBITRUM_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## Contracts Overview

### CreditScore.sol

- Stores credit scores for users based on OKX trading data
- Oracle can update user trading volume and trade count
- Automatically calculates credit score using a simple algorithm

### SimpleLending.sol

- Allows users to borrow based on their credit score
- Minimum score requirement: 300
- Credit limit: score \* $10
- Loan duration: 30 days

## Deployment Output

After successful deployment, you'll see output like:

```
CreditScore deployed at: 0x1234...
SimpleLending deployed at: 0x5678...
```

Save these addresses for frontend integration.

## Verification

Contracts will be automatically verified on Etherscan if you include the `--verify` flag and have the correct API keys set up in your `.env` file.

## Next Steps

1. Update frontend configuration with deployed contract addresses
2. Set up oracle to update credit scores
3. Fund the SimpleLending contract with initial liquidity (if needed)
