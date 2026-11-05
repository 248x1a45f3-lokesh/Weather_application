import React, { useState, useEffect, useCallback } from 'react';
import {
  Smartphone,
  Code2,
  Package,
  CheckCircle2,
  Download,
  Maximize2,
  Minimize2,
  RefreshCw,
  Sun,
  Moon,
  Laptop,
} from 'lucide-react';
import JSZip from 'jszip';
import {
  CityModel,
  WeatherModel,
  HourlyForecastModel,
  DailyForecastModel,
  TempUnit,
  WindUnit,
  AppThemeMode,
} from './types/weather';
import { fetchLiveWeather } from './services/liveWeatherService';
import { AndroidFrame } from './components/AndroidFrame';
import { HomeScreen } from './components/HomeScreen';
import { HourlyScreen } from './components/HourlyScreen';
import { WeeklyScreen } from './components/WeeklyScreen';
import { SavedCitiesScreen } from './components/SavedCitiesScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { FlutterCodeViewer } from './components/FlutterCodeViewer';
import { ApkBuildGuide } from './components/ApkBuildGuide';
import { WidgetTestRunner } from './components/WidgetTestRunner';
import { FLUTTER_PROJECT_FILES } from './data/flutterSourceCode';

const INITIAL_SAVED_CITIES: CityModel[] = [
  { name: 'London', latitude: 51.5074, longitude: -0.1278, country: 'United Kingdom', isFavorite: true },
  { name: 'New York', latitude: 40.7128, longitude: -74.006, country: 'United States', isFavorite: true },
  { name: 'Tokyo', latitude: 35.6762, longitude: 139.6503, country: 'Japan', isFavorite: true },
  { name: 'San Francisco', latitude: 37.7749, longitude: -122.4194, country: 'United States', isFavorite: true },
];

export default function App() {
  // Top-level workspace view
  const [activeWorkspaceTab, setActiveWorkspaceTab] = useState<'simulator' | 'code' | 'apk' | 'tests'>(
    'simulator'
  );

  // Android Mobile Screen Tab (0: Home, 1: Hourly, 2: 7-Day, 3: Saved, 4: Settings)
  const [activeMobileTab, setActiveMobileTab] = useState<number>(0);
  const [isDeviceMode, setIsDeviceMode] = useState<boolean>(true);

  // Settings & Preferences
  const [tempUnit, setTempUnit] = useState<TempUnit>('metric');
  const [windUnit, setWindUnit] = useState<WindUnit>('km/h');
  const [themeMode, setThemeMode] = useState<AppThemeMode>('dark');
  const [apiKey, setApiKey] = useState<string>('');

  // Weather Data & Cities State
  const [selectedCity, setSelectedCity] = useState<CityModel>(INITIAL_SAVED_CITIES[0]);
  const [savedCities, setSavedCities] = useState<CityModel[]>(INITIAL_SAVED_CITIES);
  const [weather, setWeather] = useState<WeatherModel | null>(null);
  const [hourly, setHourly] = useState<HourlyForecastModel[]>([]);
  const [daily, setDaily] = useState<DailyForecastModel[]>([]);
  const [savedCitiesWeather, setSavedCitiesWeather] = useState<Record<string, WeatherModel>>({});
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isDownloadingZip, setIsDownloadingZip] = useState<boolean>(false);

  // Load preferences from localStorage on mount
  useEffect(() => {
    try {
      const savedUnit = localStorage.getItem('skycast_temp_unit') as TempUnit;
      if (savedUnit) setTempUnit(savedUnit);

      const savedWind = localStorage.getItem('skycast_wind_unit') as WindUnit;
      if (savedWind) setWindUnit(savedWind);

      const savedTheme = localStorage.getItem('skycast_theme') as AppThemeMode;
      if (savedTheme) setThemeMode(savedTheme);

      const savedKey = localStorage.getItem('skycast_api_key');
      if (savedKey) setApiKey(savedKey);

      const savedCitiesList = localStorage.getItem('skycast_saved_cities');
      if (savedCitiesList) {
        const parsed = JSON.parse(savedCitiesList);
        if (Array.isArray(parsed) && parsed.length > 0) {
          setSavedCities(parsed);
          setSelectedCity(parsed[0]);
        }
      }
    } catch (e) {
      console.warn('Failed reading localStorage', e);
    }
  }, []);

  // Sync theme with HTML class
  useEffect(() => {
    const root = document.documentElement;
    if (themeMode === 'dark') {
      root.classList.add('dark');
    } else if (themeMode === 'light') {
      root.classList.remove('dark');
    } else {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      if (prefersDark) {
        root.classList.add('dark');
      } else {
        root.classList.remove('dark');
      }
    }
  }, [themeMode]);

  // Fetch weather for a given city
  const loadWeatherForCity = useCallback(
    async (city: CityModel) => {
      setIsLoading(true);
      setErrorMessage(null);
      try {
        const res = await fetchLiveWeather({
          latitude: city.latitude,
          longitude: city.longitude,
          cityName: city.name,
          country: city.country,
          apiKey,
        });
        setWeather(res.current);
        setHourly(res.hourly);
        setDaily(res.daily);

        // Also cache in saved cities weather dictionary
        setSavedCitiesWeather((prev) => ({
          ...prev,
          [city.name.toLowerCase()]: res.current,
        }));
      } catch (err: any) {
        console.error('Error fetching live weather:', err);
        setErrorMessage(
          err?.message || 'Unable to retrieve live meteorological data. Please retry.'
        );
      } finally {
        setIsLoading(false);
      }
    },
    [apiKey]
  );

  // Initial load
  useEffect(() => {
    loadWeatherForCity(selectedCity);
  }, [selectedCity, loadWeatherForCity]);

  // Background fetch for other saved cities
  useEffect(() => {
    const fetchOthers = async () => {
      for (const city of savedCities) {
        if (city.name.toLowerCase() !== selectedCity.name.toLowerCase()) {
          try {
            const res = await fetchLiveWeather({
              latitude: city.latitude,
              longitude: city.longitude,
              cityName: city.name,
              country: city.country,
              apiKey,
            });
            setSavedCitiesWeather((prev) => ({
              ...prev,
              [city.name.toLowerCase()]: res.current,
            }));
          } catch (_) {}
        }
      }
    };
    fetchOthers();
  }, [savedCities, selectedCity, apiKey]);

  // GPS Geolocation Handler
  const handleFetchGpsLocation = () => {
    if (!navigator.geolocation) {
      alert('Geolocation is not supported by your browser.');
      return;
    }

    setIsLoading(true);
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const lat = pos.coords.latitude;
        const lon = pos.coords.longitude;
        try {
          // Reverse geocode via Open-Meteo
          const res = await fetch(
            `https://geocoding-api.open-meteo.com/v1/search?name=${lat.toFixed(2)},${lon.toFixed(2)}&count=1&language=en&format=json`
          );
          let cityName = 'Current Location';
          let country = '';
          if (res.ok) {
            const d = await res.json();
            if (d.results && d.results.length > 0) {
              cityName = d.results[0].name;
              country = d.results[0].country || '';
            }
          }

          const gpsCity: CityModel = {
            name: cityName,
            latitude: lat,
            longitude: lon,
            country,
          };
          setSelectedCity(gpsCity);
          await loadWeatherForCity(gpsCity);
        } catch {
          const gpsCity: CityModel = {
            name: 'Local Position',
            latitude: lat,
            longitude: lon,
            country: '',
          };
          setSelectedCity(gpsCity);
          await loadWeatherForCity(gpsCity);
        } finally {
          setIsLoading(false);
        }
      },
      (err) => {
        setIsLoading(false);
        alert(`Location permission denied or unavailable: ${err.message}`);
      },
      { timeout: 10000 }
    );
  };

  // Toggle favorite
  const handleToggleFavorite = (city: CityModel) => {
    const isSaved = savedCities.some(
      (c) => c.name.toLowerCase() === city.name.toLowerCase()
    );

    let updated: CityModel[];
    if (isSaved) {
      updated = savedCities.filter(
        (c) => c.name.toLowerCase() !== city.name.toLowerCase()
      );
    } else {
      updated = [...savedCities, { ...city, isFavorite: true }];
    }
    setSavedCities(updated);
    localStorage.setItem('skycast_saved_cities', JSON.stringify(updated));
  };

  const handleAddCity = (city: CityModel) => {
    const isAlready = savedCities.some(
      (c) => c.name.toLowerCase() === city.name.toLowerCase()
    );
    if (!isAlready) {
      const updated = [...savedCities, { ...city, isFavorite: true }];
      setSavedCities(updated);
      localStorage.setItem('skycast_saved_cities', JSON.stringify(updated));
    }
  };

  const handleRemoveCity = (city: CityModel) => {
    const updated = savedCities.filter(
      (c) => c.name.toLowerCase() !== city.name.toLowerCase()
    );
    setSavedCities(updated);
    localStorage.setItem('skycast_saved_cities', JSON.stringify(updated));
  };

  // Formatting helpers
  const formatTemp = (celsius: number): string => {
    if (tempUnit === 'imperial') {
      const f = (celsius * 9) / 5 + 32;
      return `${Math.round(f)}°F`;
    }
    return `${Math.round(celsius)}°C`;
  };

  const formatWind = (speedKmh: number): string => {
    if (windUnit === 'm/s') {
      const ms = speedKmh / 3.6;
      return `${ms.toFixed(1)} m/s`;
    }
    return `${Math.round(speedKmh)} km/h`;
  };

  // Download entire Flutter project
  const handleDownloadFullProject = async () => {
    setIsDownloadingZip(true);
    try {
      const zip = new JSZip();
      const folder = zip.folder('skycast_weather_app')!;

      for (const file of FLUTTER_PROJECT_FILES) {
        folder.file(file.path, file.content);
      }

      const blob = await zip.generateAsync({ type: 'blob' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'skycast_weather_flutter_app.zip';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (e) {
      console.error(e);
    } finally {
      setIsDownloadingZip(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col font-sans selection:bg-blue-500 selection:text-white">
      {/* Top Bar Contract (3 zones: Brand, Nav links, 1 Primary Action) */}
      <header className="sticky top-0 z-50 bg-slate-950/80 backdrop-blur-xl border-b border-slate-800/80 px-6 py-3.5 flex items-center justify-between gap-8">
        {/* Zone 1: Brand title wordmark */}
        <div className="flex items-center gap-3 shrink-0">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-blue-600 to-sky-400 flex items-center justify-center shadow-md shadow-blue-500/20">
            <Smartphone className="w-5 h-5 text-white" />
          </div>
          <div>
            <div className="text-base font-extrabold tracking-tight text-white whitespace-nowrap">
              SkyCast Weather
            </div>
            <div className="text-[11px] text-slate-400 font-mono flex items-center gap-2">
              <span>Flutter 3.35</span>
              <span>·</span>
              <span>Material 3</span>
              <span>·</span>
              <span>Provider</span>
            </div>
          </div>
        </div>

        {/* Zone 2: Navigation Links */}
        <nav className="hidden md:flex items-center gap-6 text-xs font-semibold text-slate-300">
          <button
            onClick={() => setActiveWorkspaceTab('simulator')}
            className={`transition-colors whitespace-nowrap flex items-center gap-1.5 ${
              activeWorkspaceTab === 'simulator'
                ? 'text-blue-400 border-b-2 border-blue-400 pb-0.5'
                : 'hover:text-white'
            }`}
          >
            <Smartphone className="w-3.5 h-3.5" />
            <span>Android App Simulator</span>
          </button>

          <button
            onClick={() => setActiveWorkspaceTab('code')}
            className={`transition-colors whitespace-nowrap flex items-center gap-1.5 ${
              activeWorkspaceTab === 'code'
                ? 'text-blue-400 border-b-2 border-blue-400 pb-0.5'
                : 'hover:text-white'
            }`}
          >
            <Code2 className="w-3.5 h-3.5" />
            <span>Flutter Source Code (20+ Files)</span>
          </button>

          <button
            onClick={() => setActiveWorkspaceTab('apk')}
            className={`transition-colors whitespace-nowrap flex items-center gap-1.5 ${
              activeWorkspaceTab === 'apk'
                ? 'text-blue-400 border-b-2 border-blue-400 pb-0.5'
                : 'hover:text-white'
            }`}
          >
            <Package className="w-3.5 h-3.5" />
            <span>Release APK Build Guide</span>
          </button>

          <button
            onClick={() => setActiveWorkspaceTab('tests')}
            className={`transition-colors whitespace-nowrap flex items-center gap-1.5 ${
              activeWorkspaceTab === 'tests'
                ? 'text-blue-400 border-b-2 border-blue-400 pb-0.5'
                : 'hover:text-white'
            }`}
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>Widget Tests</span>
          </button>
        </nav>

        {/* Zone 3: Primary Action & Device Frame Toggle */}
        <div className="flex items-center gap-3 shrink-0">
          {activeWorkspaceTab === 'simulator' && (
            <button
              onClick={() => setIsDeviceMode((prev) => !prev)}
              title={isDeviceMode ? 'Switch to Full Screen View' : 'Switch to Android Phone Frame'}
              className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              {isDeviceMode ? (
                <>
                  <Maximize2 className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">Full Width</span>
                </>
              ) : (
                <>
                  <Minimize2 className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">Phone Frame</span>
                </>
              )}
            </button>
          )}

          <button
            onClick={handleDownloadFullProject}
            disabled={isDownloadingZip}
            className="px-4 py-2 text-xs font-bold text-white bg-blue-600 hover:bg-blue-500 rounded-xl transition-all shadow-md shadow-blue-600/30 active:scale-95 flex items-center gap-1.5 whitespace-nowrap"
          >
            <Download className="w-4 h-4" />
            <span>{isDownloadingZip ? 'Zipping...' : 'Download Project (.zip)'}</span>
          </button>
        </div>
      </header>

      {/* Main Workspace Body */}
      <main className="flex-1 p-4 md:p-6 max-w-7xl w-full mx-auto">
        {/* Workspace Tab 1: Android App Simulator */}
        {activeWorkspaceTab === 'simulator' && (
          <div className="space-y-4">
            {/* Quick Screen Switcher Toolbar for desktop convenience */}
            <div className="flex items-center justify-between bg-slate-950/60 border border-slate-800 rounded-2xl p-2.5 max-w-2xl mx-auto">
              <span className="text-xs text-slate-400 font-semibold px-2">Flutter Screens:</span>
              <div className="flex items-center gap-1 overflow-x-auto">
                {['Home (S1)', 'Hourly (S2)', '7-Day (S3)', 'Saved (S4)', 'Settings (S5)'].map(
                  (label, idx) => (
                    <button
                      key={label}
                      onClick={() => setActiveMobileTab(idx)}
                      className={`px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                        activeMobileTab === idx
                          ? 'bg-blue-600 text-white shadow-sm'
                          : 'text-slate-400 hover:text-slate-200 hover:bg-white/5'
                      }`}
                    >
                      {label}
                    </button>
                  )
                )}
              </div>
            </div>

            {/* Android Phone Simulator */}
            <AndroidFrame
              weather={weather}
              activeTab={activeMobileTab}
              onTabChange={setActiveMobileTab}
              isDeviceMode={isDeviceMode}
              onToggleDeviceMode={() => setIsDeviceMode((prev) => !prev)}
              themeMode={themeMode}
            >
              {activeMobileTab === 0 && (
                <HomeScreen
                  weather={weather}
                  hourly={hourly}
                  selectedCity={selectedCity}
                  onSelectCity={(city) => {
                    setSelectedCity(city);
                    loadWeatherForCity(city);
                  }}
                  onRefresh={() => loadWeatherForCity(selectedCity)}
                  onFetchGpsLocation={handleFetchGpsLocation}
                  onToggleFavorite={handleToggleFavorite}
                  isFavorite={savedCities.some(
                    (c) => c.name.toLowerCase() === selectedCity.name.toLowerCase()
                  )}
                  isLoading={isLoading}
                  errorMessage={errorMessage}
                  tempUnit={tempUnit}
                  windUnit={windUnit}
                  formatTemp={formatTemp}
                  formatWind={formatWind}
                />
              )}

              {activeMobileTab === 1 && (
                <HourlyScreen
                  hourly={hourly}
                  selectedCity={selectedCity}
                  tempUnit={tempUnit}
                  windUnit={windUnit}
                  formatTemp={formatTemp}
                  formatWind={formatWind}
                />
              )}

              {activeMobileTab === 2 && (
                <WeeklyScreen
                  daily={daily}
                  selectedCity={selectedCity}
                  tempUnit={tempUnit}
                  windUnit={windUnit}
                  formatTemp={formatTemp}
                  formatWind={formatWind}
                />
              )}

              {activeMobileTab === 3 && (
                <SavedCitiesScreen
                  savedCities={savedCities}
                  savedCitiesWeather={savedCitiesWeather}
                  selectedCity={selectedCity}
                  onSelectCity={(city) => {
                    setSelectedCity(city);
                    loadWeatherForCity(city);
                    setActiveMobileTab(0);
                  }}
                  onAddCity={handleAddCity}
                  onRemoveCity={handleRemoveCity}
                  formatTemp={formatTemp}
                />
              )}

              {activeMobileTab === 4 && (
                <SettingsScreen
                  tempUnit={tempUnit}
                  windUnit={windUnit}
                  themeMode={themeMode}
                  apiKey={apiKey}
                  onUpdateTempUnit={(u) => {
                    setTempUnit(u);
                    localStorage.setItem('skycast_temp_unit', u);
                  }}
                  onUpdateWindUnit={(u) => {
                    setWindUnit(u);
                    localStorage.setItem('skycast_wind_unit', u);
                  }}
                  onUpdateThemeMode={(m) => {
                    setThemeMode(m);
                    localStorage.setItem('skycast_theme', m);
                  }}
                  onUpdateApiKey={(k) => {
                    setApiKey(k);
                    localStorage.setItem('skycast_api_key', k);
                    loadWeatherForCity(selectedCity);
                  }}
                  onTestGps={handleFetchGpsLocation}
                />
              )}
            </AndroidFrame>
          </div>
        )}

        {/* Workspace Tab 2: Flutter Source Code Viewer */}
        {activeWorkspaceTab === 'code' && <FlutterCodeViewer />}

        {/* Workspace Tab 3: APK Build Guide */}
        {activeWorkspaceTab === 'apk' && <ApkBuildGuide />}

        {/* Workspace Tab 4: Widget Tests */}
        {activeWorkspaceTab === 'tests' && <WidgetTestRunner />}
      </main>

      {/* Footer */}
      <footer className="mt-auto border-t border-slate-800 bg-slate-950/60 py-4 px-6 text-center text-xs text-slate-500">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-2 max-w-7xl mx-auto">
          <span>SkyCast Weather Forecast · Built with Flutter 3.35, Dart 3, Provider & fl_chart</span>
          <span>Live Atmospheric APIs: Open-Meteo & OpenWeatherMap</span>
        </div>
      </footer>
    </div>
  );
}
