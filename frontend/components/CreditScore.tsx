'use client'

import { useCreditScore } from '@/hooks/useContracts'
import { formatUnits } from 'viem'

interface CreditScoreProps {
  address?: `0x${string}`
}

export function CreditScore({ address }: CreditScoreProps) {
  const { score, volume, tradeCount } = useCreditScore(address)

  if (!address) {
    return (
      <div className="bg-gray-900/80 backdrop-blur-xl rounded-2xl p-8 border border-gray-800 text-center">
        <p className="text-gray-400">Connect your wallet to view your credit score</p>
      </div>
    )
  }

  return (
    <div className="relative group">
      {/* Animated gradient border */}
      <div className="absolute -inset-0.5 bg-gradient-to-r from-purple-600 to-blue-600 rounded-2xl blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-pulse-slow"></div>
      
      {/* Card content */}
      <div className="relative bg-gray-900/80 backdrop-blur-xl rounded-2xl p-8 animate-fade-in border border-gray-800">
        <div className="text-center mb-8">
          <h2 className="text-2xl font-semibold mb-6 text-white">Your Credit Score</h2>
          <div className="relative inline-block">
            <div className="text-7xl font-bold bg-gradient-to-r from-purple-400 via-blue-400 to-cyan-400 bg-clip-text text-transparent">
              {score ? score.toString() : '0'}
            </div>
            <div className="text-sm text-gray-400 mt-2">out of 1000</div>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-6">
          <div className="bg-gray-800/50 backdrop-blur rounded-lg p-4 border border-gray-700">
            <div className="text-sm text-gray-400 mb-1">OKX Trading Volume (30d)</div>
            <div className="text-2xl font-semibold text-white">
              ${volume ? formatUnits(volume, 6) : '0'}
            </div>
          </div>
          <div className="bg-gray-800/50 backdrop-blur rounded-lg p-4 border border-gray-700">
            <div className="text-sm text-gray-400 mb-1">Trade Count</div>
            <div className="text-2xl font-semibold text-white">
              {tradeCount ? tradeCount.toString() : '0'}
            </div>
          </div>
        </div>

        <div className="mt-6 p-4 bg-purple-900/20 backdrop-blur rounded-lg border border-purple-800/30">
          <h3 className="font-semibold text-sm mb-2 text-purple-300">How your score is calculated:</h3>
          <ul className="text-sm text-gray-400 space-y-1">
            <li>• Base score: 200 points for any trading activity</li>
            <li>• Volume score: Up to 500 points ($1k = 50 points)</li>
            <li>• Trade frequency: Up to 300 points (1 trade = 3 points)</li>
          </ul>
        </div>
      </div>
    </div>
  )
}