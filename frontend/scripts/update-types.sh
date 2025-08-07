#!/bin/bash

# Script to regenerate TypeChain types after Foundry compilation
echo "🔨 Compiling Foundry contracts..."
cd ../foundry && forge build

echo "📦 Generating TypeChain types..."
cd ../frontend && npm run typechain

echo "✅ TypeChain types regenerated successfully!"
echo "📁 Generated files are in: frontend/lib/typechain-types/"
