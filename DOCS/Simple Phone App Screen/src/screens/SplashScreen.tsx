import React, { useEffect } from "react";

export default function SplashScreen({ onDone }: { onDone: () => void }) {
  useEffect(() => {
    const t = setTimeout(onDone, 2500);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <div className="flex flex-col items-center justify-center h-full bg-background gap-6">
      {/* Logo circle */}
      <div className="relative w-32 h-32">
        <div className="w-full h-full rounded-full flex items-center justify-center" style={{ background: "var(--primary)" }}>
          {/* Wallet icon */}
          <svg width="72" height="52" viewBox="0 0 84 60" fill="none">
            <rect x="2" y="2" width="80" height="56" rx="10" stroke="var(--background)" strokeWidth="4" />
            <line x1="2" y1="20" x2="82" y2="20" stroke="var(--background)" strokeWidth="4" />
            <circle cx="68" cy="38" r="7" fill="var(--secondary)" />
          </svg>
        </div>
        {/* Dot accent */}
        <div className="absolute top-3 right-3 w-4 h-4 rounded-full" style={{ background: "var(--secondary)" }} />
      </div>

      {/* App name */}
      <div className="text-center">
        <h1 className="text-4xl font-medium text-foreground">وِفرة</h1>
        <p className="text-sm text-muted-foreground mt-1">مصاريفك ودخلك بكل بساطة</p>
      </div>

      {/* Loading dots */}
      <div className="flex items-center gap-3 mt-4">
        {[0, 1, 2].map(i => (
          <div
            key={i}
            className="w-2.5 h-2.5 rounded-full"
            style={{
              background: "var(--primary)",
              animation: `wifra-pulse 1.2s ease-in-out infinite`,
              animationDelay: `${i * 0.15}s`,
            }}
          />
        ))}
      </div>
      <p className="text-sm text-muted-foreground">جاري التحميل...</p>
    </div>
  );
}
