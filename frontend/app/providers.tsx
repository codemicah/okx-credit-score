'use client'

import * as React from 'react'
import {
  RainbowKitProvider,
  getDefaultWallets,
  getDefaultConfig,
} from '@rainbow-me/rainbowkit'
import {
  argentWallet,
  trustWallet,
  ledgerWallet,
} from '@rainbow-me/rainbowkit/wallets'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider } from 'wagmi'
import { localhost } from '@/lib/config'
import '@rainbow-me/rainbowkit/styles.css'
import { Toaster } from 'react-hot-toast'

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = React.useState(false)
  const [config, setConfig] = React.useState<any>(null)

  React.useEffect(() => {
    const { wallets } = getDefaultWallets()
    
    const wagmiConfig = getDefaultConfig({
      appName: 'OKX Credit Score',
      projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'default',
      wallets: [
        ...wallets,
        {
          groupName: 'Other',
          wallets: [argentWallet, trustWallet, ledgerWallet],
        },
      ],
      chains: [localhost],
      ssr: true,
    })
    
    setConfig(wagmiConfig)
    setMounted(true)
  }, [])

  if (!mounted || !config) {
    return null
  }

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          {children}
          <Toaster position="bottom-right" />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}