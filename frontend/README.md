# OKX Credit Score - Next.js Frontend

Modern Next.js frontend for the OKX Credit Score Protocol with environment variable support.

## Features

- 🔐 RainbowKit wallet connection
- 🎨 Tailwind CSS for styling
- 📱 Fully responsive design
- 🔄 Real-time contract data updates
- 🍞 Toast notifications
- 🌐 Environment variable configuration
- ⚡ TypeScript for type safety
- 🔨 Foundry integration with TypeChain

## Prerequisites

- Node.js 18+
- Yarn or npm
- Running Foundry Anvil node
- Deployed contracts via Foundry
- Backend API running

## Setup

1. **Install dependencies:**

```bash
cd frontend
npm install
```

2. **Configure environment variables:**

```bash
cp .env.local.example .env.local
```

Update `.env.local` with your contract addresses:

```
NEXT_PUBLIC_CREDIT_SCORE_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
NEXT_PUBLIC_LENDING_ADDRESS=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_CHAIN_ID=31337
```

3. **Run the development server:**

```bash
yarn dev
```

Open [http://localhost:3000](http://localhost:3000)

## Environment Variables

All environment variables are prefixed with `NEXT_PUBLIC_` to make them available in the browser:

- `NEXT_PUBLIC_CREDIT_SCORE_ADDRESS`: Deployed CreditScore contract address
- `NEXT_PUBLIC_LENDING_ADDRESS`: Deployed SimpleLending contract address
- `NEXT_PUBLIC_API_URL`: Backend API URL (default: http://localhost:3001)
- `NEXT_PUBLIC_CHAIN_ID`: Blockchain chain ID (31337 for localhost)
- `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`: Optional WalletConnect project ID

## Project Structure

```
frontend-nextjs/
├── app/
│   ├── layout.tsx      # Root layout with providers
│   ├── page.tsx        # Main page component
│   └── providers.tsx   # Web3 providers setup
├── components/
│   ├── ConnectWallet.tsx   # Wallet connection button
│   ├── CreditScore.tsx     # Credit score display
│   └── LendingActions.tsx  # Borrow/Repay actions
├── hooks/
│   └── useContracts.ts     # Contract interaction hooks
├── lib/
│   └── config.ts           # Configuration and ABIs
└── styles/
    └── globals.css         # Global styles
```

## Development Workflow

### TypeChain Integration

This project uses TypeChain to generate TypeScript bindings from Foundry artifacts:

1. **Regenerate types after contract changes:**

```bash
npm run typechain
```

2. **Or use the convenience script:**

```bash
./scripts/update-types.sh
```

This script will:

- Compile Foundry contracts
- Generate fresh TypeChain types
- Update the frontend type definitions

## Testing

1. **Start local Foundry node:**

```bash
cd ../foundry
anvil
```

2. **Deploy contracts:**

```bash
cd ../foundry
./deploy-local.sh
```

3. **Update `.env.local`** with deployed addresses

4. **Start backend:**

```bash
cd ../backend
node server.js
```

5. **Start Next.js:**

```bash
cd frontend-nextjs
yarn dev
```

6. **Connect wallet** and test functionality

## Build for Production

```bash
yarn build
yarn start
```

## Deployment

For production deployment:

1. Update `.env.production` with mainnet/testnet addresses
2. Build the application
3. Deploy to Vercel, Netlify, or any Next.js hosting platform

## Features Comparison

### Original Frontend

- Vanilla HTML/JS
- Direct ethers.js usage
- Hardcoded addresses
- Basic styling

### Next.js Frontend

- React components
- RainbowKit + wagmi
- Environment variables
- Tailwind CSS
- Server-side rendering
- Type safety
- Better UX with loading states

## Troubleshooting

### Wallet not connecting

- Ensure MetaMask is on the correct network (localhost:8545)
- Check that Foundry Anvil node is running
- Verify contract addresses in `.env.local`

### Transactions failing

- Check backend is running
- Verify contract addresses match deployed contracts
- Ensure wallet has ETH for gas

### Environment variables not loading

- Restart Next.js server after changing `.env.local`
- Ensure variables start with `NEXT_PUBLIC_`
