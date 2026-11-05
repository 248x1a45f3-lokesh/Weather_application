import React, { useState } from 'react';
import {
  Folder,
  FileCode,
  Download,
  Copy,
  Check,
  Search,
  ExternalLink,
  Terminal,
  Code2,
} from 'lucide-react';
import JSZip from 'jszip';
import { FLUTTER_PROJECT_FILES, FlutterFile } from '../data/flutterSourceCode';

export function FlutterCodeViewer() {
  const [selectedFilePath, setSelectedFilePath] = useState<string>('lib/main.dart');
  const [copied, setCopied] = useState(false);
  const [searchFilter, setSearchFilter] = useState('');
  const [isZipping, setIsZipping] = useState(false);

  const selectedFile: FlutterFile =
    FLUTTER_PROJECT_FILES.find((f) => f.path === selectedFilePath) || FLUTTER_PROJECT_FILES[0];

  const filteredFiles = FLUTTER_PROJECT_FILES.filter(
    (f) =>
      f.name.toLowerCase().includes(searchFilter.toLowerCase()) ||
      f.path.toLowerCase().includes(searchFilter.toLowerCase()) ||
      f.description.toLowerCase().includes(searchFilter.toLowerCase())
  );

  const handleCopy = () => {
    navigator.clipboard.writeText(selectedFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadZip = async () => {
    setIsZipping(true);
    try {
      const zip = new JSZip();
      const rootFolder = zip.folder('skycast_flutter_app')!;

      // Add all project files into the zip
      for (const file of FLUTTER_PROJECT_FILES) {
        rootFolder.file(file.path, file.content);
      }

      // Generate zip blob
      const content = await zip.generateAsync({ type: 'blob' });
      const url = URL.createObjectURL(content);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'skycast_flutter_weather_app.zip';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Failed to create zip:', err);
    } finally {
      setIsZipping(false);
    }
  };

  const categories = [
    { key: 'root', label: 'Root Config' },
    { key: 'models', label: 'Models' },
    { key: 'services', label: 'Services' },
    { key: 'providers', label: 'Provider State' },
    { key: 'screens', label: 'Screens' },
    { key: 'widgets', label: 'Widgets' },
    { key: 'utils', label: 'Utils' },
    { key: 'tests', label: 'Tests' },
    { key: 'android', label: 'Android' },
  ];

  return (
    <div className="flex flex-col lg:flex-row h-[760px] rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 overflow-hidden shadow-sm">
      {/* Left Sidebar: File Tree */}
      <div className="w-full lg:w-72 border-r border-slate-200 dark:border-slate-800 flex flex-col bg-slate-50 dark:bg-slate-950/50">
        {/* Top Header & Zip Download */}
        <div className="p-3 border-b border-slate-200 dark:border-slate-800 space-y-2.5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 flex items-center gap-1.5">
              <Folder className="w-4 h-4 text-blue-500" />
              Flutter Project Tree
            </span>
            <span className="text-[11px] font-mono text-slate-400">
              {FLUTTER_PROJECT_FILES.length} files
            </span>
          </div>

          <button
            onClick={handleDownloadZip}
            disabled={isZipping}
            className="w-full py-2 px-3 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold flex items-center justify-center gap-2 shadow-sm transition-all active:scale-[0.98]"
          >
            <Download className="w-4 h-4" />
            <span>{isZipping ? 'Bundling Zip...' : 'Download Project (.zip)'}</span>
          </button>

          {/* Search files input */}
          <div className="relative">
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-2.5" />
            <input
              type="text"
              value={searchFilter}
              onChange={(e) => setSearchFilter(e.target.value)}
              placeholder="Filter Flutter files..."
              className="w-full pl-8 pr-2.5 py-1.5 text-xs bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg text-slate-900 dark:text-slate-100 placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
          </div>
        </div>

        {/* Scrollable File List grouped by category */}
        <div className="flex-1 overflow-y-auto p-2 space-y-3">
          {categories.map((cat) => {
            const filesInCat = filteredFiles.filter((f) => f.category === cat.key);
            if (filesInCat.length === 0) return null;

            return (
              <div key={cat.key} className="space-y-1">
                <div className="px-2 text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">
                  {cat.label}
                </div>
                {filesInCat.map((file) => {
                  const isSelected = file.path === selectedFilePath;
                  return (
                    <button
                      key={file.path}
                      onClick={() => setSelectedFilePath(file.path)}
                      className={`w-full px-2.5 py-1.5 rounded-lg text-left text-xs flex items-center justify-between group transition-colors ${
                        isSelected
                          ? 'bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 font-semibold'
                          : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800/60'
                      }`}
                    >
                      <div className="flex items-center gap-2 truncate">
                        <FileCode
                          className={`w-3.5 h-3.5 shrink-0 ${
                            isSelected
                              ? 'text-blue-600 dark:text-blue-400'
                              : 'text-slate-400 group-hover:text-slate-600'
                          }`}
                        />
                        <span className="truncate">{file.name}</span>
                      </div>
                      <span className="text-[10px] text-slate-400 font-mono shrink-0 ml-1">
                        .{file.language}
                      </span>
                    </button>
                  );
                })}
              </div>
            );
          })}
        </div>
      </div>

      {/* Right Code Viewer */}
      <div className="flex-1 flex flex-col bg-white dark:bg-slate-900 overflow-hidden">
        {/* Code Header Bar */}
        <div className="px-4 py-3 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between bg-slate-50/50 dark:bg-slate-950/30">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-sm font-bold text-slate-900 dark:text-slate-100 font-mono">
                {selectedFile.path}
              </span>
              <span className="text-[11px] px-2 py-0.5 rounded-md bg-slate-200 dark:bg-slate-800 text-slate-600 dark:text-slate-300 uppercase font-mono">
                {selectedFile.language}
              </span>
            </div>
            <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
              {selectedFile.description}
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleCopy}
              className="px-3 py-1.5 rounded-lg bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              {copied ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-500" />
                  <span>Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Code</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* Code Content with Line Numbers */}
        <div className="flex-1 overflow-auto p-4 font-mono text-xs leading-relaxed bg-slate-950 text-slate-200">
          <pre className="flex">
            {/* Line numbers column */}
            <div className="select-none pr-4 text-slate-600 text-right shrink-0">
              {selectedFile.content.split('\n').map((_, i) => (
                <div key={i}>{i + 1}</div>
              ))}
            </div>

            {/* Code text */}
            <code className="flex-1 overflow-x-auto text-slate-100 whitespace-pre">
              {selectedFile.content}
            </code>
          </pre>
        </div>

        {/* Footer command helper */}
        <div className="p-3 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-950/60 flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
          <div className="flex items-center gap-2 font-mono">
            <Terminal className="w-4 h-4 text-blue-500" />
            <span>flutter run -d android</span>
          </div>
          <span className="text-[11px]">Null-safe Dart 3.35+ · Material 3</span>
        </div>
      </div>
    </div>
  );
}
