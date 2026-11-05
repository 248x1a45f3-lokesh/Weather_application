import React, { useState } from 'react';
import { Play, CheckCircle2, Terminal, RefreshCw, FileText } from 'lucide-react';

interface TestCase {
  name: string;
  group: string;
  status: 'pending' | 'running' | 'passed' | 'failed';
  durationMs?: number;
  logs: string[];
}

export function WidgetTestRunner() {
  const [isRunning, setIsRunning] = useState(false);
  const [tests, setTests] = useState<TestCase[]>([
    {
      group: 'CurrentWeatherCard Tests',
      name: 'CurrentWeatherCard displays correct city, temperature, and condition',
      status: 'pending',
      logs: [
        'pumpWidget(CurrentWeatherCard(weather: mockWeather))',
        'expect(find.text("San Francisco"), findsOneWidget) -> PASSED',
        'expect(find.text("Sunny skies"), findsOneWidget) -> PASSED',
        'expect(find.text("21°C"), findsOneWidget) -> PASSED',
        'expect(find.text("Feels like 21°C"), findsOneWidget) -> PASSED',
      ],
    },
    {
      group: 'WeatherProvider Unit Tests',
      name: 'WeatherProvider converts Celsius to Fahrenheit correctly',
      status: 'pending',
      logs: [
        'provider.formatTemperature(25.0) -> "25°C"',
        'provider.setTemperatureUnit("imperial")',
        'provider.formatTemperature(25.0) -> "77°F"',
        'Formula verified: (25 * 9/5) + 32 = 77 -> PASSED',
      ],
    },
    {
      group: 'CityModel Tests',
      name: 'CityModel serialization and equality logic',
      status: 'pending',
      logs: [
        'city1 == city2 with case-insensitive name/country -> TRUE',
        'city1.toJson() serialized successfully',
        'CityModel.fromJson(json) matching latitude 48.8566 -> PASSED',
      ],
    },
  ]);

  const runAllTests = async () => {
    setIsRunning(true);

    // Reset status
    setTests((prev) => prev.map((t) => ({ ...t, status: 'pending', durationMs: undefined })));

    for (let i = 0; i < tests.length; i++) {
      setTests((prev) =>
        prev.map((t, idx) => (idx === i ? { ...t, status: 'running' } : t))
      );

      // Simulate micro-execution delay
      await new Promise((r) => setTimeout(r, 450 + Math.random() * 200));

      const duration = Math.round(180 + Math.random() * 120);
      setTests((prev) =>
        prev.map((t, idx) =>
          idx === i ? { ...t, status: 'passed', durationMs: duration } : t
        )
      );
    }

    setIsRunning(false);
  };

  const allPassed = tests.every((t) => t.status === 'passed');

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header & Trigger */}
      <div className="p-6 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <FileText className="w-5 h-5 text-blue-500" />
            <h2 className="text-lg font-bold text-slate-900 dark:text-slate-100">
              Flutter Widget & Unit Test Suite (`test/widget_test.dart`)
            </h2>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            Simulates `flutter test` execution on null-safe Dart models and Material 3 widgets.
          </p>
        </div>

        <button
          onClick={runAllTests}
          disabled={isRunning}
          className="px-4 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold flex items-center gap-2 shadow-sm transition-all active:scale-95 disabled:opacity-50"
        >
          {isRunning ? (
            <>
              <RefreshCw className="w-4 h-4 animate-spin" />
              <span>Running Tests...</span>
            </>
          ) : (
            <>
              <Play className="w-4 h-4 fill-white" />
              <span>Run Test Suite</span>
            </>
          )}
        </button>
      </div>

      {/* Test List */}
      <div className="space-y-3">
        {tests.map((test) => (
          <div
            key={test.name}
            className="p-4 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm space-y-2.5"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                {test.status === 'passed' && (
                  <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />
                )}
                {test.status === 'running' && (
                  <div className="w-4 h-4 border-2 border-blue-500 border-t-transparent rounded-full animate-spin shrink-0" />
                )}
                {test.status === 'pending' && (
                  <div className="w-4 h-4 rounded-full border-2 border-slate-300 dark:border-slate-700 shrink-0" />
                )}
                <div>
                  <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                    {test.group}
                  </span>
                  <div className="text-sm font-semibold text-slate-900 dark:text-slate-100">
                    {test.name}
                  </div>
                </div>
              </div>

              {test.durationMs && (
                <span className="text-xs font-mono text-emerald-600 dark:text-emerald-400 font-semibold">
                  +{test.durationMs}ms
                </span>
              )}
            </div>

            {/* Test Console Logs */}
            <div className="p-3 rounded-xl bg-slate-950 font-mono text-[11px] text-slate-300 space-y-1 border border-slate-800">
              {test.logs.map((log, idx) => (
                <div key={idx} className="flex items-center gap-2">
                  <span className="text-slate-600">›</span>
                  <span
                    className={
                      log.includes('PASSED') || log.includes('TRUE')
                        ? 'text-emerald-400'
                        : 'text-slate-300'
                    }
                  >
                    {log}
                  </span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* Terminal Output Summary */}
      <div className="p-4 rounded-2xl bg-slate-950 border border-slate-800 text-slate-300 font-mono text-xs space-y-1">
        <div className="flex items-center gap-2 text-slate-500 mb-2">
          <Terminal className="w-4 h-4 text-blue-400" />
          <span>flutter test --coverage</span>
        </div>
        <div>00:01 +3: All tests passed!</div>
        <div className="text-emerald-400 font-semibold">✓ 3 test cases passed (100% assertions satisfied)</div>
      </div>
    </div>
  );
}
