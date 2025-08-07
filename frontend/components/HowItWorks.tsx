interface StepProps {
  number: string
  title: string
  description: string
}

function Step({ number, title, description }: StepProps) {
  return (
    <div className="flex flex-col items-center text-center">
      <div className="w-16 h-16 rounded-full bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center text-2xl font-bold text-white mb-4">
        {number}
      </div>
      <h3 className="text-xl font-semibold text-white mb-2">{title}</h3>
      <p className="text-gray-400">{description}</p>
    </div>
  )
}

export function HowItWorks() {
  return (
    <section className="py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-white mb-4">How It Works</h2>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Build your onchain credit score in four simple steps
          </p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          <Step
            number="1"
            title="Connect Wallet"
            description="Connect your wallet to access the OKX Credit Score Protocol"
          />
          <Step
            number="2"
            title="Trade on OKX DEX"
            description="Build your trading history on OKX decentralized exchange"
          />
          <Step
            number="3"
            title="Update Score"
            description="Sync your trading data to calculate your credit score onchain"
          />
          <Step
            number="4"
            title="Access Lending"
            description="Unlock uncollateralized loans based on your credit score"
          />
        </div>
        
        <div className="mt-8 flex justify-center">
          <div className="flex items-center space-x-4">
            <div className="h-1 w-24 bg-gradient-to-r from-purple-600 to-blue-600 rounded"></div>
            <div className="h-1 w-24 bg-gradient-to-r from-blue-600 to-cyan-600 rounded"></div>
            <div className="h-1 w-24 bg-gradient-to-r from-cyan-600 to-teal-600 rounded"></div>
          </div>
        </div>
      </div>
    </section>
  )
}