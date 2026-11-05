export interface CityModel {
  name: string;
  latitude: number;
  longitude: number;
  country: string;
  state?: string;
  isFavorite?: boolean;
}

export interface WeatherModel {
  cityName: string;
  country: string;
  temperature: number; // Celsius
  feelsLike: number;
  tempMin: number;
  tempMax: number;
  condition: string;
  description: string;
  iconCode: string;
  humidity: number; // %
  windSpeed: number; // km/h
  windDirection: number; // degrees
  pressure: number; // hPa
  visibility: number; // km
  sunrise: string; // ISO
  sunset: string; // ISO
  uvIndex: number;
  isDay: boolean;
  timestamp: string;
}

export interface HourlyForecastModel {
  time: string; // ISO
  temperature: number;
  feelsLike: number;
  condition: string;
  description: string;
  iconCode: string;
  rainProbability: number;
  windSpeed: number;
  humidity: number;
  isDay: boolean;
}

export interface DailyForecastModel {
  date: string;
  dayName: string;
  tempMin: number;
  tempMax: number;
  condition: string;
  description: string;
  iconCode: string;
  rainProbability: number;
  humidity: number;
  windSpeed: number;
  uvIndex: number;
  sunrise?: string;
  sunset?: string;
}

export type TempUnit = 'metric' | 'imperial';
export type WindUnit = 'km/h' | 'm/s';
export type AppThemeMode = 'system' | 'light' | 'dark';
