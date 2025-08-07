# OKX Credit Score Protocol - Frontend

A modern Next.js application for the OKX Credit Score Protocol, enabling users to build credit scores from DEX trading history and access uncollateralized lending.

## Overview

The frontend provides a comprehensive interface for interacting with the OKX Credit Score Protocol, featuring wallet connection, credit score tracking, and lending functionality. Built with Next.js 14, TypeScript, and modern Web3 technologies.

## Features

- 🔐 **Smart Wallet Integration** - RainbowKit with automatic dashboard redirect
- 📊 **Credit Score Dashboard** - Real-time credit score tracking and visualization  
- 💰 **Lending Interface** - Borrow and repay funds based on credit score
- 🎨 **Modern UI/UX** - Responsive design with Tailwind CSS and gradient animations
- ⚡ **TypeScript Safety** - Full type safety with auto-generated contract types
- 🔄 **Real-time Updates** - Live contract data synchronization
- 📱 **Mobile Responsive** - Optimized for all device sizes
- 🍞 **User Feedback** - Toast notifications for all user actions

## Quick Start

### Prerequisites

- Node.js 18+
- Running Foundry Anvil local node
- Deployed smart contracts
- Backend API server

### Installation

1. **Install dependencies:**
```bash
cd frontend
npm install
```

2. **Configure environment:**
```bash
cp .env.local.example .env.local
```

3. **Update environment variables:**
```env
NEXT_PUBLIC_CREDIT_SCORE_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
NEXT_PUBLIC_LENDING_ADDRESS=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_CHAIN_ID=31337
```

4. **Start development server:**
```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000) to view the application.

## Project Architecture

```
frontend/
├── app/
│   ├── dashboard/
│   │   └── page.tsx           # Dashboard page with credit score and lending
│   ├── layout.tsx             # Root layout with Web3 providers
│   ├── page.tsx               # Landing page with smart wallet redirect
│   └── providers.tsx          # Web3 provider configuration
├── components/
│   ├── ConnectWallet.tsx      # RainbowKit wallet connection
│   ├── CreditScore.tsx        # Credit score display and OKX sync
│   ├── LandingPage.tsx        # Homepage with feature showcase
│   ├── LendingActions.tsx     # Borrow/repay interface
│   ├── FeatureCard.tsx        # Feature highlight cards
│   ├── HowItWorks.tsx         # Process explanation section
│   ├── StatsSection.tsx       # Protocol statistics
│   ├── Logo.tsx               # Animated protocol logo
│   └── DebugInfo.tsx          # Development debugging panel
├── hooks/
│   └── useContracts.ts        # Contract interaction hooks
├── lib/
│   ├── config.ts              # Configuration and ABIs
│   ├── contracts.ts           # Contract address management
│   └── typechain-types/       # Auto-generated contract types
└── styles/
    └── globals.css            # Global styles and animations
```

## Environment Configuration

All environment variables are prefixed with `NEXT_PUBLIC_` for browser availability:

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXT_PUBLIC_CREDIT_SCORE_ADDRESS` | CreditScore contract address | Required |
| `NEXT_PUBLIC_LENDING_ADDRESS` | SimpleLending contract address | Required |
| `NEXT_PUBLIC_API_URL` | Backend API endpoint | `http://localhost:3001` |
| `NEXT_PUBLIC_CHAIN_ID` | Blockchain network ID | `31337` (localhost) |
| `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` | WalletConnect project ID | Optional |

## Development Workflow

### Type Generation

Generate TypeScript contract bindings from Foundry artifacts:

```bash
npm run typechain
```

Or use the convenience script:
```bash
./scripts/update-types.sh
```

### Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run typechain` | Generate contract types |
| `npm run typechain:watch` | Watch and regenerate types |

### Testing Locally

1. **Start Foundry node:**
```bash
cd ../foundry && anvil
```

2. **Deploy contracts:**
```bash
cd ../foundry && ./deploy-local.sh
```

3. **Start backend API:**
```bash
cd ../backend && node server.js
```

4. **Start frontend:**
```bash
npm run dev
```

## User Flow

1. **Landing Page** - Users see protocol features and connect wallet
2. **Auto-Redirect** - Wallet connection automatically redirects to dashboard
3. **Dashboard Access** - View credit score, sync OKX data, borrow funds
4. **Credit Building** - Import trading history to improve credit score
5. **Lending** - Access uncollateralized loans based on credit rating

## Key Components

### ConnectWallet
- RainbowKit integration with custom styling
- Supports both default and custom button variants
- Automatic connection state management

### CreditScore  
- Displays current credit score and rating
- OKX DEX data synchronization
- Real-time score updates

### LendingActions
- Borrow funds interface with amount validation
- Repay loans with balance checking
- Transaction status and confirmation

### LandingPage
- Feature showcase with animated elements
- Responsive hero section
- Statistics and how-it-works sections

## Deployment

### Development
```bash
npm run build
npm run start
```

### Production
1. Configure production environment variables
2. Deploy to Vercel, Netlify, or similar platform
3. Ensure contract addresses match deployed network

## Technology Stack

- **Framework:** Next.js 14 with App Router
- **Language:** TypeScript
- **Styling:** Tailwind CSS with custom animations
- **Web3:** wagmi + viem for contract interactions
- **Wallet:** RainbowKit for wallet connection
- **HTTP Client:** TanStack Query for API calls
- **Notifications:** react-hot-toast
- **Contract Types:** TypeChain for type generation