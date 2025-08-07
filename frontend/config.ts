import { createConfig, http } from "wagmi";
import { mainnet, sepolia } from "wagmi/chains";

// Define local Foundry chain
const foundryLocal = {
  id: 31337,
  name: "Foundry Local",
  nativeCurrency: {
    decimals: 18,
    name: "Ether",
    symbol: "ETH",
  },
  rpcUrls: {
    default: {
      http: ["http://127.0.0.1:8545"],
    },
  },
} as const;

export const config = createConfig({
  chains: [foundryLocal],
  transports: {
    [foundryLocal.id]: http("http://127.0.0.1:8545/"),
  },
});
