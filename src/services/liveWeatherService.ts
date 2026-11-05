import { CityModel, WeatherModel, HourlyForecastModel, DailyForecastModel } from '../types/weather';

function mapWmoCode(code: number): { main: string; desc: string } {
  if (code === 0) return { main: 'Clear', desc: 'Clear sky' };
  if (code === 1) return { main: 'Mainly Clear', desc: 'Mainly clear' };
  if (code === 2) return { main: 'Partly Cloudy', desc: 'Partly cloudy' };
  if (code === 3) return { main: 'Overcast', desc: 'Overcast' };
  if (code >= 45 && code <= 48) return { main: 'Fog', desc: 'Foggy conditions' };
  if (code >= 51 && code <= 55) return { main: 'Drizzle', desc: 'Light drizzle' };
  if (code >= 61 && code <= 65) return { main: 'Rain', desc: 'Rain showers' };
  if (code >= 71 && code <= 77) return { main: 'Snow', desc: 'Snowfall' };
  if (code >= 80 && code <= 82) return { main: 'Rain Showers', desc: 'Heavy showers' };
  if (code >= 85 && code <= 86) return { main: 'Snow Showers', desc: 'Snow showers' };
  if (code >= 95) return { main: 'Thunderstorm', desc: 'Thunderstorm' };
  return { main: 'Clear', desc: 'Clear sky' };
}

function getDayName(date: Date, index: number): string {
  if (index === 0) return 'Today';
  return date.toLocaleDateString('en-US', { weekday: 'short' });
}

export async function searchCitiesApi(query: string): Promise<CityModel[]> {
  if (!query || query.trim().length < 2) return [];

  try {
    const res = await fetch(
      `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(query)}&count=10&language=en&format=json`
    );
    if (!res.ok) throw new Error(`Geocoding error ${res.status}`);
    const data = await res.json();
    if (!data.results) return [];

    return data.results.map((r: any) => ({
      name: r.name,
      latitude: r.latitude,
      longitude: r.longitude,
      country: r.country || r.country_code || '',
      state: r.admin1,
      isFavorite: false,
    }));
  } catch (error) {
    console.error('Failed to search cities:', error);
    return [];
  }
}

export async function fetchLiveWeather({
  latitude,
  longitude,
  cityName,
  country,
  apiKey,
}: {
  latitude: number;
  longitude: number;
  cityName: string;
  country: string;
  apiKey?: string;
}): Promise<{
  current: WeatherModel;
  hourly: HourlyForecastModel[];
  daily: DailyForecastModel[];
}> {
  // If user provided OpenWeatherMap API key
  if (apiKey && apiKey.trim().length > 10) {
    try {
      return await fetchFromOpenWeatherMap({ latitude, longitude, cityName, country, apiKey });
    } catch (e) {
      console.warn('OpenWeatherMap failed, falling back to Open-Meteo', e);
    }
  }

  // Live Open-Meteo API (High precision, free, zero keys needed)
  return await fetchFromOpenMeteo({ latitude, longitude, cityName, country });
}

async function fetchFromOpenMeteo({
  latitude,
  longitude,
  cityName,
  country,
}: {
  latitude: number;
  longitude: number;
  cityName: string;
  country: string;
}) {
  const url =
    `https://api.open-meteo.com/v1/forecast?` +
    `latitude=${latitude}&longitude=${longitude}` +
    `&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m` +
    `&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m` +
    `&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max,wind_speed_10m_max` +
    `&timezone=auto`;

  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Open-Meteo API returned status ${res.status}`);
  }

  const data = await res.json();
  const current = data.current || {};
  const daily = data.daily || {};
  const hourly = data.hourly || {};

  const now = new Date();
  const weatherCode = current.weather_code ?? 0;
  const condition = mapWmoCode(weatherCode);
  const isDay = current.is_day === 1;

  const sunrise = daily.sunrise?.[0] || now.toISOString();
  const sunset = daily.sunset?.[0] || new Date(now.getTime() + 12 * 3600000).toISOString();

  const currentWeather: WeatherModel = {
    cityName,
    country,
    temperature: current.temperature_2m ?? 20,
    feelsLike: current.apparent_temperature ?? 20,
    tempMin: daily.temperature_2m_min?.[0] ?? 15,
    tempMax: daily.temperature_2m_max?.[0] ?? 25,
    condition: condition.main,
    description: condition.desc,
    iconCode: isDay ? '01d' : '01n',
    humidity: current.relative_humidity_2m ?? 50,
    windSpeed: current.wind_speed_10m ?? 0,
    windDirection: current.wind_direction_10m ?? 0,
    pressure: current.surface_pressure ?? 1013,
    visibility: 10,
    sunrise,
    sunset,
    uvIndex: daily.uv_index_max?.[0] ?? 5,
    isDay,
    timestamp: now.toISOString(),
  };

  // Hourly (24 hours starting from current hour)
  const hourlyList: HourlyForecastModel[] = [];
  const hourlyTimes = hourly.time || [];
  const hourlyTemps = hourly.temperature_2m || [];
  const hourlyFeels = hourly.apparent_temperature || [];
  const hourlyCodes = hourly.weather_code || [];
  const hourlyPops = hourly.precipitation_probability || [];
  const hourlyWinds = hourly.wind_speed_10m || [];
  const hourlyHumids = hourly.relative_humidity_2m || [];

  let startIdx = 0;
  for (let i = 0; i < hourlyTimes.length; i++) {
    const t = new Date(hourlyTimes[i]);
    if (t.getTime() >= now.getTime() - 3600000) {
      startIdx = i;
      break;
    }
  }

  for (let i = startIdx; i < startIdx + 24 && i < hourlyTimes.length; i++) {
    const t = new Date(hourlyTimes[i]);
    const code = hourlyCodes[i] ?? 0;
    const cond = mapWmoCode(code);
    const hr = t.getHours();
    const itemIsDay = hr >= 6 && hr < 20;

    hourlyList.push({
      time: t.toISOString(),
      temperature: hourlyTemps[i] ?? 20,
      feelsLike: hourlyFeels[i] ?? 20,
      condition: cond.main,
      description: cond.desc,
      iconCode: itemIsDay ? '01d' : '01n',
      rainProbability: hourlyPops[i] ?? 0,
      windSpeed: hourlyWinds[i] ?? 0,
      humidity: hourlyHumids[i] ?? 50,
      isDay: itemIsDay,
    });
  }

  // Daily (7 days)
  const dailyList: DailyForecastModel[] = [];
  const dailyTimes = daily.time || [];
  const dailyCodes = daily.weather_code || [];
  const dailyMax = daily.temperature_2m_max || [];
  const dailyMin = daily.temperature_2m_min || [];
  const dailyPops = daily.precipitation_probability_max || [];
  const dailyWinds = daily.wind_speed_10m_max || [];
  const dailySunrises = daily.sunrise || [];
  const dailySunsets = daily.sunset || [];
  const dailyUvs = daily.uv_index_max || [];

  for (let i = 0; i < dailyTimes.length && i < 7; i++) {
    const d = new Date(dailyTimes[i]);
    const code = dailyCodes[i] ?? 0;
    const cond = mapWmoCode(code);

    dailyList.push({
      date: d.toISOString(),
      dayName: getDayName(d, i),
      tempMin: dailyMin[i] ?? 15,
      tempMax: dailyMax[i] ?? 25,
      condition: cond.main,
      description: cond.desc,
      iconCode: '01d',
      rainProbability: dailyPops[i] ?? 0,
      humidity: 60,
      windSpeed: dailyWinds[i] ?? 10,
      uvIndex: dailyUvs[i] ?? 5,
      sunrise: dailySunrises[i],
      sunset: dailySunsets[i],
    });
  }

  return {
    current: currentWeather,
    hourly: hourlyList,
    daily: dailyList,
  };
}

async function fetchFromOpenWeatherMap({
  latitude,
  longitude,
  cityName,
  country,
  apiKey,
}: {
  latitude: number;
  longitude: number;
  cityName: string;
  country: string;
  apiKey: string;
}) {
  const curRes = await fetch(
    `https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&units=metric&appid=${apiKey}`
  );
  if (!curRes.ok) throw new Error(`OpenWeatherMap error ${curRes.status}`);
  const cur = await curRes.json();

  const forecastRes = await fetch(
    `https://api.openweathermap.org/data/2.5/forecast?lat=${latitude}&lon=${longitude}&units=metric&appid=${apiKey}`
  );
  if (!forecastRes.ok) throw new Error(`OpenWeatherMap forecast error ${forecastRes.status}`);
  const fcast = await forecastRes.json();

  const weather0 = cur.weather?.[0] || {};
  const current: WeatherModel = {
    cityName: cur.name || cityName,
    country: cur.sys?.country || country,
    temperature: cur.main?.temp ?? 20,
    feelsLike: cur.main?.feels_like ?? 20,
    tempMin: cur.main?.temp_min ?? 18,
    tempMax: cur.main?.temp_max ?? 25,
    condition: weather0.main || 'Clear',
    description: weather0.description || 'Clear sky',
    iconCode: weather0.icon || '01d',
    humidity: cur.main?.humidity ?? 50,
    windSpeed: cur.wind?.speed ? cur.wind.speed * 3.6 : 10, // m/s to km/h
    windDirection: cur.wind?.deg ?? 0,
    pressure: cur.main?.pressure ?? 1013,
    visibility: (cur.visibility ?? 10000) / 1000,
    sunrise: new Date((cur.sys?.sunrise ?? Date.now() / 1000) * 1000).toISOString(),
    sunset: new Date((cur.sys?.sunset ?? Date.now() / 1000 + 43200) * 1000).toISOString(),
    uvIndex: 5,
    isDay: (weather0.icon || 'd').includes('d'),
    timestamp: new Date().toISOString(),
  };

  const list = fcast.list || [];
  const hourly: HourlyForecastModel[] = list.slice(0, 12).map((item: any) => {
    const w = item.weather?.[0] || {};
    return {
      time: new Date(item.dt * 1000).toISOString(),
      temperature: item.main?.temp ?? 20,
      feelsLike: item.main?.feels_like ?? 20,
      condition: w.main || 'Clear',
      description: w.description || 'Clear',
      iconCode: w.icon || '01d',
      rainProbability: Math.round((item.pop ?? 0) * 100),
      windSpeed: item.wind?.speed ? item.wind.speed * 3.6 : 10,
      humidity: item.main?.humidity ?? 50,
      isDay: (w.icon || 'd').includes('d'),
    };
  });

  // Group by day for daily list
  const dailyGroups: Record<string, any[]> = {};
  for (const item of list) {
    const dt = new Date(item.dt * 1000).toISOString().split('T')[0];
    if (!dailyGroups[dt]) dailyGroups[dt] = [];
    dailyGroups[dt].push(item);
  }

  const daily: DailyForecastModel[] = Object.keys(dailyGroups)
    .slice(0, 7)
    .map((dateStr, idx) => {
      const items = dailyGroups[dateStr];
      const d = new Date(dateStr);
      let min = 999;
      let max = -999;
      for (const it of items) {
        if (it.main?.temp < min) min = it.main.temp;
        if (it.main?.temp > max) max = it.main.temp;
      }
      const firstW = items[0]?.weather?.[0] || {};
      return {
        date: d.toISOString(),
        dayName: getDayName(d, idx),
        tempMin: min === 999 ? 15 : min,
        tempMax: max === -999 ? 25 : max,
        condition: firstW.main || 'Clear',
        description: firstW.description || 'Clear sky',
        iconCode: firstW.icon || '01d',
        rainProbability: Math.round((items[0]?.pop ?? 0) * 100),
        humidity: items[0]?.main?.humidity ?? 50,
        windSpeed: items[0]?.wind?.speed ? items[0].wind.speed * 3.6 : 10,
        uvIndex: 5,
      };
    });

  return { current, hourly, daily };
}
