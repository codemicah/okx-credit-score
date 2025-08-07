'use client';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

const sizeClasses = {
  sm: 'w-8 h-8',
  md: 'w-10 h-10', 
  lg: 'w-16 h-16',
  xl: 'w-24 h-24'
};

export function Logo({ size = 'md', className = '' }: LogoProps) {
  const sizeClass = sizeClasses[size];
  
  return (
    <div className={`${sizeClass} ${className} relative`}>
      <svg 
        viewBox="0 0 100 100" 
        className="w-full h-full"
        role="img"
        aria-label="OKX Credit Logo"
      >
        <defs>
          {/* Main gradient - purple to blue */}
          <linearGradient id="main-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#9333ea" />
            <stop offset="50%" stopColor="#2563eb" />
            <stop offset="100%" stopColor="#0891b2" />
          </linearGradient>
          
          {/* Secondary gradient for accents */}
          <linearGradient id="accent-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#06b6d4" />
            <stop offset="100%" stopColor="#10b981" />
          </linearGradient>
          
          {/* Glow effect */}
          <filter id="glow">
            <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
            <feMerge> 
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
        
        {/* Background hexagon */}
        <polygon 
          points="50,5 85,27.5 85,72.5 50,95 15,72.5 15,27.5"
          fill="url(#main-gradient)"
          className="drop-shadow-lg"
        />
        
        {/* Inner hexagon frame */}
        <polygon 
          points="50,15 75,32.5 75,67.5 50,85 25,67.5 25,32.5"
          fill="none"
          stroke="rgba(255,255,255,0.3)"
          strokeWidth="1"
        />
        
        {/* Credit score gauge arc */}
        <path
          d="M 30 50 A 20 20 0 1 1 70 50"
          fill="none"
          stroke="url(#accent-gradient)"
          strokeWidth="3"
          strokeLinecap="round"
          filter="url(#glow)"
        />
        
        {/* Central diamond representing value/credit */}
        <polygon
          points="50,35 60,50 50,65 40,50"
          fill="rgba(255,255,255,0.9)"
          className="drop-shadow-sm"
        />
        
        {/* Data points/nodes representing blockchain */}
        <circle cx="35" cy="35" r="2" fill="rgba(255,255,255,0.8)" />
        <circle cx="65" cy="35" r="2" fill="rgba(255,255,255,0.8)" />
        <circle cx="35" cy="65" r="2" fill="rgba(255,255,255,0.8)" />
        <circle cx="65" cy="65" r="2" fill="rgba(255,255,255,0.8)" />
        
        {/* Connection lines */}
        <line x1="35" y1="35" x2="40" y2="45" stroke="rgba(255,255,255,0.4)" strokeWidth="1" />
        <line x1="65" y1="35" x2="60" y2="45" stroke="rgba(255,255,255,0.4)" strokeWidth="1" />
        <line x1="35" y1="65" x2="40" y2="55" stroke="rgba(255,255,255,0.4)" strokeWidth="1" />
        <line x1="65" y1="65" x2="60" y2="55" stroke="rgba(255,255,255,0.4)" strokeWidth="1" />
        
        {/* Trading arrow indicator */}
        <path
          d="M 45 45 L 55 45 L 52 42 M 55 45 L 52 48"
          stroke="url(#accent-gradient)"
          strokeWidth="2"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    </div>
  );
}