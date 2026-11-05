import React, { useState } from 'react';
import {
  Terminal,
  Copy,
  Check,
  ShieldCheck,
  Package,
  Layers,
  HelpCircle,
  FileCheck,
} from 'lucide-react';

export function ApkBuildGuide() {
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);

  const copyCommand = (cmd: string, idx: number) => {
    navigator.clipboard.writeText(cmd);
    setCopiedIndex(idx);
    setTimeout(() => setCopiedIndex(null), 2000);
  };

  const steps = [
    {
      title: 'Step 1: Get Dependencies & Verify Flutter Environment',
      desc: 'Ensure Flutter 3.35+ is installed and verify Android SDK license agreements.',
      commands: [
        'flutter doctor',
        'cd flutter_weather_app',
        'flutter pub get',
      ],
    },
    {
      title: 'Step 2: Run Flutter Widget & Unit Tests',
      desc: 'Verify that all models, provider conversions, and UI widgets pass verification before compilation.',
      commands: [
        'flutter test',
      ],
    },
    {
      title: 'Step 3: Generate Standalone Release APK',
      desc: 'Compiles the full universal APK with native ARM and x86 binaries ready to sideload on physical Android phones.',
      commands: [
        'flutter build apk --release',
      ],
      output: 'build/app/outputs/flutter-apk/app-release.apk',
    },
    {
      title: 'Step 4: Generate Split Per-ABI APKs (Recommended for smaller downloads)',
      desc: 'Produces separate, lean APKs for arm64-v8a, armeabi-v7a, and x86_64, reducing file sizes by up to 60%.',
      commands: [
        'flutter build apk --split-per-abi --release',
      ],
      output: 'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk',
    },
    {
      title: 'Step 5: Generate Android App Bundle (.aab) for Google Play Store',
      desc: 'Google Play Store requires an .aab bundle so Google can generate dynamic optimized splits for each user device.',
      commands: [
        'flutter build appbundle --release',
      ],
      output: 'build/app/outputs/bundle/release/app-release.aab',
    },
    {
      title: 'Step 6: Keystore Signing Configuration (Production Distribution)',
      desc: 'To publish on Google Play Store, sign your APK or bundle with a private release keystore.',
      commands: [
        'keytool -genkey -v -keystore ~/skycast-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias skycast',
      ],
    },
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Overview Banner */}
      <div className="p-6 rounded-3xl bg-gradient-to-r from-blue-600 to-indigo-700 text-white shadow-lg space-y-2">
        <div className="flex items-center gap-2">
          <Package className="w-6 h-6 text-blue-200" />
          <h2 className="text-xl font-bold tracking-tight">
            Android Release APK & App Bundle Build Instructions
          </h2>
        </div>
        <p className="text-sm text-blue-100 max-w-2xl leading-relaxed">
          Follow these standardized steps to compile, sign, and export the SkyCast Weather Flutter
          application into a production-grade APK or Google Play Store bundle.
        </p>
      </div>

      {/* Build Steps List */}
      <div className="space-y-4">
        {steps.map((step, idx) => (
          <div
            key={step.title}
            className="p-5 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 shadow-sm space-y-3"
          >
            <div className="flex items-start justify-between">
              <div>
                <h3 className="text-base font-bold text-slate-900 dark:text-slate-100">
                  {step.title}
                </h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">{step.desc}</p>
              </div>
              <span className="text-xs font-mono px-2 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300">
                0{idx + 1}
              </span>
            </div>

            {/* Command block */}
            <div className="relative rounded-xl bg-slate-950 p-3 font-mono text-xs text-slate-200 flex items-center justify-between border border-slate-800">
              <div className="space-y-1 overflow-x-auto pr-8">
                {step.commands.map((cmd) => (
                  <div key={cmd} className="flex items-center gap-2">
                    <span className="text-blue-400 select-none">$</span>
                    <span>{cmd}</span>
                  </div>
                ))}
              </div>

              <button
                onClick={() => copyCommand(step.commands.join(' && '), idx)}
                className="absolute right-3 top-3 p-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
                title="Copy command"
              >
                {copiedIndex === idx ? (
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                ) : (
                  <Copy className="w-3.5 h-3.5" />
                )}
              </button>
            </div>

            {step.output && (
              <div className="text-[11px] text-slate-500 dark:text-slate-400 font-mono flex items-center gap-1.5">
                <FileCheck className="w-3.5 h-3.5 text-emerald-500" />
                <span>Output Artifact:</span>
                <span className="text-slate-700 dark:text-slate-200 font-semibold">
                  {step.output}
                </span>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Signing Config Guide */}
      <div className="p-5 rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-slate-900 dark:text-slate-100">
          <ShieldCheck className="w-4 h-4 text-emerald-500" />
          <span>Configuring `android/key.properties` for Automated Signing</span>
        </div>
        <p className="text-xs text-slate-500 dark:text-slate-400 leading-relaxed">
          Create a file named <code className="font-mono text-blue-600 dark:text-blue-400">key.properties</code> in the{' '}
          <code className="font-mono text-blue-600 dark:text-blue-400">android/</code> directory to sign APKs automatically without typing passwords:
        </p>

        <pre className="p-3 rounded-xl bg-slate-950 text-slate-200 font-mono text-xs overflow-x-auto border border-slate-800">
{`storePassword=mySecretStorePassword
keyPassword=mySecretKeyPassword
keyAlias=skycast
storeFile=/Users/developer/skycast-release-key.jks`}
        </pre>
      </div>
    </div>
  );
}
