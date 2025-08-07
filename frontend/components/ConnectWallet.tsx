'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'

interface ConnectWalletProps {
  className?: string
}

export function ConnectWallet({ className }: ConnectWalletProps) {
  if (className) {
    return (
      <ConnectButton.Custom>
        {({ account, chain, openConnectModal, mounted }) => {
          const connected = mounted && account && chain
          
          return (
            <button
              onClick={openConnectModal}
              className={className}
              disabled={!mounted}
            >
              {connected ? `${account.displayName}` : 'Connect Wallet'}
            </button>
          )
        }}
      </ConnectButton.Custom>
    )
  }
  
  return (
    <ConnectButton
      showBalance={false}
      chainStatus="icon"
      accountStatus={{
        smallScreen: 'avatar',
        largeScreen: 'full',
      }}
    />
  )
}