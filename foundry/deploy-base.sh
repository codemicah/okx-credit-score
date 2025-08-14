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

NETWORK="base-sepolia"
RPC_URL="$BASE_SEPOLIA_RPC_URL"


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
