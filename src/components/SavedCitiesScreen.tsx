import React, { useState } from 'react';
import {
  Heart,
  Plus,
  Trash2,
  MapPin,
  Search,
  X,
  CheckCircle,
  Sun,
  CloudRain,
  Cloud,
  Snowflake,
} from 'lucide-react';
import { CityModel, WeatherModel, TempUnit } from '../types/weather';
import { searchCitiesApi } from '../services/liveWeatherService';

interface SavedCitiesScreenProps {
  savedCities: CityModel[];
  savedCitiesWeather: Record<string, WeatherModel>;
  selectedCity: CityModel;
  onSelectCity: (city: CityModel) => void;
  onAddCity: (city: CityModel) => void;
  onRemoveCity: (city: CityModel) => void;
  formatTemp: (celsius: number) => string;
}

export function SavedCitiesScreen({
  savedCities,
  savedCitiesWeather,
  selectedCity,
  onSelectCity,
  onAddCity,
  onRemoveCity,
  formatTemp,
}: SavedCitiesScreenProps) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<CityModel[]>([]);
  const [isSearching, setIsSearching] = useState(false);

  const handleSearchChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setSearchQuery(val);
    if (val.trim().length < 2) {
      setSearchResults([]);
      return;
    }
    setIsSearching(true);
    const results = await searchCitiesApi(val);
    setSearchResults(results);
    setIsSearching(false);
  };

  const handleAddFromModal = (city: CityModel) => {
    onAddCity(city);
    setIsModalOpen(false);
    setSearchQuery('');
    setSearchResults([]);
  };

  const getWeatherIcon = (cond: string, size = 'w-6 h-6') => {
    const lower = cond.toLowerCase();
    if (lower.includes('rain') || lower.includes('drizzle')) return <CloudRain className={size} />;
    if (lower.includes('snow')) return <Snowflake className={size} />;
    if (lower.includes('cloud')) return <Cloud className={size} />;
    return <Sun className={size} />;
  };

  return (
    <div className="p-4 space-y-4">
      {/* Top Header & Add Button */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold tracking-tight text-white">Saved Cities</h2>
          <p className="text-xs text-white/70">
            Manage your favorite locations for fast weather switching
          </p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="p-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-medium flex items-center gap-1 text-xs shadow-md shadow-blue-900/30 transition-all active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>Add City</span>
        </button>
      </div>

      {/* Empty State */}
      {savedCities.length === 0 ? (
        <div className="p-8 text-center rounded-3xl bg-slate-900/60 border border-white/10 space-y-3">
          <Heart className="w-12 h-12 text-slate-500 mx-auto" />
          <h3 className="text-sm font-semibold text-white">No saved cities yet</h3>
          <p className="text-xs text-slate-400">
            Save locations you frequently travel to or keep tabs on family weather.
          </p>
          <button
            onClick={() => setIsModalOpen(true)}
            className="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold"
          >
            Add Your First City
          </button>
        </div>
      ) : (
        /* Saved Cities List */
        <div className="space-y-2.5">
          {savedCities.map((city) => {
            const key = city.name.toLowerCase();
            const weather = savedCitiesWeather[key];
            const isSelected = selectedCity.name.toLowerCase() === key;

            return (
              <div
                key={`${city.name}-${city.latitude}`}
                className={`group relative rounded-2xl p-4 transition-all border ${
                  isSelected
                    ? 'bg-blue-950/40 border-blue-500/50 shadow-lg shadow-blue-900/20'
                    : 'bg-slate-900/70 border-white/10 hover:border-white/20'
                }`}
              >
                <div className="flex items-center justify-between">
                  {/* Left: City Info & Click trigger */}
                  <div
                    onClick={() => onSelectCity(city)}
                    className="flex-1 cursor-pointer pr-3"
                  >
                    <div className="flex items-center gap-2">
                      <span className="text-base font-bold text-white">{city.name}</span>
                      {isSelected && (
                        <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-400">
                          Active
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-white/60">
                      {[city.state, city.country].filter(Boolean).join(', ')}
                    </div>
                    {weather && (
                      <div className="text-xs text-white/80 mt-1">
                        {weather.condition} · H: {formatTemp(weather.tempMax)} L:{' '}
                        {formatTemp(weather.tempMin)}
                      </div>
                    )}
                  </div>

                  {/* Right: Weather Metric and Trash button */}
                  <div className="flex items-center gap-3">
                    {weather ? (
                      <div className="text-right">
                        <div className="text-white/80 flex justify-end">
                          {getWeatherIcon(weather.condition, 'w-6 h-6')}
                        </div>
                        <div className="text-lg font-extrabold text-white tabular-nums">
                          {formatTemp(weather.temperature)}
                        </div>
                      </div>
                    ) : (
                      <div className="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                    )}

                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onRemoveCity(city);
                      }}
                      title="Remove from favorites"
                      className="p-2 rounded-xl text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Add City Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-end justify-center p-3">
          <div className="w-full max-w-sm bg-slate-900 border border-white/20 rounded-3xl p-5 shadow-2xl space-y-4 animate-in slide-in-from-bottom-5 max-h-[80vh] flex flex-col">
            <div className="flex items-center justify-between shrink-0">
              <h3 className="text-base font-bold text-white">Add Favorite City</h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-full bg-white/10 hover:bg-white/20 text-white"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Search Input */}
            <div className="relative shrink-0">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
              <input
                type="text"
                autoFocus
                value={searchQuery}
                onChange={handleSearchChange}
                placeholder="Search city (e.g. London, Rome)..."
                className="w-full pl-9 pr-3 py-2 text-sm bg-white/10 border border-white/15 rounded-xl text-white placeholder-slate-400 focus:outline-none focus:border-blue-500"
              />
            </div>

            {/* Results */}
            <div className="flex-1 overflow-y-auto divide-y divide-white/10 pr-1">
              {isSearching ? (
                <div className="py-6 text-center text-xs text-slate-400">Searching...</div>
              ) : searchResults.length > 0 ? (
                searchResults.map((city, idx) => {
                  const isAlready = savedCities.some(
                    (c) =>
                      c.name.toLowerCase() === city.name.toLowerCase() &&
                      c.country.toLowerCase() === city.country.toLowerCase()
                  );

                  return (
                    <button
                      key={`${city.name}-${city.latitude}-${idx}`}
                      disabled={isAlready}
                      onClick={() => handleAddFromModal(city)}
                      className="w-full py-2.5 px-2 flex items-center justify-between text-left hover:bg-white/5 rounded-xl transition-colors disabled:opacity-50"
                    >
                      <div>
                        <div className="text-sm font-semibold text-white">{city.name}</div>
                        <div className="text-xs text-slate-400">
                          {[city.state, city.country].filter(Boolean).join(', ')}
                        </div>
                      </div>
                      {isAlready ? (
                        <CheckCircle className="w-4 h-4 text-emerald-400 shrink-0" />
                      ) : (
                        <Plus className="w-4 h-4 text-blue-400 shrink-0" />
                      )}
                    </button>
                  );
                })
              ) : searchQuery.length >= 2 ? (
                <div className="py-6 text-center text-xs text-slate-400">
                  No matching cities found.
                </div>
              ) : (
                <div className="py-6 text-center text-xs text-slate-400">
                  Type at least 2 characters to search worldwide locations.
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
