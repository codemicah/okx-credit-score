import { useReadContract, useWriteContract } from "wagmi";
import {
  CREDIT_SCORE_ADDRESS,
  LENDING_ADDRESS,
  CreditScore__factory,
  SimpleLending__factory,
} from "@/lib/contracts";
import { parseEther } from "viem";

// Use ABIs directly from factories
const CREDIT_SCORE_ABI = CreditScore__factory.abi;
const LENDING_ABI = SimpleLending__factory.abi;

export function useCreditScore(userAddress?: `0x${string}`) {
  const { data: score, refetch: refetchScore, isFetching: isFetchingScore, isLoading: isLoadingScore } = useReadContract({
    address: CREDIT_SCORE_ADDRESS,
    abi: CREDIT_SCORE_ABI,
    functionName: "getScore",
    args: userAddress ? [userAddress] : undefined,
  });

  const { data: volume, refetch: refetchVolume, isFetching: isFetchingVolume, isLoading: isLoadingVolume } = useReadContract({
    address: CREDIT_SCORE_ADDRESS,
    abi: CREDIT_SCORE_ABI,
    functionName: "tradingVolume",
    args: userAddress ? [userAddress] : undefined,
  });

  const { data: tradeCount, refetch: refetchTradeCount, isFetching: isFetchingTradeCount, isLoading: isLoadingTradeCount } = useReadContract({
    address: CREDIT_SCORE_ADDRESS,
    abi: CREDIT_SCORE_ABI,
    functionName: "tradeCount",
    args: userAddress ? [userAddress] : undefined,
  });

  // Get loan refetch function (but don't call useLoan here to avoid circular dependency issues)
  const refetchAll = async () => {
    await Promise.all([refetchScore(), refetchVolume(), refetchTradeCount()]);
  };

  const isLoading = isLoadingScore || isLoadingVolume || isLoadingTradeCount || 
                   isFetchingScore || isFetchingVolume || isFetchingTradeCount;

  return {
    score: score as bigint | undefined,
    volume: volume as bigint | undefined,
    tradeCount: tradeCount as bigint | undefined,
    refetchAll,
    isLoading,
  };
}

export function useLoan(userAddress?: `0x${string}`) {
  const { data: loan, refetch: refetchLoan, isFetching, isLoading } = useReadContract({
    address: LENDING_ADDRESS,
    abi: LENDING_ABI,
    functionName: "loans",
    args: userAddress ? [userAddress] : undefined,
  });

  // Convert array format [amount, dueDate, repaid] to object format
  const parsedLoan = loan && Array.isArray(loan) && loan.length === 3 ? {
    amount: loan[0] as bigint,
    dueDate: loan[1] as bigint,
    repaid: loan[2] as boolean,
  } : undefined;

  return {
    loan: parsedLoan,
    refetchLoan,
    isLoading: isLoading || isFetching, // True during any fetch operation
  };
}

export function useBorrow() {
  const { writeContract, ...rest } = useWriteContract();

  const borrow = () => {
    return writeContract({
      address: LENDING_ADDRESS,
      abi: LENDING_ABI,
      functionName: "borrow",
    });
  };

  return { borrow, writeContract, ...rest };
}

export function useRepay() {
  const { writeContract, ...rest } = useWriteContract();

  const repay = (args: { value: bigint }) => {
    return writeContract({
      address: LENDING_ADDRESS,
      abi: LENDING_ABI,
      functionName: "repay",
      value: args.value,
    });
  };

  return { repay, writeContract, ...rest };
}
