'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useAccount } from 'wagmi'
import { ConnectWallet } from '@/components/ConnectWallet'
import { CreditScore } from '@/components/CreditScore'
import { LendingActions } from '@/components/LendingActions'
import { Logo } from '@/components/Logo'

export default function Dashboard() {
  const { address, isConnected, isConnecting } = useAccount()
  const router = useRouter()
  const [hasCheckedConnection, setHasCheckedConnection] = useState(false)

  // Mark that user is on dashboard page
  useEffect(() => {
    if (typeof window !== 'undefined') {
      sessionStorage.setItem('currentPage', 'dashboard')
    }
  }, [])

  // Wait for initial connection check before deciding to redirect
  useEffect(() => {
    if (!isConnecting) {
      setHasCheckedConnection(true)
    }
  }, [isConnecting])

  // Only redirect after we've given the wallet time to reconnect and confirmed it's not connected
  useEffect(() => {
    if (hasCheckedConnection && !isConnected && !isConnecting) {
      // Longer delay to allow for wallet reconnection during page refresh
      const timer = setTimeout(() => {
        router.replace('/')
      }, 2000)
      
      return () => clearTimeout(timer)
    }
  }, [hasCheckedConnection, isConnected, isConnecting, router])

  // Show loading state while checking connection
  if (!hasCheckedConnection || isConnecting) {
    return (
      <main className="min-h-screen bg-black text-white overflow-hidden flex items-center justify-center">
        <div className="text-center">
          <Logo size="lg" className="mx-auto mb-6" />
          <div className="animate-spin w-8 h-8 border-2 border-purple-600 border-t-transparent rounded-full mx-auto mb-4"></div>
          <p className="text-gray-400">Loading dashboard...</p>
        </div>
      </main>
    )
  }

  // Show loading state while waiting to redirect
  if (!isConnected) {
    return (
      <main className="min-h-screen bg-black text-white overflow-hidden flex items-center justify-center">
        <div className="text-center">
          <Logo size="lg" className="mx-auto mb-6" />
          <div className="animate-spin w-8 h-8 border-2 border-purple-600 border-t-transparent rounded-full mx-auto mb-4"></div>
          <p className="text-gray-400">Wallet not connected. Redirecting...</p>
        </div>
      </main>
    )
  }

  return (
    <main className="min-h-screen bg-black text-white overflow-hidden">
      {/* Background gradient */}
      <div className="fixed inset-0 bg-gradient-to-br from-purple-900/20 via-blue-900/20 to-cyan-900/20"></div>
      <div className="fixed inset-0 bg-[url('/grid.svg')] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))]"></div>
      
      <div className="relative z-10 container mx-auto px-4 py-8">
        <header className="mb-12">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-3">
              <Link href="/" className="hover:opacity-80 transition-opacity cursor-pointer">
                <Logo size="md" />
              </Link>
              <Link href="/" className="hover:opacity-80 transition-opacity cursor-pointer">
                <div>
                  <h1 className="text-3xl font-bold text-white">
                    OKX Credit Score Protocol
                  </h1>
                  <p className="text-sm text-gray-400 mt-1">
                    Your Dashboard
                  </p>
                </div>
              </Link>
            </div>
            <div className="flex items-center space-x-4">
              <ConnectWallet />
            </div>
          </div>
        </header>

        <div className="space-y-8 max-w-4xl mx-auto">
          <CreditScore address={address} />
          <LendingActions />
        </div>
      </div>
    </main>
  )
}