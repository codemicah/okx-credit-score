#!/bin/bash

# Production deployment script for testnets and mainnet
# Requires .env file with PRIVATE_KEY and RPC URLs

if [ ! -f .env ]; then
    echo "Error: .env file not found. Please copy .env.example to .env and fill in your values."
    exit 1
fi

source .env

if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY not set in .env file"
    exit 1
fi

echo "Choose deployment network:"
echo "1) Sepolia Testnet"
echo "2) Polygon Mainnet" 
echo "3) Arbitrum Mainnet"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        NETWORK="sepolia"
        RPC_URL="$SEPOLIA_RPC_URL"
        ;;
    2)
        NETWORK="polygon"
        RPC_URL="$POLYGON_RPC_URL"
        ;;
    3)
        NETWORK="arbitrum"
        RPC_URL="$ARBITRUM_RPC_URL"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

if [ -z "$RPC_URL" ]; then
    echo "Error: RPC URL for $NETWORK not set in .env file"
    exit 1
fi

echo "Deploying to $NETWORK..."
echo "RPC URL: $RPC_URL"

forge script script/Deploy.s.sol \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  --verify

echo "Deployment to $NETWORK complete!"
