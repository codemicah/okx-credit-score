'use client'

import Link from 'next/link'
import { ConnectWallet } from './ConnectWallet'
import { FeatureCard } from './FeatureCard'
import { HowItWorks } from './HowItWorks'
import { StatsSection } from './StatsSection'
import { Logo } from './Logo'

interface LandingPageProps {
  isConnected?: boolean
}

export function LandingPage({ isConnected = false }: LandingPageProps) {
  return (
    <div className="min-h-screen bg-black text-white overflow-hidden">
      {/* Background gradient */}
      <div className="fixed inset-0 bg-gradient-to-br from-purple-900/20 via-blue-900/20 to-cyan-900/20"></div>
      <div className="fixed inset-0 bg-[url('/grid.svg')] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))]"></div>
      
      {/* Hero Section */}
      <section className="relative pt-20 pb-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Navigation */}
          <nav className="flex justify-between items-center mb-20">
            <div className="flex items-center space-x-3">
              <Logo size="md" className="animate-pulse-slow" />
              <span className="text-2xl font-bold">OKX Credit</span>
            </div>
            <div className="flex items-center space-x-4">
              {isConnected ? (
                <Link
                  href="/dashboard"
                  className="px-6 py-2 text-sm font-semibold bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white rounded-lg transition-all transform hover:scale-105"
                >
                  Go to Dashboard
                </Link>
              ) : (
                <ConnectWallet />
              )}
            </div>
          </nav>
          
          {/* Hero Content */}
          <div className="text-center max-w-4xl mx-auto">
            <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-purple-400 via-blue-400 to-cyan-400 bg-clip-text text-transparent animate-gradient">
              Unlock DeFi with Your Trading Reputation
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 mb-8">
              Build your onchain credit score using OKX DEX trading history. 
              Access uncollateralized loans based on your proven track record.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              {isConnected ? (
                <Link
                  href="/dashboard"
                  className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all transform hover:scale-105 text-center"
                >
                  Open Dashboard
                </Link>
              ) : (
                <ConnectWallet className="px-8 py-4 text-lg font-semibold bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all transform hover:scale-105" />
              )}
              <button className="px-8 py-4 text-lg font-semibold border border-gray-600 rounded-xl hover:border-gray-400 transition-colors">
                Learn More
              </button>
            </div>
          </div>
          
          {/* Floating elements */}
          <div className="absolute top-20 left-10 w-72 h-72 bg-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-float"></div>
          <div className="absolute bottom-20 right-10 w-72 h-72 bg-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-float animation-delay-2000"></div>
        </div>
      </section>
      
      {/* Features Section */}
      <section className="relative py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-white mb-4">Why Choose OKX Credit Score?</h2>
            <p className="text-xl text-gray-400 max-w-2xl mx-auto">
              The first decentralized credit scoring protocol powered by real DEX trading data
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <FeatureCard
              title="No Collateral Required"
              description="Borrow funds based solely on your trading reputation and credit score"
              icon={
                <svg className="w-8 h-8 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              }
              gradient="from-purple-600 to-pink-600"
            />
            <FeatureCard
              title="Real Trading Data"
              description="Credit scores calculated from actual OKX DEX trading volume and history"
              icon={
                <svg className="w-8 h-8 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              }
              gradient="from-blue-600 to-cyan-600"
            />
            <FeatureCard
              title="Instant Updates"
              description="Sync your trading activity and update your credit score in real-time"
              icon={
                <svg className="w-8 h-8 text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              }
              gradient="from-cyan-600 to-teal-600"
            />
            <FeatureCard
              title="Transparent & Fair"
              description="All credit scores and lending terms are publicly verifiable onchain"
              icon={
                <svg className="w-8 h-8 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
              }
              gradient="from-teal-600 to-green-600"
            />
          </div>
        </div>
      </section>
      
      {/* Stats Section */}
      <StatsSection />
      
      {/* How It Works */}
      <HowItWorks />
      
      {/* CTA Section */}
      <section className="relative py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl font-bold text-white mb-4">
            Ready to Build Your Credit Score?
          </h2>
          <p className="text-xl text-gray-400 mb-8">
            Join thousands of traders already benefiting from uncollateralized DeFi lending
          </p>
          {isConnected ? (
            <Link
              href="/dashboard"
              className="px-12 py-4 text-lg font-semibold bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all transform hover:scale-105 inline-block text-center"
            >
              Open Dashboard
            </Link>
          ) : (
            <ConnectWallet className="px-12 py-4 text-lg font-semibold bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all transform hover:scale-105" />
          )}
        </div>
      </section>
      
      {/* Footer */}
      <footer className="relative py-12 border-t border-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-gray-400">
          <div className="flex items-center justify-center space-x-2 mb-4">
            <Logo size="sm" />
            <span className="text-lg font-semibold text-white">OKX Credit</span>
          </div>
          <p>Built for OKX EthCC Hackathon 2025</p>
        </div>
      </footer>
    </div>
  )
}