# OKX Credit Score Protocol

> **Decentralized Credit Scoring Protocol powered by OKX DEX Trading History**

A comprehensive DeFi protocol that enables users to build onchain credit scores from their OKX DEX trading history and access uncollateralized lending based on their proven track record.

[![Built for EthCC 2025](https://img.shields.io/badge/Built%20for-EthCC%202025-purple)](https://ethcc.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 🚀 Overview

The OKX Credit Score Protocol revolutionizes DeFi lending by creating verifiable credit scores based on real DEX trading activity. Users can import their OKX trading history to build credit scores onchain, then access uncollateralized loans proportional to their trading reputation.

### Key Innovation

- **First-of-its-kind**: Decentralized credit scoring using real DEX trading data
- **No Collateral Required**: Borrow based purely on trading reputation
- **Transparent & Fair**: All scores and lending terms are publicly verifiable
- **Real-time Updates**: Sync trading activity and update scores instantly

## ✨ Features

### 🏦 For Borrowers
- **Build Credit Score** - Import OKX DEX trading history to establish creditworthiness
- **Uncollateralized Loans** - Access loans up to 10x your credit score (in USD)
- **Flexible Terms** - 30-day loan duration with competitive rates
- **Real-time Tracking** - Monitor credit score changes and loan status

### 💰 For Lenders
- **Risk Assessment** - Transparent credit scores based on verifiable trading data
- **Automated Lending** - Smart contracts handle loan issuance and repayment
- **Yield Generation** - Earn returns from uncollateralized lending

### 🔧 For Developers
- **Full-stack Protocol** - Smart contracts, API, and frontend components
- **Modern Tech Stack** - Solidity, Node.js, Next.js, TypeScript
- **Extensible Architecture** - Easy integration with other DEX data sources

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │ Smart Contracts │
│   (Next.js)     │    │   (Node.js)     │    │   (Solidity)    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Landing Page  │◄──►│ • OKX DEX API   │◄──►│ • CreditScore   │
│ • Dashboard     │    │ • Data Processing│    │ • SimpleLending │
│ • Wallet Connect│    │ • Blockchain TX │    │ • Oracle Updates│
│ • Lending UI    │    │ • CORS/Security │    │ • Loan Logic    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   OKX DEX API   │
                    │ (Trading Data)  │
                    └─────────────────┘
```

### Data Flow

1. **User connects wallet** → Frontend redirects to dashboard
2. **User requests credit update** → Backend fetches OKX trading data
3. **Backend processes data** → Updates credit score onchain via smart contract
4. **User views updated score** → Frontend displays new credit rating
5. **User borrows funds** → Smart contract validates score and issues loan

## 🚀 Quick Start

Get the entire protocol running locally in minutes:

### Prerequisites

- Node.js 18+
- Foundry (for smart contracts)
- Git

### One-Command Setup

```bash
# Clone the repository
git clone <repository-url>
cd okx-credit-score-protocol

# Install all dependencies and start local development
./scripts/dev-setup.sh
```

This will:
- Install dependencies for all components
- Start local Anvil blockchain
- Deploy smart contracts
- Start backend API server
- Launch frontend development server

Visit [http://localhost:3000](http://localhost:3000) to see the application.

## 📁 Project Structure

```
okx-credit-score-protocol/
├── foundry/                    # Smart Contracts (Solidity + Foundry)
│   ├── src/
│   │   ├── CreditScore.sol     # Credit scoring logic
│   │   └── SimpleLending.sol   # Lending protocol
│   ├── script/                 # Deployment scripts
│   ├── test/                   # Contract tests
│   └── README.md              # Contract documentation
│
├── backend/                    # Backend API (Node.js + Express)
│   ├── server.js              # Main API server
│   ├── package.json           # Dependencies
│   └── README.md              # API documentation
│
├── frontend/                   # Frontend App (Next.js + TypeScript)
│   ├── app/                   # Next.js app router
│   │   ├── page.tsx           # Landing page
│   │   └── dashboard/         # Dashboard interface
│   ├── components/            # React components
│   ├── lib/                   # Utilities and contract types
│   └── README.md              # Frontend documentation
│
└── README.md                   # This file
```

## 🛠️ Development Setup

### 1. Smart Contracts (Foundry)

```bash
cd foundry

# Install Foundry dependencies
forge install

# Start local blockchain
anvil

# Deploy contracts (in another terminal)
./deploy-local.sh

# Run tests
forge test
```

### 2. Backend API

```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with deployed contract addresses

# Start server
node server.js
```

### 3. Frontend Application

```bash
cd frontend

# Install dependencies
npm install

# Configure environment
cp .env.local.example .env.local
# Edit .env.local with contract addresses and API URL

# Start development server
npm run dev
```

## 🌐 Deployment

### Local Development
- **Blockchain**: Anvil (localhost:8545)
- **Backend**: localhost:3001
- **Frontend**: localhost:3000

### Testnet Deployment
- **Contracts**: Deploy to Sepolia or Polygon Mumbai
- **Backend**: Deploy to Railway, Render, or AWS
- **Frontend**: Deploy to Vercel or Netlify

### Production
- **Contracts**: Deploy to Polygon, Arbitrum, or Ethereum mainnet
- **Backend**: Production server with proper monitoring
- **Frontend**: CDN deployment with custom domain

## 📊 Technology Stack

### Smart Contracts
- **Solidity** - Contract development language
- **Foundry** - Development framework and testing
- **OpenZeppelin** - Security and standard implementations

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **ethers.js** - Blockchain interactions
- **Axios** - HTTP client for OKX API

### Frontend
- **Next.js 14** - React framework with App Router
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling framework
- **wagmi + viem** - Web3 React hooks
- **RainbowKit** - Wallet connection UI

### Infrastructure
- **OKX DEX API** - Trading data source
- **Anvil/Hardhat** - Local blockchain development
- **Vercel/Netlify** - Frontend hosting
- **Railway/Render** - Backend hosting

## 🧪 Testing

### Smart Contracts
```bash
cd foundry
forge test -vvv
```

### Backend API
```bash
cd backend
# Test endpoints with curl
curl http://localhost:3001/trading-data/0x123...
```

### Frontend
```bash
cd frontend
npm run build
npm run lint
```

### Integration Testing
```bash
# Start all services
./scripts/start-all.sh

# Run integration tests
./scripts/test-integration.sh
```

## 📚 Documentation

- **[Smart Contracts](./foundry/README.md)** - Contract architecture and deployment
- **[Backend API](./backend/README.md)** - API endpoints and integration
- **[Frontend App](./frontend/README.md)** - UI components and user flows
- **[Deployment Guide](./foundry/DEPLOYMENT.md)** - Production deployment steps

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and add tests
4. **Run the test suite**: `npm test` (in each component)
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines

- Follow existing code style and conventions
- Add tests for new features
- Update documentation for API changes
- Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Built for EthCC 2025

This project was created for the EthCC 2025 Hackathon, demonstrating the power of combining real-world trading data with decentralized lending protocols.

### Team
- Smart Contract Development
- Backend API Integration  
- Frontend UI/UX Design
- OKX DEX Data Integration

## 🔗 Links

- **Live Demo**: [https://okx-credit-protocol.vercel.app](https://okx-credit-protocol.vercel.app)
- **Documentation**: [https://docs.okx-credit.com](https://docs.okx-credit.com)
- **EthCC Presentation**: [https://ethcc.io/presentations/okx-credit](https://ethcc.io/presentations/okx-credit)

---

**Disclaimer**: This is a hackathon project for demonstration purposes. Use at your own risk and conduct proper security audits before any production deployment.