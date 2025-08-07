'use client'

import { useAccount } from 'wagmi'
import { useCreditScore, useLoan } from '@/hooks/useContracts'
import { LENDING_ADDRESS, CREDIT_SCORE_ADDRESS } from '@/lib/contracts'

export function DebugInfo() {
  const { address, isConnected } = useAccount()
  const { score, volume, tradeCount } = useCreditScore(address)
  const { loan } = useLoan(address)
  
  const hasLoan = loan && loan.amount > 0n && !loan.repaid
  const canBorrow = Number(score || 0) >= 300 && !hasLoan
  
  return (
    <div className="bg-gray-900/80 backdrop-blur-xl rounded-xl p-6 border border-gray-800">
      <h3 className="text-lg font-semibold mb-4 text-cyan-400">🔍 Debug Information</h3>
      
      <div className="space-y-2 text-sm font-mono">
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">Connected:</span>
          <span className={isConnected ? "text-green-400" : "text-red-400"}>
            {isConnected ? "Yes" : "No"}
          </span>
        </div>
        
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">User Address:</span>
          <span className="text-white text-xs">{address || "Not connected"}</span>
        </div>
        
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">Credit Score:</span>
          <span className={Number(score || 0) >= 300 ? "text-green-400" : "text-yellow-400"}>
            {score?.toString() || "0"} {Number(score || 0) >= 300 ? "✓" : "(Need 300+)"}
          </span>
        </div>
        
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">Trading Volume:</span>
          <span className="text-white">${(Number(volume || 0n) / 1e6).toFixed(2)}</span>
        </div>
        
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">Trade Count:</span>
          <span className="text-white">{tradeCount?.toString() || "0"}</span>
        </div>
        
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">Has Active Loan:</span>
          <span className={hasLoan ? "text-red-400" : "text-green-400"}>
            {hasLoan ? "Yes ❌" : "No ✓"}
          </span>
        </div>
        
        {loan && loan.amount > 0n && (
          <>
            <div className="grid grid-cols-2 gap-2">
              <span className="text-gray-400">Loan Amount:</span>
              <span className="text-white">${Number(loan.amount) / 1e6} USDC</span>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <span className="text-gray-400">Loan Repaid:</span>
              <span className={loan.repaid ? "text-green-400" : "text-yellow-400"}>
                {loan.repaid ? "Yes" : "No"}
              </span>
            </div>
          </>
        )}
        
        <div className="grid grid-cols-2 gap-2">
          <span className="text-gray-400">Can Borrow:</span>
          <span className={canBorrow ? "text-green-400 font-bold" : "text-red-400 font-bold"}>
            {canBorrow ? "YES ✓" : "NO ❌"}
          </span>
        </div>
        
        <div className="pt-2 border-t border-gray-700">
          <div className="text-gray-400 mb-1">Contract Addresses:</div>
          <div className="text-xs space-y-1">
            <div>CreditScore: {CREDIT_SCORE_ADDRESS}</div>
            <div>SimpleLending: {LENDING_ADDRESS}</div>
          </div>
        </div>
        
        {!canBorrow && (
          <div className="pt-2 border-t border-gray-700">
            <div className="text-yellow-400 text-xs">
              ⚠️ Cannot borrow because:
              {Number(score || 0) < 300 && <div>• Credit score below 300</div>}
              {hasLoan && <div>• Active loan not repaid</div>}
              {!isConnected && <div>• Wallet not connected</div>}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}