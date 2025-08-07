# OKX Credit Score Protocol - Smart Contracts

Solidity smart contracts for the OKX Credit Score Protocol, enabling decentralized credit scoring based on OKX DEX trading history and uncollateralized lending.

## Overview

The smart contracts consist of two core components that work together to provide credit-based lending in DeFi:

1. **CreditScore.sol** - Stores and calculates user credit scores based on OKX trading data
2. **SimpleLending.sol** - Provides uncollateralized loans based on credit scores

Built with Solidity 0.8.20 and deployed using the Foundry framework for maximum security and gas efficiency.

## Features

- 🏦 **Credit Score Management** - Onchain storage and calculation of user credit ratings
- 💰 **Uncollateralized Lending** - Borrow funds based purely on credit score
- 🔐 **Oracle Integration** - Secure data feeds from OKX DEX API
- ⚡ **Gas Optimized** - Efficient storage patterns and minimal computation
- 🛡️ **Security First** - Comprehensive access controls and validation
- 📊 **Transparent Scoring** - Public scoring algorithm for fairness

## Contract Architecture

### CreditScore Contract

**Purpose**: Manages user credit scores based on OKX trading data

**Key Functions**:
- `updateUserData(address, uint256, uint256)` - Oracle updates user trading data
- `calculateScore(uint256, uint256)` - Pure function for score calculation
- `getScore(address)` - View user's current credit score

**Scoring Algorithm**:
```
Base Score (200 points) + Volume Score (0-500) + Trade Count Score (0-300) = Total (200-1000)

Volume Score: $1,000 trading volume = 50 points (capped at 500)
Trade Count Score: 1 trade = 3 points (capped at 300)
Maximum Score: 1,000 points
```

### SimpleLending Contract

**Purpose**: Provides uncollateralized loans based on credit scores

**Key Functions**:
- `borrow()` - Request loan based on credit score
- `repay()` - Repay outstanding loan
- `deposit()` - Add liquidity to lending pool

**Lending Terms**:
- **Minimum Score**: 300 points required to borrow
- **Credit Limit**: Credit Score × $10 USD
- **Loan Amount**: 50% of credit limit (conservative approach)
- **Duration**: 30 days
- **Interest**: 0% for MVP (can be extended)

## Quick Start

### Prerequisites

- [Foundry](https://getfoundry.sh/) installed
- Node.js 18+ (for scripts)

### Installation

```bash
# Clone and navigate to contracts
cd foundry

# Install dependencies
forge install

# Build contracts
forge build
```

### Local Development

1. **Start local blockchain:**
```bash
anvil
```

2. **Deploy contracts locally:**
```bash
./deploy-local.sh
```

3. **Run tests:**
```bash
forge test -vvv
```

## Deployment

### Local Development (Anvil)

```bash
# Start Anvil in one terminal
anvil

# Deploy in another terminal
forge script script/DeployLocal.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

### Testnet Deployment (Sepolia)

```bash
# Configure environment
cp .env.example .env
# Edit .env with your private key and RPC URLs

# Deploy to Sepolia
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### Mainnet Networks

```bash
# Polygon
forge script script/Deploy.s.sol --rpc-url $POLYGON_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Arbitrum
forge script script/Deploy.s.sol --rpc-url $ARBITRUM_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## Contract Details

### CreditScore.sol

```solidity
// State Variables
mapping(address => uint256) public scores;           // User credit scores
mapping(address => uint256) public tradingVolume;   // OKX trading volume
mapping(address => uint256) public tradeCount;      // Number of trades
address public oracle;                              // Authorized data updater

// Key Functions
function updateUserData(address user, uint256 volume, uint256 count) external onlyOracle
function calculateScore(uint256 volume, uint256 count) public pure returns (uint256)
function getScore(address user) external view returns (uint256)
```

**Events**:
- `ScoreUpdated(address indexed user, uint256 score)` - Credit score updated

### SimpleLending.sol

```solidity
// State Variables
ICreditScore public creditScore;                     // Credit score contract reference
mapping(address => Loan) public loans;              // User loans
uint256 public constant MIN_SCORE = 300;           // Minimum score to borrow
uint256 public constant LOAN_DURATION = 30 days;   // Loan term

// Loan Structure
struct Loan {
    uint256 amount;    // Loan amount in USD (6 decimals)
    uint256 dueDate;   // Repayment deadline
    bool repaid;       // Repayment status
}

// Key Functions
function borrow() external                           // Request loan
function repay() external payable                   // Repay loan
function deposit() external payable                 // Add liquidity
```

**Events**:
- `LoanIssued(address indexed borrower, uint256 amount)` - Loan disbursed
- `LoanRepaid(address indexed borrower, uint256 amount)` - Loan repaid

## Testing

### Unit Tests

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/CreditScore.t.sol

# Gas reporting
forge test --gas-report
```

### Test Coverage

```bash
# Generate coverage report
forge coverage
```

### Integration Tests

The contracts are designed to work together:

1. **Oracle updates credit score** via `CreditScore.updateUserData()`
2. **User borrows funds** via `SimpleLending.borrow()`
3. **Lending contract queries** credit score via `CreditScore.getScore()`
4. **Loan issued** based on calculated credit limit

## Security Considerations

### Access Control
- **Oracle Role**: Only designated oracle can update credit scores
- **Owner Role**: Only owner can withdraw liquidity from lending contract

### Input Validation
- Address zero checks for all user inputs
- Overflow protection with Solidity 0.8.20
- Loan existence and repayment status validation

### Economic Security
- Conservative loan-to-value ratio (50% of credit limit)
- Minimum credit score requirement (300 points)
- Fixed ETH price for MVP (upgradeable for production)

### Known Limitations
- **Fixed ETH Price**: Uses constant $3,000/ETH (needs oracle for production)
- **No Interest**: 0% interest for MVP demonstration
- **Simple Scoring**: Basic algorithm (can be enhanced with ML)

## Gas Optimization

- **Packed Structs**: Loan struct uses optimal packing
- **View Functions**: Scoring calculation is `pure` for gas efficiency
- **Minimal Storage**: Only essential data stored onchain
- **Batch Operations**: Future versions could support batch updates

## Deployment Addresses

Contract addresses are stored in `DEPLOYED_ADDRESSES.md` after deployment.

### Local (Anvil)
- CreditScore: `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- SimpleLending: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`

### Testnet (Sepolia)
- CreditScore: `TBD`
- SimpleLending: `TBD`

## Development Scripts

### Available Scripts

| Script | Description |
|--------|-------------|
| `deploy-local.sh` | Deploy to local Anvil node |
| `deploy-production.sh` | Deploy to production networks |
| `forge build` | Compile contracts |
| `forge test` | Run test suite |
| `forge fmt` | Format code |

### Development Workflow

1. **Make contract changes**
2. **Run tests**: `forge test`
3. **Deploy locally**: `./deploy-local.sh`
4. **Test integration** with frontend/backend
5. **Deploy to testnet** for staging
6. **Deploy to mainnet** for production

## Future Enhancements

### V2 Features
- **Dynamic Interest Rates** - Based on risk assessment
- **Multiple Credit Sources** - Integrate other DEX data
- **Collateral Options** - Hybrid collateralized/uncollateralized loans
- **Governance Token** - Decentralized protocol governance

### Technical Improvements
- **Price Oracles** - Chainlink integration for accurate pricing
- **Advanced Scoring** - Machine learning-based credit models
- **Flash Loan Protection** - MEV and manipulation resistance
- **Cross-chain Support** - Multi-chain credit score portability

## Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/contract-enhancement`
3. **Add comprehensive tests** for new functionality
4. **Ensure all tests pass**: `forge test`
5. **Format code**: `forge fmt`
6. **Submit pull request** with detailed description

### Code Standards
- Follow Solidity style guide
- Add NatSpec documentation for all public functions
- Maintain 100% test coverage for new code
- Gas optimize where possible

## License

MIT License - see [LICENSE](../LICENSE) for details.

## Audit Status

⚠️ **Security Notice** - These contracts have not undergone formal security audits. Conduct comprehensive security audits and testing before mainnet deployment.

## Links

- **Foundry Documentation**: https://book.getfoundry.sh/
- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts/
- **Solidity Documentation**: https://docs.soliditylang.org/