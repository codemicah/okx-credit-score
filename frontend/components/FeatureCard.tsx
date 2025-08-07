interface FeatureCardProps {
  title: string
  description: string
  icon: React.ReactNode
  gradient: string
}

export function FeatureCard({ title, description, icon, gradient }: FeatureCardProps) {
  return (
    <div className="relative group">
      <div className={`absolute -inset-0.5 bg-gradient-to-r ${gradient} rounded-2xl blur opacity-75 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-pulse-slow`}></div>
      <div className="relative bg-gray-900 rounded-2xl p-8 hover:bg-gray-800 transition-colors">
        <div className="flex items-center justify-center w-16 h-16 rounded-xl bg-gradient-to-br from-gray-800 to-gray-700 mb-6 group-hover:scale-110 transition-transform">
          {icon}
        </div>
        <h3 className="text-xl font-bold text-white mb-3">{title}</h3>
        <p className="text-gray-400">{description}</p>
      </div>
    </div>
  )
}