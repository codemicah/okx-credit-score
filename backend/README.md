# OKX Credit Score Protocol - Backend API

Node.js Express server providing API endpoints for OKX trading data integration and smart contract interactions for the OKX Credit Score Protocol.

## Overview

The backend serves as a bridge between the frontend application and external data sources, primarily handling OKX DEX trading data retrieval and updating onchain credit scores. Built with Express.js and ethers.js for blockchain interactions.

## Features

- 🔗 **OKX DEX Integration** - Fetches real trading data from OKX DEX API
- 📊 **Credit Score Updates** - Updates user credit scores onchain based on trading history
- 🔐 **Secure Transactions** - Handles blockchain transactions with private key management
- 🌐 **CORS Enabled** - Supports cross-origin requests from frontend
- 📡 **RESTful API** - Clean REST endpoints for data retrieval and updates
- 🔧 **Environment Configuration** - Flexible configuration via environment variables

## Quick Start

### Prerequisites

- Node.js 16+
- Deployed CreditScore smart contract
- OKX DEX API access (for production)
- Ethereum RPC endpoint (Alchemy, Infura, or local node)

### Installation

1. **Install dependencies:**

```bash
cd backend
npm install
```

2. **Configure environment:**

```bash
cp .env.example .env
```

3. **Update environment variables:**

```env
RPC_URL=http://127.0.0.1:8545
PRIVATE_KEY=your_wallet_private_key_here
CREDIT_SCORE_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
OKX_API_KEY=your_okx_api_key_here
OKX_BASE_URL=https://web3.okx.com/api/v5/dex/post-transaction
CHAIN_ID=31337
NODE_ENV=development
PORT=3001
```

4. **Start the server:**

```bash
node server.js
```

Server will be running at [http://localhost:3001](http://localhost:3001)

## API Endpoints

### POST `/update-score/:address`

Updates a user's credit score onchain based on their OKX trading data.

**Parameters:**

- `address` (path) - User's wallet address

**Response:**

```json
{
  "success": true,
  "data": {
    "address": "0x742d35Cc6C9e5e4B5E7f7b9f1b3c7c44D5a7e6F3",
    "volume": 25000.5,
    "tradeCount": 45,
    "txHash": "0x1234...abcd"
  }
}
```

**Example:**

```bash
curl -X POST http://localhost:3001/update-score/0x742d35Cc6C9e5e4B5E7f7b9f1b3c7c44D5a7e6F3
```

### GET `/trading-data/:address`

Retrieves OKX trading data for a specific address without updating onchain data.

**Parameters:**

- `address` (path) - User's wallet address

**Response:**

```json
{
  "volume": 25000.5,
  "tradeCount": 45
}
```

**Example:**

```bash
curl http://localhost:3001/trading-data/0x742d35Cc6C9e5e4B5E7f7b9f1b3c7c44D5a7e6F3
```

## Environment Configuration

| Variable               | Description                           | Required | Default                                                    |
| ---------------------- | ------------------------------------- | -------- | ---------------------------------------------------------- |
| `RPC_URL`              | Ethereum RPC endpoint                 | Yes      | `http://127.0.0.1:8545`                                    |
| `PRIVATE_KEY`          | Wallet private key for transactions   | Yes      | -                                                          |
| `CREDIT_SCORE_ADDRESS` | Deployed CreditScore contract address | Yes      | -                                                          |
| `OKX_API_KEY`          | OKX DEX API key                       | Yes      | -                                                          |
| `OKX_BASE_URL`         | OKX DEX API base URL                  | No       | `https://web3.okx.com/api/v5/dex/post-transaction`         |
| `CHAIN_ID`             | Blockchain chain ID                   | No       | `31337`                                                    |
| `NODE_ENV`             | Environment mode                      | No       | `development`                                              |
| `PORT`                 | Server port                           | No       | `3001`                                                     |

## Development Setup

### Local Development

1. **Start local blockchain:**

```bash
cd ../foundry && anvil
```

2. **Deploy contracts:**

```bash
cd ../foundry && ./deploy-local.sh
```

3. **Update environment variables** with deployed contract addresses

4. **Start backend:**

```bash
node server.js
```

### Testing

Test the API endpoints using curl or Postman:

```bash
# Test trading data retrieval
curl http://localhost:3001/trading-data/0x742d35Cc6C9e5e4B5E7f7b9f1b3c7c44D5a7e6F3

# Test credit score update
curl -X POST http://localhost:3001/update-score/0x742d35Cc6C9e5e4B5E7f7b9f1b3c7c44D5a7e6F3
```

## Architecture

### Data Flow

1. **Frontend Request** - User triggers credit score update from frontend
2. **API Call** - Backend receives request with user address
3. **OKX Data Fetch** - Server retrieves trading data from OKX DEX API
4. **Blockchain Update** - Backend calls smart contract to update credit score
5. **Response** - API returns updated data and transaction hash

### OKX Integration

The backend integrates with OKX DEX API to fetch real trading data:

```javascript
// Production implementation
const response = await axios.get(`${OKX_BASE_URL}/transactions-by-address`, {
  headers: { 
    "OK-ACCESS-KEY": OKX_API_KEY,
    "Content-Type": "application/json" 
  },
  params: { 
    address: userAddress, 
    chains: CHAIN_ID,
    limit: "100"
  },
});
```

**Note:** Uses mock data when NODE_ENV !== 'production'. In production mode, makes actual OKX DEX API calls.

### Smart Contract Integration

Interacts with the CreditScore contract using ethers.js:

```javascript
const creditScore = new ethers.Contract(
  creditScoreAddress,
  creditScoreABI,
  wallet
);

// Update user data onchain
const tx = await creditScore.updateUserData(
  userAddress,
  tradingVolume,
  tradeCount
);
```

## Security Considerations

- **Private Key Management**: Store private keys securely, never commit to version control
- **API Key Protection**: Keep OKX API keys in environment variables
- **Input Validation**: Validate wallet addresses and sanitize inputs
- **CORS Configuration**: Configure CORS for specific frontend domains in production
- **Rate Limiting**: Implement rate limiting for production deployments

## Error Handling

The API implements comprehensive error handling:

- **Network Errors**: Blockchain connection issues
- **API Errors**: OKX DEX API failures
- **Transaction Errors**: Failed smart contract transactions
- **Validation Errors**: Invalid addresses or parameters

All errors return appropriate HTTP status codes and descriptive messages.

## Deployment

### Development

```bash
node server.js
```

### Production

1. Configure production environment variables
2. Use process manager (PM2, systemd, etc.)
3. Set up reverse proxy (nginx)
4. Configure SSL certificates
5. Implement monitoring and logging

**Example PM2 deployment:**

```bash
npm install -g pm2
pm2 start server.js --name "okx-backend"
pm2 startup
pm2 save
```

## Dependencies

- **express** - Web framework for Node.js
- **ethers** - Ethereum library for blockchain interactions
- **axios** - HTTP client for API requests
- **cors** - Enable Cross-Origin Resource Sharing
- **dotenv** - Environment variable management

## Technology Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Blockchain:** ethers.js v5
- **HTTP Client:** Axios
- **Environment:** dotenv
- **CORS:** cors middleware

## Monitoring

For production deployments, consider implementing:

- **Health Check Endpoints** - `/health` endpoint for load balancers
- **Request Logging** - Winston or similar logging framework
- **Metrics Collection** - Prometheus metrics for monitoring
- **Error Tracking** - Sentry or similar error tracking service
