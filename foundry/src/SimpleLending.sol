// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICreditScore {
    function getScore(address user) external view returns (uint256);
}

contract SimpleLending {
    ICreditScore public creditScore;
    address public owner;

    struct Loan {
        uint256 amount; // in USD with 6 decimals
        uint256 dueDate;
        bool repaid;
    }

    mapping(address => Loan) public loans;
    uint256 public constant MIN_SCORE = 300;
    uint256 public constant LOAN_DURATION = 30 days;
    uint256 public constant ETH_PRICE_IN_USD = 3000;

    event LoanIssued(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _creditScore) {
        creditScore = ICreditScore(_creditScore);
        owner = msg.sender;
    }

    function deposit() external payable {
        // Anyone can deposit funds to the contract
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function borrow() external {
        require(loans[msg.sender].amount == 0 || loans[msg.sender].repaid, "Existing loan");

        uint256 score = creditScore.getScore(msg.sender);
        require(score >= MIN_SCORE, "Score too low");

        // Simple credit limit: score * $10
        uint256 creditLimit = score * 10 * 1e6; // in USDC-like decimals
        uint256 borrowAmountUSD = creditLimit / 2; // Conservative: 50% of limit

        // Convert USD amount to ETH amount (in wei)
        // (borrowAmountUSD / 1e6) * 1e18 / ETH_PRICE_IN_USD
        uint256 borrowAmountWei = (borrowAmountUSD * 1e12) / ETH_PRICE_IN_USD;

        require(
            address(this).balance >= borrowAmountWei,
            "Insufficient funds in contract"
        );

        loans[msg.sender] = Loan({
            amount: borrowAmountUSD,
            dueDate: block.timestamp + LOAN_DURATION,
            repaid: false
        });

        payable(msg.sender).transfer(borrowAmountWei);

        emit LoanIssued(msg.sender, borrowAmountUSD);
    }

    function repay() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.amount > 0, "No loan");
        require(!loan.repaid, "Already repaid");

        // Convert stored USD amount to expected ETH amount
        uint256 repayAmountWei = (loan.amount * 1e12) / ETH_PRICE_IN_USD;

        // Simple repayment - no interest for MVP
        require(msg.value >= repayAmountWei, "Insufficient payment");

        loan.repaid = true;
        emit LoanRepaid(msg.sender, loan.amount);
    }

    receive() external payable {} // Accept ETH

    // Add minimal ERC165 implementation to prevent wallet/library token detection
    function supportsInterface(bytes4) public pure returns (bool) {
        return false;
    }
    
    // Stub ERC20 methods that return empty/zero values to prevent token detection
    // These are commonly checked by wallets/libraries
    function decimals() external pure returns (uint8) {
        return 0; // Not a real token
    }
    
    function symbol() external pure returns (string memory) {
        return ""; // Empty symbol indicates not a token
    }
    
    function name() external pure returns (string memory) {
        return ""; // Empty name indicates not a token
    }
    
    function balanceOf(address) external pure returns (uint256) {
        return 0; // Always return 0 balance
    }
    
    function totalSupply() external pure returns (uint256) {
        return 0; // No supply
    }
}
