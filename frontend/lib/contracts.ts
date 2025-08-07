// Auto-generated contract types and ABIs from TypeChain (Foundry artifacts)
import {
  CreditScore__factory,
  SimpleLending__factory,
} from "./typechain-types";
import type { CreditScore, SimpleLending } from "./typechain-types";

// Export contract addresses from environment
export const CREDIT_SCORE_ADDRESS = process.env
  .NEXT_PUBLIC_CREDIT_SCORE_ADDRESS as `0x${string}`;
export const LENDING_ADDRESS = process.env
  .NEXT_PUBLIC_LENDING_ADDRESS as `0x${string}`;

// Export ABIs from TypeChain factories
export const CREDIT_SCORE_ABI = CreditScore__factory.abi;
export const LENDING_ABI = SimpleLending__factory.abi;

// Export TypeChain factories for contract deployment/connection
export { CreditScore__factory, SimpleLending__factory };

// Export contract types for type safety
export type { CreditScore, SimpleLending };
