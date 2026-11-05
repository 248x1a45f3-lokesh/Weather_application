import React, { useState } from 'react';
import {
  Search,
  MapPin,
  RefreshCw,
  Heart,
  Droplets,
  Wind,
  Gauge,
  Eye,
  Sunrise,
  Sunset,
  Sun,
  CloudRain,
  Cloud,
  Snowflake,
  Compass,
  AlertCircle,
} from 'lucide-react';
import { WeatherModel, HourlyForecastModel, CityModel, TempUnit, WindUnit } from '../types/weather';
import { searchCitiesApi } from '../services/liveWeatherService';

interface HomeScreenProps {
  weather: WeatherModel | null;
  hourly: HourlyForecastModel[];
  selectedCity: CityModel;
  onSelectCity: (city: CityModel) => void;
  onRefresh: () => void;
  onFetchGpsLocation: () => void;
  onToggleFavorite: (city: CityModel) => void;
  isFavorite: boolean;
  isLoading: boolean;
  errorMessage: string | null;
  tempUnit: TempUnit;
  windUnit: WindUnit;
  formatTemp: (celsius: number) => string;
  formatWind: (speedKmh: number) => string;
}

export function HomeScreen({
  weather,
  hourly,
  selectedCity,
  onSelectCity,
  onRefresh,
  onFetchGpsLocation,
  onToggleFavorite,
  isFavorite,
  isLoading,
  errorMessage,
  tempUnit,
  windUnit,
  formatTemp,
  formatWind,
}: HomeScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [suggestions, setSuggestions] = useState<CityModel[]>([]);
  const [isSearching, setIsSearching] = useState(false);

  const handleSearchChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setSearchQuery(val);
    if (val.trim().length < 2) {
      setSuggestions([]);
      return;
    }
    setIsSearching(true);
    const results = await searchCitiesApi(val);
    setSuggestions(results);
    setIsSearching(false);
  };

  const handleSelectSuggestion = (city: CityModel) => {
    setSearchQuery('');
    setSuggestions([]);
    onSelectCity(city);
  };

  const getWeatherIcon = (cond: string, isDay: boolean, size = 'w-10 h-10') => {
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

  return (
    <div className="p-4 space-y-4">
      {/* Top Search Bar & Action Buttons */}
      <div className="relative z-30">
        <div className="flex items-center gap-2 bg-slate-900/70 backdrop-blur-md border border-white/15 rounded-2xl px-3 py-2 shadow-sm">
          <Search className="w-4 h-4 text-slate-400 shrink-0" />
          <input
            type="text"
            value={searchQuery}
            onChange={handleSearchChange}
            placeholder="Search city (e.g. Tokyo, Paris)..."
            className="w-full bg-transparent text-sm text-white placeholder-slate-400 focus:outline-none"
          />
          {isSearching && (
            <div className="w-4 h-4 border-2 border-blue-400 border-t-transparent rounded-full animate-spin shrink-0" />
          )}
          <button
            onClick={onFetchGpsLocation}
            title="Use Current GPS Location"
            className="p-1.5 rounded-lg bg-blue-500/20 text-blue-400 hover:bg-blue-500/30 transition-colors shrink-0"
          >
            <MapPin className="w-4 h-4" />
          </button>
          <button
            onClick={onRefresh}
            title="Refresh Live Weather"
            disabled={isLoading}
            className={`p-1.5 rounded-lg bg-white/10 text-white hover:bg-white/20 transition-colors shrink-0 ${
              isLoading ? 'animate-spin' : ''
            }`}
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {/* Live Auto-Suggestions dropdown */}
        {suggestions.length > 0 && (
          <div className="absolute top-12 left-0 right-0 bg-slate-900/95 backdrop-blur-xl border border-white/15 rounded-2xl shadow-xl overflow-hidden z-50 divide-y divide-white/10">
            {suggestions.map((c, i) => (
              <button
                key={`${c.name}-${c.latitude}-${i}`}
                onClick={() => handleSelectSuggestion(c)}
                className="w-full px-4 py-3 text-left hover:bg-white/10 flex items-center justify-between transition-colors"
              >
                <div>
                  <div className="text-sm font-semibold text-white">{c.name}</div>
                  <div className="text-xs text-slate-400">
                    {[c.state, c.country].filter(Boolean).join(', ')}
                  </div>
                </div>
                <span className="text-xs text-blue-400">Select</span>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Error State */}
      {errorMessage && !weather && (
        <div className="p-4 rounded-2xl bg-red-950/50 border border-red-500/30 text-center space-y-3">
          <AlertCircle className="w-10 h-10 text-red-400 mx-auto" />
          <h3 className="text-sm font-semibold text-red-300">Weather Unavailable</h3>
          <p className="text-xs text-red-200/80">{errorMessage}</p>
          <button
            onClick={onRefresh}
            className="px-4 py-1.5 text-xs font-semibold bg-red-600 hover:bg-red-500 text-white rounded-xl transition-colors"
          >
            Try Again
          </button>
        </div>
      )}

      {/* Loading Skeleton */}
      {isLoading && !weather && (
        <div className="p-8 text-center space-y-3">
          <div className="w-8 h-8 border-3 border-blue-400 border-t-transparent rounded-full animate-spin mx-auto" />
          <p className="text-xs text-slate-300">Fetching live atmospheric data...</p>
        </div>
      )}

      {/* Main Weather Card */}
      {weather && (
        <>
          <div className="relative overflow-hidden rounded-3xl p-6 bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-xl border border-white/20 shadow-xl">
            {/* Header: City Name and Heart Toggle */}
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-1.5">
                  <MapPin className="w-4 h-4 text-white/80" />
                  <h1 className="text-xl font-bold tracking-tight text-white">
                    {weather.cityName}
                  </h1>
                </div>
                <div className="text-xs text-white/70 mt-0.5">
                  {new Date(weather.timestamp).toLocaleDateString('en-US', {
                    weekday: 'long',
                    month: 'short',
                    day: 'numeric',
                  })}{' '}
                  ·{' '}
                  {new Date(weather.timestamp).toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </div>
              </div>

              <button
                onClick={() => onToggleFavorite(selectedCity)}
                title={isFavorite ? 'Remove from favorites' : 'Add to favorites'}
                className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-all active:scale-95"
              >
                <Heart
                  className={`w-5 h-5 ${
                    isFavorite
                      ? 'fill-rose-500 text-rose-500'
                      : 'text-white/80 hover:text-white'
                  }`}
                />
              </button>
            </div>

            {/* Temperature & Icon */}
            <div className="mt-6 flex items-center justify-between">
              <div>
                <div className="text-6xl font-extrabold tracking-tighter text-white tabular-nums">
                  {formatTemp(weather.temperature)}
                </div>
                <div className="text-sm font-medium text-white/90 mt-1 capitalize">
                  {weather.description}
                </div>
              </div>

              <div className="p-4 rounded-3xl bg-white/15 backdrop-blur-md shadow-inner text-white">
                {getWeatherIcon(weather.condition, weather.isDay, 'w-14 h-14')}
              </div>
            </div>

            {/* Footer: Feels like & High/Low */}
            <div className="mt-6 pt-4 border-t border-white/15 flex items-center justify-between text-xs text-white/85">
              <span>Feels like {formatTemp(weather.feelsLike)}</span>
              <span>
                H: {formatTemp(weather.tempMax)} · L: {formatTemp(weather.tempMin)}
              </span>
            </div>
          </div>

          {/* 24-Hour Forecast Horizontal Card Scroller */}
          {hourly.length > 0 && (
            <div className="rounded-2xl p-4 bg-slate-900/60 backdrop-blur-md border border-white/10 space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-1.5 text-xs font-bold text-white/90 uppercase tracking-wider">
                  <CloudRain className="w-3.5 h-3.5 text-blue-400" />
                  <span>Hourly Forecast</span>
                </div>
                <span className="text-[11px] text-white/60">Next 24h</span>
              </div>

              <div className="flex gap-2.5 overflow-x-auto pb-2 scrollbar-none">
                {hourly.slice(0, 12).map((item, index) => (
                  <div
                    key={item.time}
                    className={`flex flex-col items-center justify-between min-w-[70px] p-2.5 rounded-2xl transition-all ${
                      index === 0
                        ? 'bg-blue-500/25 border border-blue-400/40 text-white'
                        : 'bg-white/5 border border-white/5 text-slate-200'
                    }`}
                  >
                    <span className="text-[11px] font-medium text-white/80">
                      {index === 0 ? 'Now' : formatHour(item.time)}
                    </span>
                    <div className="my-1.5 text-white">
                      {getWeatherIcon(item.condition, item.isDay, 'w-6 h-6')}
                    </div>
                    <span className="text-xs font-bold tabular-nums">
                      {formatTemp(item.temperature)}
                    </span>
                    <div className="flex items-center gap-0.5 mt-1 text-[10px] text-sky-400 font-semibold">
                      <Droplets className="w-2.5 h-2.5" />
                      <span>{item.rainProbability}%</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* 6-Metric Meteorological Grid */}
          <div className="rounded-2xl p-4 bg-slate-900/60 backdrop-blur-md border border-white/10 space-y-3">
            <div className="flex items-center gap-1.5 text-xs font-bold text-white/90 uppercase tracking-wider">
              <Compass className="w-3.5 h-3.5 text-blue-400" />
              <span>Atmospheric Details</span>
            </div>

            <div className="grid grid-cols-2 gap-2.5">
              {/* Humidity */}
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 space-y-1">
                <div className="flex items-center gap-1.5 text-xs text-slate-300">
                  <Droplets className="w-3.5 h-3.5 text-sky-400" />
                  <span>Humidity</span>
                </div>
                <div className="text-base font-bold text-white tabular-nums">
                  {weather.humidity}%
                </div>
                <div className="text-[10px] text-slate-400">
                  Dew point ~{Math.round(weather.temperature - (100 - weather.humidity) / 5)}°
                </div>
              </div>

              {/* Wind */}
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 space-y-1">
                <div className="flex items-center gap-1.5 text-xs text-slate-300">
                  <Wind className="w-3.5 h-3.5 text-emerald-400" />
                  <span>Wind</span>
                </div>
                <div className="text-base font-bold text-white tabular-nums">
                  {formatWind(weather.windSpeed)}
                </div>
                <div className="text-[10px] text-slate-400">
                  Direction {weather.windDirection}°
                </div>
              </div>

              {/* Pressure */}
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 space-y-1">
                <div className="flex items-center gap-1.5 text-xs text-slate-300">
                  <Gauge className="w-3.5 h-3.5 text-amber-400" />
                  <span>Pressure</span>
                </div>
                <div className="text-base font-bold text-white tabular-nums">
                  {weather.pressure} hPa
                </div>
                <div className="text-[10px] text-slate-400">
                  {weather.pressure >= 1013 ? 'High pressure' : 'Normal pressure'}
                </div>
              </div>

              {/* Visibility */}
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 space-y-1">
                <div className="flex items-center gap-1.5 text-xs text-slate-300">
                  <Eye className="w-3.5 h-3.5 text-purple-400" />
                  <span>Visibility</span>
                </div>
                <div className="text-base font-bold text-white tabular-nums">
                  {weather.visibility.toFixed(1)} km
                </div>
                <div className="text-[10px] text-slate-400">
                  {weather.visibility >= 10 ? 'Clear visibility' : 'Moderate visibility'}
                </div>
              </div>

              {/* Sunrise / Sunset */}
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 space-y-1">
                <div className="flex items-center gap-1.5 text-xs text-slate-300">
                  <Sunrise className="w-3.5 h-3.5 text-orange-400" />
                  <span>Sunrise / Sunset</span>
                </div>
                <div className="text-xs font-semibold text-white">
                  {new Date(weather.sunrise).toLocaleTimeString([], {
                    hour: 'numeric',
                    minute: '2-digit',
                  })}
                </div>
                <div className="text-[10px] text-slate-400 flex items-center gap-1">
                  <Sunset className="w-3 h-3 text-pink-400" />
                  <span>
                    {new Date(weather.sunset).toLocaleTimeString([], {
                      hour: 'numeric',
                      minute: '2-digit',
                    })}
                  </span>
                </div>
              </div>

              {/* UV Index */}
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 space-y-1">
                <div className="flex items-center gap-1.5 text-xs text-slate-300">
                  <Sun className="w-3.5 h-3.5 text-yellow-400" />
                  <span>UV Index</span>
                </div>
                <div className="text-base font-bold text-white tabular-nums">
                  {weather.uvIndex.toFixed(1)}
                </div>
                <div className="text-[10px] text-slate-400">
                  {weather.uvIndex >= 6 ? 'Very High UV' : 'Moderate UV'}
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
