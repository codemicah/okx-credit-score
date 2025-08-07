"use client";

import { useState, useEffect } from "react";
import { useAccount, useWaitForTransactionReceipt } from "wagmi";
import {
  useCreditScore,
  useLoan,
  useBorrow,
  useRepay,
} from "@/hooks/useContracts";
import { API_URL } from "@/lib/config";
import { SimpleLending__factory } from "@/lib/contracts";
import toast from "react-hot-toast";
import { formatEther } from "viem";

// Utility function to format ETH amounts with proper decimals
const formatETH = (
  value: bigint | string | number,
  decimals: number = 4
): string => {
  if (typeof value === "bigint") {
    return Number(formatEther(value)).toFixed(decimals);
  }
  if (typeof value === "string") {
    return Number(value).toFixed(decimals);
  }
  return value.toFixed(decimals);
};

// Use the ABI directly from the factory
const LENDING_ABI = SimpleLending__factory.abi;

export function LendingActions() {
  const { address } = useAccount();
  const {
    score,
    refetchAll,
    isLoading: isCreditScoreLoading,
  } = useCreditScore(address);
  const { loan, refetchLoan, isLoading: isLoanLoading } = useLoan(address);
  const [isUpdating, setIsUpdating] = useState(false);

  const { borrow, data: borrowData, error, isPending } = useBorrow();
  const { repay, data: repayData, isPending: isRepayPending } = useRepay();

  const { isLoading: isBorrowing } = useWaitForTransactionReceipt({
    hash: borrowData,
  });

  const { isLoading: isRepaying } = useWaitForTransactionReceipt({
    hash: repayData,
  });

  const creditLimit = score ? Number(score) * 10 : 0;
  const availableBorrow = loan && !loan.repaid ? 0 : creditLimit / 2;
  const hasLoan = loan && loan.amount > 0n && !loan.repaid;

  // Single source of truth for loading state - prevents multiple actions running simultaneously
  const isAnyActionLoading =
    isUpdating ||
    isCreditScoreLoading ||
    isLoanLoading ||
    isBorrowing ||
    isPending ||
    isRepaying ||
    isRepayPending;

  // Auto-refetch loan data when transactions complete
  useEffect(() => {
    if (!isBorrowing && borrowData) {
      // Transaction completed, refetch loan data
      refetchLoan();
      toast.success("Borrow successful! Loan data updated.");
    }
  }, [isBorrowing, borrowData, refetchLoan]);

  useEffect(() => {
    if (!isRepaying && repayData) {
      // Transaction completed, refetch loan data
      refetchLoan();
      toast.success("Repay successful! Loan data updated.");
    }
  }, [isRepaying, repayData, refetchLoan]);

  const updateScore = async () => {
    if (!address) return;

    setIsUpdating(true);
    try {
      const response = await fetch(
        `${API_URL}/update-score/${address.toLowerCase()}`,
        {
          method: "POST",
        }
      );

      const data = await response.json();

      if (data.success) {
        // Wait a moment for the transaction to be mined, then refetch
        setTimeout(async () => {
          await refetchAll();
          await refetchLoan(); // Also refetch loan data
          // Show success toast after refetch
          toast.success(
            `Score updated! Volume: $${data.data.volume}, Trades: ${data.data.tradeCount}`
          );
          setIsUpdating(false);
        }, 2000);
      } else {
        setIsUpdating(false);
        throw new Error(data.error);
      }
    } catch (error) {
      setIsUpdating(false);
      toast.error("Failed to update score");
      console.error(error);
    }
  };

  if (!address) {
    return null;
  }

  return (
    <div className="relative group">
      {/* Animated gradient border */}
      <div className="absolute -inset-0.5 bg-gradient-to-r from-cyan-600 to-teal-600 rounded-2xl blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-pulse-slow"></div>

      {/* Card content */}
      <div className="relative bg-gray-900/80 backdrop-blur-xl rounded-2xl p-8 animate-fade-in border border-gray-800">
        <h2 className="text-2xl font-semibold mb-6 text-white">
          Lending Options
        </h2>

        <div className="grid grid-cols-2 gap-6 mb-6">
          <div className="bg-gray-800/50 backdrop-blur rounded-lg p-4 border border-gray-700">
            <div className="text-sm text-gray-400 mb-1">Credit Limit</div>
            <div className="text-2xl font-semibold text-white">
              ${creditLimit.toLocaleString()}
            </div>
          </div>
          <div className="bg-gray-800/50 backdrop-blur rounded-lg p-4 border border-gray-700">
            <div className="text-sm text-gray-400 mb-1">
              Available to Borrow
            </div>
            <div className="text-2xl font-semibold text-white">
              ${availableBorrow.toLocaleString()}
            </div>
          </div>
        </div>

        <div className="flex flex-col sm:flex-row gap-4">
          <button
            onClick={updateScore}
            disabled={isAnyActionLoading}
            className="flex-1 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white font-semibold py-3 px-6 rounded-lg transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
          >
            {isUpdating || isCreditScoreLoading
              ? "Updating..."
              : "Update Credit Score"}
          </button>

          <button
            onClick={async () => {
              try {
                await borrow();
              } catch (error: any) {
                console.error("Borrow error:", error);
                console.error("Error details:", {
                  message: error.message,
                  reason: error.reason,
                  code: error.code,
                  data: error.data,
                });
                toast.error(
                  `Borrow failed: ${error.message || "Unknown error"}`
                );
              }
            }}
            disabled={
              !borrow ||
              hasLoan ||
              Number(score || 0) < 300 ||
              isAnyActionLoading
            }
            className="flex-1 bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white font-semibold py-3 px-6 rounded-lg transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
          >
            {isBorrowing || isPending
              ? "Borrowing..."
              : isLoanLoading
              ? "Refreshing data..."
              : "Borrow Funds"}
          </button>

          {hasLoan && (
            <button
              onClick={async () => {
                if (!loan || !loan.amount) return;
                try {
                  // This should match the contract's price
                  const ETH_PRICE_IN_USD = 3000n;
                  const repayAmountWei =
                    (loan.amount * 10n ** 12n) / ETH_PRICE_IN_USD;

                  await repay({ value: repayAmountWei });
                } catch (error: any) {
                  console.error("Repay error:", error);
                  toast.error(
                    `Repay failed: ${error.message || "Unknown error"}`
                  );
                }
              }}
              disabled={!repay || !hasLoan || isAnyActionLoading}
              className="flex-1 bg-gradient-to-r from-orange-500 to-red-500 hover:from-orange-600 hover:to-red-600 text-white font-semibold py-3 px-6 rounded-lg transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
            >
              {isRepaying || isRepayPending
                ? "Repaying..."
                : isLoanLoading
                ? "Refreshing data..."
                : `Repay Loan (${formatETH(
                    loan?.amount ? (loan.amount * 10n ** 12n) / 3000n : 0n
                  )} ETH)`}
            </button>
          )}
        </div>

        {Number(score || 0) < 300 && (
          <p className="mt-4 text-sm text-red-400">
            Minimum credit score of 300 required to borrow
          </p>
        )}

        {hasLoan && (
          <div className="mt-6 p-4 bg-yellow-900/20 backdrop-blur rounded-lg border border-yellow-800/30">
            <h3 className="font-semibold text-sm mb-2 text-yellow-300">
              Active Loan
            </h3>
            <p className="text-sm text-gray-400">
              Amount: {loan && (Number(loan.amount) / 1e6).toFixed(2)} USDC
              <br />
              Due:{" "}
              {loan &&
                new Date(Number(loan.dueDate) * 1000).toLocaleDateString()}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
