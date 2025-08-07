import type { Chain } from "viem";

// Re-export from contracts module (now using TypeChain)
export {
  CREDIT_SCORE_ADDRESS,
  LENDING_ADDRESS,
  CREDIT_SCORE_ABI,
  LENDING_ABI,
} from "./contracts";

export const API_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";

// Custom localhost chain for Foundry
export const localhost: Chain = {
  id: 31337,
  name: "Foundry Local",
  nativeCurrency: {
    decimals: 18,
    name: "Ether",
    symbol: "ETH",
  },
  rpcUrls: {
    default: { http: ["http://127.0.0.1:8545"] },
    public: { http: ["http://127.0.0.1:8545"] },
  },
  blockExplorers: {
    default: { name: "Foundry Local", url: "http://localhost:8545" },
  },
};
