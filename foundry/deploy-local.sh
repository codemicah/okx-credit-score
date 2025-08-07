#!/bin/bash

# Deploy contracts to local Anvil network
# Make sure Anvil is running: anvil

echo "Deploying contracts to local Anvil network..."

forge script script/DeployLocal.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast

echo "Deployment complete!"
