import { useState } from 'react';
import type { CodeSnippet } from '../types';
import { useAuth } from '../context/AuthContext';

interface SnippetCardProps {
  snippet: CodeSnippet;
  onEdit: (snippet: CodeSnippet) => void;
  onDelete: (id: string) => void;
}

const languageColors: Record<string, string> = {
  'C#': 'bg-purple-100 dark:bg-purple-900 text-purple-800 dark:text-purple-200',
  'SQL': 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200',
  'TypeScript': 'bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200',
  'JavaScript': 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200',
  'HTML': 'bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200',
  'CSS': 'bg-pink-100 dark:bg-pink-900 text-pink-800 dark:text-pink-200',
  'JSON': 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200',
  'YAML': 'bg-teal-100 dark:bg-teal-900 text-teal-800 dark:text-teal-200',
  'XML': 'bg-indigo-100 dark:bg-indigo-900 text-indigo-800 dark:text-indigo-200',
  'Bash': 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200',
  'PowerShell': 'bg-cyan-100 dark:bg-cyan-900 text-cyan-800 dark:text-cyan-200',
};

export default function SnippetCard({ snippet, onEdit, onDelete }: SnippetCardProps) {
  const [expanded, setExpanded] = useState(false);
  const [copied, setCopied] = useState(false);
  const { user } = useAuth();

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(snippet.code);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      const textarea = document.createElement('textarea');
      textarea.value = snippet.code;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const languageColor = languageColors[snippet.language] || 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200';

  return (
    <div className="card border border-gray-200 dark:border-gray-700">
      <div className="flex items-start justify-between cursor-pointer" onClick={() => setExpanded(!expanded)}>
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{snippet.title}</h3>
            <span className={`inline-block px-2 py-0.5 text-xs font-medium rounded ${languageColor}`}>
              {snippet.language}
            </span>
          </div>
          {snippet.description && (
            <p className="text-sm text-gray-600 dark:text-gray-400">{snippet.description}</p>
          )}
        </div>
        <span className="text-gray-400 dark:text-gray-500 ml-2">{expanded ? '▲' : '▼'}</span>
      </div>

      {expanded && (
        <div className="mt-4">
          <pre className="relative bg-gray-900 dark:bg-gray-950 text-gray-100 rounded-lg p-4 overflow-x-auto text-sm">
            <button
              onClick={(e) => { e.stopPropagation(); handleCopy(); }}
              className="absolute top-2 right-2 px-2 py-1 text-xs rounded bg-gray-700 hover:bg-gray-600 text-gray-200 transition-colors"
            >
              {copied ? 'Copied!' : 'Copy'}
            </button>
            <code>{snippet.code}</code>
          </pre>

          <div className="flex items-center justify-between mt-3 text-xs text-gray-500 dark:text-gray-400">
            <span>By {snippet.createdByName}</span>
            <span>{new Date(snippet.createdAt).toLocaleDateString()}</span>
          </div>

          {user && (
            <div className="flex gap-2 mt-3">
              <button
                onClick={(e) => { e.stopPropagation(); onEdit(snippet); }}
                className="px-3 py-1 text-sm rounded bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 hover:bg-blue-200 dark:hover:bg-blue-800 transition-colors"
              >
                Edit
              </button>
              <button
                onClick={(e) => { e.stopPropagation(); onDelete(snippet.snippetId); }}
                className="px-3 py-1 text-sm rounded bg-red-100 dark:bg-red-900 text-red-700 dark:text-red-300 hover:bg-red-200 dark:hover:bg-red-800 transition-colors"
              >
                Delete
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
