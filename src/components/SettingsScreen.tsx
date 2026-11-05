import React, { useState } from 'react';
import {
  Settings,
  Compass,
  Thermometer,
  Wind,
  Moon,
  Sun,
  Shield,
  Key,
  Info,
  Check,
  RotateCcw,
} from 'lucide-react';
import { TempUnit, WindUnit, AppThemeMode } from '../types/weather';

interface SettingsScreenProps {
  tempUnit: TempUnit;
  windUnit: WindUnit;
  themeMode: AppThemeMode;
  apiKey: string;
  onUpdateTempUnit: (unit: TempUnit) => void;
  onUpdateWindUnit: (unit: WindUnit) => void;
  onUpdateThemeMode: (mode: AppThemeMode) => void;
  onUpdateApiKey: (key: string) => void;
  onTestGps: () => void;
}

export function SettingsScreen({
  tempUnit,
  windUnit,
  themeMode,
  apiKey,
  onUpdateTempUnit,
  onUpdateWindUnit,
  onUpdateThemeMode,
  onUpdateApiKey,
  onTestGps,
}: SettingsScreenProps) {
  const [inputKey, setInputKey] = useState(apiKey);
  const [savedNotice, setSavedNotice] = useState(false);

  const handleSaveKey = () => {
    onUpdateApiKey(inputKey.trim());
    setSavedNotice(true);
    setTimeout(() => setSavedNotice(false), 2500);
  };

  const handleClearKey = () => {
    setInputKey('');
    onUpdateApiKey('');
    setSavedNotice(true);
    setTimeout(() => setSavedNotice(false), 2500);
  };

  return (
    <div className="p-4 space-y-4">
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold tracking-tight text-white">Settings</h2>
        <p className="text-xs text-white/70">
          Units, theme, device permissions & live API configuration
        </p>
      </div>

      {/* Temperature Unit */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-3">
        <div className="flex items-center gap-2 text-xs font-bold text-white/90 uppercase tracking-wider">
          <Thermometer className="w-4 h-4 text-blue-400" />
          <span>Temperature Scale</span>
        </div>

        <div className="grid grid-cols-2 gap-2">
          <button
            onClick={() => onUpdateTempUnit('metric')}
            className={`py-2 px-3 rounded-xl text-xs font-semibold flex items-center justify-center gap-2 transition-all ${
              tempUnit === 'metric'
                ? 'bg-blue-600 text-white shadow-md shadow-blue-900/40'
                : 'bg-white/5 text-slate-300 hover:bg-white/10'
            }`}
          >
            <span>Celsius (°C)</span>
            {tempUnit === 'metric' && <Check className="w-3.5 h-3.5" />}
          </button>

          <button
            onClick={() => onUpdateTempUnit('imperial')}
            className={`py-2 px-3 rounded-xl text-xs font-semibold flex items-center justify-center gap-2 transition-all ${
              tempUnit === 'imperial'
                ? 'bg-blue-600 text-white shadow-md shadow-blue-900/40'
                : 'bg-white/5 text-slate-300 hover:bg-white/10'
            }`}
          >
            <span>Fahrenheit (°F)</span>
            {tempUnit === 'imperial' && <Check className="w-3.5 h-3.5" />}
          </button>
        </div>
      </div>

      {/* Wind Speed Unit */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-3">
        <div className="flex items-center gap-2 text-xs font-bold text-white/90 uppercase tracking-wider">
          <Wind className="w-4 h-4 text-emerald-400" />
          <span>Wind Speed Unit</span>
        </div>

        <div className="grid grid-cols-2 gap-2">
          <button
            onClick={() => onUpdateWindUnit('km/h')}
            className={`py-2 px-3 rounded-xl text-xs font-semibold flex items-center justify-center gap-2 transition-all ${
              windUnit === 'km/h'
                ? 'bg-blue-600 text-white shadow-md shadow-blue-900/40'
                : 'bg-white/5 text-slate-300 hover:bg-white/10'
            }`}
          >
            <span>Kilometers / h (km/h)</span>
            {windUnit === 'km/h' && <Check className="w-3.5 h-3.5" />}
          </button>

          <button
            onClick={() => onUpdateWindUnit('m/s')}
            className={`py-2 px-3 rounded-xl text-xs font-semibold flex items-center justify-center gap-2 transition-all ${
              windUnit === 'm/s'
                ? 'bg-blue-600 text-white shadow-md shadow-blue-900/40'
                : 'bg-white/5 text-slate-300 hover:bg-white/10'
            }`}
          >
            <span>Meters / sec (m/s)</span>
            {windUnit === 'm/s' && <Check className="w-3.5 h-3.5" />}
          </button>
        </div>
      </div>

      {/* Theme Selection */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-3">
        <div className="flex items-center gap-2 text-xs font-bold text-white/90 uppercase tracking-wider">
          <Moon className="w-4 h-4 text-purple-400" />
          <span>Theme Mode</span>
        </div>

        <div className="grid grid-cols-3 gap-2">
          {(['system', 'light', 'dark'] as AppThemeMode[]).map((mode) => (
            <button
              key={mode}
              onClick={() => onUpdateThemeMode(mode)}
              className={`py-2 px-2 rounded-xl text-xs font-semibold capitalize flex items-center justify-center gap-1.5 transition-all ${
                themeMode === mode
                  ? 'bg-blue-600 text-white shadow-md shadow-blue-900/40'
                  : 'bg-white/5 text-slate-300 hover:bg-white/10'
              }`}
            >
              {mode === 'system' && <Compass className="w-3.5 h-3.5" />}
              {mode === 'light' && <Sun className="w-3.5 h-3.5" />}
              {mode === 'dark' && <Moon className="w-3.5 h-3.5" />}
              <span>{mode}</span>
            </button>
          ))}
        </div>
      </div>

      {/* GPS Location Services */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 text-xs font-bold text-white/90 uppercase tracking-wider">
            <Shield className="w-4 h-4 text-sky-400" />
            <span>GPS Location Permission</span>
          </div>
          <button
            onClick={onTestGps}
            className="px-2.5 py-1 text-xs rounded-lg bg-blue-500/20 text-blue-400 hover:bg-blue-500/30 transition-colors"
          >
            Test Geolocation
          </button>
        </div>
        <p className="text-xs text-white/60">
          Used to automatically load live weather for your current city using Android&apos;s
          `ACCESS_FINE_LOCATION` or HTML5 Geolocation API.
        </p>
      </div>

      {/* Custom Weather API Key */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-3">
        <div className="flex items-center gap-2 text-xs font-bold text-white/90 uppercase tracking-wider">
          <Key className="w-4 h-4 text-amber-400" />
          <span>OpenWeatherMap API Key (Optional)</span>
        </div>
        <p className="text-xs text-white/60 leading-relaxed">
          SkyCast automatically streams live global forecasts via Open-Meteo with no API key
          required. You can optionally supply your personal OpenWeatherMap key below.
        </p>

        <div className="space-y-2">
          <input
            type="password"
            value={inputKey}
            onChange={(e) => setInputKey(e.target.value)}
            placeholder="Paste 32-character API key..."
            className="w-full px-3 py-2 text-xs bg-white/10 border border-white/15 rounded-xl text-white placeholder-slate-400 focus:outline-none focus:border-blue-500 font-mono"
          />

          <div className="flex items-center gap-2">
            <button
              onClick={handleSaveKey}
              className="flex-1 py-1.5 px-3 rounded-lg bg-blue-600 hover:bg-blue-500 text-xs font-semibold text-white transition-colors"
            >
              Save Key
            </button>
            <button
              onClick={handleClearKey}
              className="py-1.5 px-3 rounded-lg bg-white/10 hover:bg-white/20 text-xs text-white transition-colors flex items-center gap-1"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Reset</span>
            </button>
          </div>

          {savedNotice && (
            <div className="text-[11px] text-emerald-400 font-medium flex items-center gap-1">
              <Check className="w-3.5 h-3.5" />
              <span>Settings updated and persisted!</span>
            </div>
          )}
        </div>
      </div>

      {/* Application Information */}
      <div className="rounded-2xl p-4 bg-slate-900/70 backdrop-blur-md border border-white/10 space-y-2 text-xs">
        <div className="flex items-center gap-2 font-bold text-white/90 uppercase tracking-wider mb-2">
          <Info className="w-4 h-4 text-slate-400" />
          <span>Application Information</span>
        </div>
        <div className="flex justify-between text-slate-300">
          <span>Application</span>
          <span className="font-semibold text-white">SkyCast Weather</span>
        </div>
        <div className="flex justify-between text-slate-300">
          <span>Framework</span>
          <span className="font-semibold text-white">Flutter 3.35 · Dart 3</span>
        </div>
        <div className="flex justify-between text-slate-300">
          <span>State Management</span>
          <span className="font-semibold text-white">Provider & ChangeNotifier</span>
        </div>
        <div className="flex justify-between text-slate-300">
          <span>Charts Library</span>
          <span className="font-semibold text-white">fl_chart 0.68+</span>
        </div>
        <div className="flex justify-between text-slate-300">
          <span>Weather Data Providers</span>
          <span className="font-semibold text-white">Open-Meteo & OpenWeatherMap</span>
        </div>
      </div>
    </div>
  );
}
