import React, { useState, useEffect } from 'react';
import { Wifi, BatteryMedium, Signal, Sun, CloudRain, Cloud, Moon, Snowflake } from 'lucide-react';
import { WeatherModel } from '../types/weather';

interface AndroidFrameProps {
  children: React.ReactNode;
  weather: WeatherModel | null;
  activeTab: number;
  onTabChange: (tabIndex: number) => void;
  isDeviceMode: boolean;
  onToggleDeviceMode: () => void;
  themeMode: 'system' | 'light' | 'dark';
}

export function AndroidFrame({
  children,
  weather,
  activeTab,
  onTabChange,
  isDeviceMode,
  onToggleDeviceMode,
  themeMode,
}: AndroidFrameProps) {
  const [currentTime, setCurrentTime] = useState('');

  useEffect(() => {
    const update = () => {
      const now = new Date();
      setCurrentTime(
        now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false })
      );
    };
    update();
    const interval = setInterval(update, 1000);
    return () => clearInterval(interval);
  }, []);

  // Determine dynamic background style
  const getDynamicBackground = () => {
    if (!weather) return 'from-slate-900 via-slate-800 to-slate-950 text-slate-100';
    const cond = weather.condition.toLowerCase();

    if (!weather.isDay) {
      return 'from-slate-950 via-slate-900 to-indigo-950 text-slate-100';
    }
    if (cond.includes('rain') || cond.includes('drizzle')) {
      return 'from-slate-900 via-sky-950 to-blue-900 text-slate-100';
    }
    if (cond.includes('snow')) {
      return 'from-slate-800 via-slate-700 to-blue-950 text-slate-100';
    }
    if (cond.includes('cloud') || cond.includes('overcast')) {
      return 'from-slate-800 via-slate-700 to-slate-900 text-slate-100';
    }
    // Sunny / Clear
    return 'from-amber-600/90 via-orange-600/80 to-slate-900 text-slate-100';
  };

  const navItems = [
    { label: 'Home', icon: Sun },
    { label: 'Hourly', icon: CloudRain },
    { label: '7-Day', icon: Cloud },
    { label: 'Saved', icon: Moon },
    { label: 'Settings', icon: Snowflake },
  ];

  return (
    <div className="flex flex-col items-center justify-center w-full">
      {/* Device wrapper */}
      <div
        className={`transition-all duration-300 w-full ${
          isDeviceMode
            ? 'max-w-[410px] my-4 rounded-[48px] p-3 bg-slate-950 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.6)] border-[6px] border-slate-800 relative ring-1 ring-slate-700/50'
            : 'max-w-2xl w-full rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden'
        }`}
      >
        {/* Android Punch Hole & Speaker Grill in Device Mode */}
        {isDeviceMode && (
          <div className="relative z-50 flex items-center justify-between px-7 pt-2 pb-1 bg-transparent">
            {/* Status bar time */}
            <span className="text-xs font-semibold tracking-tight text-white/90 font-mono">
              {currentTime}
            </span>

            {/* Camera cutout */}
            <div className="w-4 h-4 rounded-full bg-black border border-slate-800/80 shadow-inner flex items-center justify-center">
              <div className="w-1.5 h-1.5 rounded-full bg-slate-900/90" />
            </div>

            {/* Status indicators */}
            <div className="flex items-center gap-1.5 text-white/80">
              <span className="text-[10px] font-bold tracking-tight">5G</span>
              <Signal className="w-3.5 h-3.5" />
              <Wifi className="w-3.5 h-3.5" />
              <BatteryMedium className="w-4 h-4" />
            </div>
          </div>
        )}

        {/* Screen content container */}
        <div
          className={`relative flex flex-col overflow-hidden bg-gradient-to-b ${getDynamicBackground()} ${
            isDeviceMode ? 'h-[780px] rounded-[36px]' : 'min-h-[720px] rounded-xl'
          }`}
        >
          {/* Main scrollable body */}
          <div className="flex-1 overflow-y-auto overflow-x-hidden relative pb-20">
            {children}
          </div>

          {/* Android Material 3 Navigation Bar */}
          <nav
            aria-label="Application Navigation"
            className="absolute bottom-0 left-0 right-0 z-40 bg-slate-950/80 backdrop-blur-xl border-t border-white/10 px-3 py-2 flex items-center justify-around"
          >
            {navItems.map((item, idx) => {
              const Icon = item.icon;
              const isActive = activeTab === idx;
              return (
                <button
                  key={item.label}
                  onClick={() => onTabChange(idx)}
                  className="flex flex-col items-center justify-center flex-1 py-1 group transition-all"
                  aria-label={item.label}
                  aria-pressed={isActive}
                >
                  <div
                    className={`px-4 py-1 rounded-full transition-all flex items-center justify-center ${
                      isActive
                        ? 'bg-blue-500/25 text-blue-400 scale-105'
                        : 'text-slate-400 hover:text-slate-200'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                  </div>
                  <span
                    className={`text-[11px] font-medium mt-1 tracking-tight ${
                      isActive ? 'text-blue-400 font-semibold' : 'text-slate-400'
                    }`}
                  >
                    {item.label}
                  </span>
                </button>
              );
            })}
          </nav>

          {/* Android Home Navigation Bar indicator in device mode */}
          {isDeviceMode && (
            <div className="absolute bottom-1 left-1/2 -translate-x-1/2 w-32 h-1 bg-white/40 rounded-full pointer-events-none z-50" />
          )}
        </div>
      </div>
    </div>
  );
}
