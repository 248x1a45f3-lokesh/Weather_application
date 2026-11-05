import React, { useState } from 'react';
import {
  CloudRain,
  Sun,
  Cloud,
  Snowflake,
  Droplets,
  Wind,
  TrendingUp,
} from 'lucide-react';
import { HourlyForecastModel, CityModel, TempUnit, WindUnit } from '../types/weather';

interface HourlyScreenProps {
  hourly: HourlyForecastModel[];
  selectedCity: CityModel;
  tempUnit: TempUnit;
  windUnit: WindUnit;
  formatTemp: (celsius: number) => string;
  formatWind: (speedKmh: number) => string;
}

export function HourlyScreen({
  hourly,
  selectedCity,
  formatTemp,
  formatWind,
}: HourlyScreenProps) {
  const [hoveredIdx, setHoveredIdx] = useState<number | null>(null);

  const getWeatherIcon = (cond: string, isDay: boolean, size = 'w-5 h-5') => {
    const lower = cond.toLowerCase();
    if (lower.includes('rain') || lower.includes('drizzle')) return <CloudRain className={size} />;
    if (lower.includes('snow')) return <Snowflake className={size} />;
    if (lower.includes('cloud')) return <Cloud className={size} />;
    return <Sun className={size} />;
  };

  const formatHour = (isoStr: string) => {
    try {
      const d = new Date(isoStr);
      return d.toLocaleTimeString([], { hour: 'numeric', hour12: true });
    } catch {
      return '';
    }
  };

  if (!hourly || hourly.length === 0) {
    return (
      <div className="p-6 text-center text-slate-300">
        <p>No hourly forecast data available.</p>
      </div>
    );
  }

  // Calculate SVG curve coordinates for 16 hourly data points
  const chartData = hourly.slice(0, 16);
  const temps = chartData.map((d) => d.temperature);
  const minTemp = Math.min(...temps);
  const maxTemp = Math.max(...temps);
  const tempRange = Math.max(maxTemp - minTemp, 1);

  const svgWidth = 340;
  const svgHeight = 140;
  const paddingX = 20;
  const paddingY = 24;

  const points = chartData.map((item, idx) => {
    const x = paddingX + (idx / (chartData.length - 1)) * (svgWidth - paddingX * 2);
    const normalizedY = (item.temperature - minTemp) / tempRange;
    const y = svgHeight - paddingY - normalizedY * (svgHeight - paddingY * 2);
    return { x, y, item, idx };
  });

  // Build SVG path with smooth bezier curves
  let pathD = `M ${points[0].x} ${points[0].y}`;
  for (let i = 0; i < points.length - 1; i++) {
    const curr = points[i];
    const next = points[i + 1];
    const cpX1 = curr.x + (next.x - curr.x) / 2;
    const cpY1 = curr.y;
    const cpX2 = curr.x + (next.x - curr.x) / 2;
    const cpY2 = next.y;
    pathD += ` C ${cpX1} ${cpY1}, ${cpX2} ${cpY2}, ${next.x} ${next.y}`;
  }

  const fillD = `${pathD} L ${points[points.length - 1].x} ${svgHeight} L ${points[0].x} ${svgHeight} Z`;

  const activePoint = hoveredIdx !== null ? points[hoveredIdx] : points[0];

  return (
    <div className="p-4 space-y-4">
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold tracking-tight text-white">24-Hour Forecast</h2>
        <p className="text-xs text-white/70">
          Temperature, precipitation & wind trajectory for {selectedCity.name}
        </p>
      </div>

      {/* Interactive Bezier Chart */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1.5 text-xs font-bold text-white/90 uppercase tracking-wider">
            <TrendingUp className="w-3.5 h-3.5 text-blue-400" />
            <span>Interactive Temperature Curve</span>
          </div>
          <span className="text-[11px] text-blue-400 font-semibold tabular-nums">
            {formatHour(activePoint.item.time)}: {formatTemp(activePoint.item.temperature)}
          </span>
        </div>

        {/* SVG Curve */}
        <div className="relative w-full overflow-hidden flex justify-center">
          <svg
            viewBox={`0 0 ${svgWidth} ${svgHeight}`}
            className="w-full h-36 overflow-visible cursor-crosshair"
            onMouseLeave={() => setHoveredIdx(null)}
          >
            <defs>
              <linearGradient id="curveGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.4" />
                <stop offset="100%" stopColor="#3b82f6" stopOpacity="0.0" />
              </linearGradient>
            </defs>

            {/* Gradient Fill under line */}
            <path d={fillD} fill="url(#curveGradient)" />

            {/* Main curve line */}
            <path d={pathD} fill="none" stroke="#60a5fa" strokeWidth="2.5" strokeLinecap="round" />

            {/* Data Points */}
            {points.map((p) => (
              <g
                key={p.idx}
                onMouseEnter={() => setHoveredIdx(p.idx)}
                onTouchStart={() => setHoveredIdx(p.idx)}
                className="cursor-pointer"
              >
                <circle
                  cx={p.x}
                  cy={p.y}
                  r={hoveredIdx === p.idx ? 5 : 3}
                  className={`transition-all ${
                    hoveredIdx === p.idx
                      ? 'fill-white stroke-blue-500 stroke-2'
                      : 'fill-blue-400'
                  }`}
                />
              </g>
            ))}

            {/* Scrub tooltip guide line */}
            {hoveredIdx !== null && (
              <line
                x1={activePoint.x}
                y1={0}
                x2={activePoint.x}
                y2={svgHeight}
                stroke="rgba(255,255,255,0.3)"
                strokeDasharray="3 3"
              />
            )}
          </svg>
        </div>

        <div className="flex justify-between text-[10px] text-white/50 px-2 font-mono">
          <span>{formatHour(chartData[0].time)}</span>
          <span>{formatHour(chartData[Math.floor(chartData.length / 2)].time)}</span>
          <span>{formatHour(chartData[chartData.length - 1].time)}</span>
        </div>
      </div>

      {/* Detailed Hourly Table */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-2">
        <div className="text-xs font-bold text-white/90 uppercase tracking-wider mb-2">
          Hourly Breakdown Table
        </div>

        <div className="divide-y divide-white/10 max-h-[360px] overflow-y-auto pr-1">
          {hourly.map((item, idx) => (
            <div
              key={item.time}
              className={`py-2.5 px-2 flex items-center justify-between transition-colors rounded-lg ${
                hoveredIdx === idx ? 'bg-white/10' : 'hover:bg-white/5'
              }`}
              onMouseEnter={() => setHoveredIdx(idx)}
            >
              {/* Hour & Icon */}
              <div className="flex items-center gap-2.5 w-24">
                <span className="text-xs font-medium text-white/90">
                  {idx === 0 ? 'Now' : formatHour(item.time)}
                </span>
                <div className="text-white/80">
                  {getWeatherIcon(item.condition, item.isDay, 'w-4 h-4')}
                </div>
              </div>

              {/* Rain Probability */}
              <div className="flex items-center gap-1 text-xs text-sky-400 font-semibold w-16">
                <Droplets className="w-3 h-3" />
                <span>{item.rainProbability}%</span>
              </div>

              {/* Wind */}
              <div className="flex items-center gap-1 text-xs text-slate-300 w-20">
                <Wind className="w-3 h-3 text-slate-400" />
                <span>{formatWind(item.windSpeed)}</span>
              </div>

              {/* Temperature */}
              <div className="text-xs font-bold text-white tabular-nums text-right w-12">
                {formatTemp(item.temperature)}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
