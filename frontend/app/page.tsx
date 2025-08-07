'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAccount } from 'wagmi'
import { LandingPage } from '@/components/LandingPage'

export default function Home() {
  const { isConnected } = useAccount()
  const router = useRouter()
  const [previouslyConnected, setPreviouslyConnected] = useState<boolean | null>(null)
  const [hasCheckedInitialState, setHasCheckedInitialState] = useState(false)

  // Check if user explicitly navigated to landing page
  useEffect(() => {
    if (typeof window !== 'undefined') {
      // Mark that user is on landing page (for refresh detection)
      sessionStorage.setItem('currentPage', 'landing')
      
      // Initialize previous connection state
      setPreviouslyConnected(isConnected)
      setHasCheckedInitialState(true)
    }
  }, [])

  // Handle wallet connection changes
  useEffect(() => {
    if (!hasCheckedInitialState) return

    // Only redirect on initial connection (was disconnected, now connected)
    if (previouslyConnected === false && isConnected === true) {
      // Small delay to ensure connection is stable
      const timer = setTimeout(() => {
        router.push('/dashboard')
      }, 500)
      
      return () => clearTimeout(timer)
    }

    // Update previous state
    setPreviouslyConnected(isConnected)
  }, [isConnected, previouslyConnected, hasCheckedInitialState, router])

  return <LandingPage isConnected={isConnected} />
}