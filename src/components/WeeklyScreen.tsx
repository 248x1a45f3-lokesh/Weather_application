import React, { useState } from 'react';
import {
  Calendar,
  CloudRain,
  Sun,
  Cloud,
  Snowflake,
  Droplets,
  Wind,
  X,
  Compass,
} from 'lucide-react';
import { DailyForecastModel, CityModel, TempUnit, WindUnit } from '../types/weather';

interface WeeklyScreenProps {
  daily: DailyForecastModel[];
  selectedCity: CityModel;
  tempUnit: TempUnit;
  windUnit: WindUnit;
  formatTemp: (celsius: number) => string;
  formatWind: (speedKmh: number) => string;
}

export function WeeklyScreen({
  daily,
  selectedCity,
  formatTemp,
  formatWind,
}: WeeklyScreenProps) {
  const [selectedDay, setSelectedDay] = useState<DailyForecastModel | null>(null);

  const getWeatherIcon = (cond: string, size = 'w-5 h-5') => {
    const lower = cond.toLowerCase();
    if (lower.includes('rain') || lower.includes('drizzle')) return <CloudRain className={size} />;
    if (lower.includes('snow')) return <Snowflake className={size} />;
    if (lower.includes('cloud')) return <Cloud className={size} />;
    return <Sun className={size} />;
  };

  if (!daily || daily.length === 0) {
    return (
      <div className="p-6 text-center text-slate-300">
        <p>No 7-day forecast available.</p>
      </div>
    );
  }

  // Calculate global min and max for relative range bar
  const allMins = daily.map((d) => d.tempMin);
  const allMaxs = daily.map((d) => d.tempMax);
  const globalMin = Math.min(...allMins);
  const globalMax = Math.max(...allMaxs);
  const range = Math.max(globalMax - globalMin, 1);

  return (
    <div className="p-4 space-y-4">
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold tracking-tight text-white">7-Day Forecast</h2>
        <p className="text-xs text-white/70">
          Extended weekly outlook & precipitation probability for {selectedCity.name}
        </p>
      </div>

      {/* Helpful Hint */}
      <div className="p-3 rounded-xl bg-blue-500/20 border border-blue-400/30 text-xs text-blue-200 flex items-center gap-2">
        <Calendar className="w-4 h-4 shrink-0 text-blue-400" />
        <span>Tap any day to view detailed metrics and hourly breakdown.</span>
      </div>

      {/* Daily List */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-2">
        <div className="divide-y divide-white/10">
          {daily.map((item) => {
            const leftPercent = ((item.tempMin - globalMin) / range) * 100;
            const rightPercent = ((globalMax - item.tempMax) / range) * 100;

            return (
              <button
                key={item.date}
                onClick={() => setSelectedDay(item)}
                className="w-full py-3 px-2 flex items-center justify-between hover:bg-white/5 rounded-xl transition-all text-left"
              >
                {/* Day name */}
                <div className="w-20">
                  <div className="text-sm font-semibold text-white">{item.dayName}</div>
                  <div className="text-[11px] text-white/50">
                    {new Date(item.date).toLocaleDateString([], {
                      month: 'numeric',
                      day: 'numeric',
                    })}
                  </div>
                </div>

                {/* Weather icon & rain % */}
                <div className="flex items-center gap-1.5 w-16">
                  <div className="text-white/80">{getWeatherIcon(item.condition, 'w-5 h-5')}</div>
                  {item.rainProbability > 15 && (
                    <span className="text-[11px] text-sky-400 font-semibold flex items-center gap-0.5">
                      <Droplets className="w-2.5 h-2.5" />
                      {item.rainProbability}%
                    </span>
                  )}
                </div>

                {/* Min Temp */}
                <div className="w-10 text-right text-xs text-white/60 tabular-nums">
                  {formatTemp(item.tempMin)}
                </div>

                {/* Horizontal Range Bar */}
                <div className="flex-1 mx-3 h-1.5 bg-white/15 rounded-full relative overflow-hidden">
                  <div
                    className="absolute top-0 bottom-0 bg-gradient-to-r from-sky-400 to-amber-400 rounded-full"
                    style={{
                      left: `${Math.max(0, leftPercent)}%`,
                      right: `${Math.max(0, rightPercent)}%`,
                    }}
                  />
                </div>

                {/* Max Temp */}
                <div className="w-10 text-right text-xs font-bold text-white tabular-nums">
                  {formatTemp(item.tempMax)}
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Detail Modal Bottom Sheet */}
      {selectedDay && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end justify-center p-3">
          <div className="w-full max-w-sm bg-slate-900 border border-white/20 rounded-3xl p-5 shadow-2xl space-y-4 animate-in slide-in-from-bottom-5">
            <div className="flex items-start justify-between">
              <div>
                <h3 className="text-lg font-bold text-white">{selectedDay.dayName} Details</h3>
                <p className="text-xs text-slate-400">
                  {new Date(selectedDay.date).toLocaleDateString('en-US', {
                    weekday: 'long',
                    month: 'long',
                    day: 'numeric',
                  })}
                </p>
              </div>
              <button
                onClick={() => setSelectedDay(null)}
                className="p-1 rounded-full bg-white/10 hover:bg-white/20 text-white"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-3 rounded-2xl bg-white/5 border border-white/5 flex items-center justify-between">
              <div>
                <div className="text-xs text-slate-400">Condition</div>
                <div className="text-sm font-semibold text-white capitalize">
                  {selectedDay.description || selectedDay.condition}
                </div>
              </div>
              <div className="text-white">
                {getWeatherIcon(selectedDay.condition, 'w-8 h-8')}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="p-2.5 rounded-xl bg-white/5 space-y-0.5">
                <span className="text-slate-400">Temperature Span</span>
                <div className="font-bold text-white">
                  {formatTemp(selectedDay.tempMin)} to {formatTemp(selectedDay.tempMax)}
                </div>
              </div>
              <div className="p-2.5 rounded-xl bg-white/5 space-y-0.5">
                <span className="text-slate-400">Rain Probability</span>
                <div className="font-bold text-sky-400">{selectedDay.rainProbability}%</div>
              </div>
              <div className="p-2.5 rounded-xl bg-white/5 space-y-0.5">
                <span className="text-slate-400">Peak Wind</span>
                <div className="font-bold text-emerald-400">
                  {formatWind(selectedDay.windSpeed)}
                </div>
              </div>
              <div className="p-2.5 rounded-xl bg-white/5 space-y-0.5">
                <span className="text-slate-400">Max UV Index</span>
                <div className="font-bold text-amber-400">{selectedDay.uvIndex.toFixed(1)}</div>
              </div>
            </div>

            <button
              onClick={() => setSelectedDay(null)}
              className="w-full py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 font-semibold text-xs text-white transition-colors"
            >
              Close Details
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
