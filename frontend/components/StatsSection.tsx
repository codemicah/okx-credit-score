interface StatProps {
  value: string
  label: string
  suffix?: string
}

function Stat({ value, label, suffix }: StatProps) {
  return (
    <div className="text-center">
      <div className="text-4xl md:text-5xl font-bold text-white mb-2">
        {value}
        {suffix && <span className="text-3xl md:text-4xl text-purple-400">{suffix}</span>}
      </div>
      <div className="text-gray-400">{label}</div>
    </div>
  )
}

export function StatsSection() {
  return (
    <section className="py-20 bg-gray-900/50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <Stat value="$50M" suffix="+" label="Total Volume Tracked" />
          <Stat value="10K" suffix="+" label="Active Users" />
          <Stat value="$5M" label="Loans Issued" />
          <Stat value="850" label="Max Credit Score" />
        </div>
      </div>
    </section>
  )
}