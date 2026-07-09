import { useEffect, useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { snippetsAPI } from '../services/api';
import type { CombinedSearchResult } from '../types';
import Header from '../components/Header';


export default function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const query = searchParams.get('q') || '';

  const [results, setResults] = useState<CombinedSearchResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [searchInput, setSearchInput] = useState(query);
  const [activeTab, setActiveTab] = useState<'all' | 'articles' | 'snippets'>('all');

  useEffect(() => {
    if (!query) return;

    const fetchResults = async () => {
      setLoading(true);
      try {
        const response = await snippetsAPI.searchAll(query, 1, 20);
        if (response.success && response.data) {
          setResults(response.data);
          setError('');
        }
      } catch (err) {
        setError('Error searching');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchResults();
  }, [query]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchInput.trim()) {
      setSearchParams({ q: searchInput.trim() });
    }
  };

  const languageBadge = (lang: string) => {
    const colors: Record<string, string> = {
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
    return colors[lang] || 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200';
  };

  const totalResults = (results?.totalArticles || 0) + (results?.totalSnippets || 0);

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Header />

      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <form onSubmit={handleSearch} className="mb-8">
          <div className="flex gap-2">
            <input
              type="text"
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              placeholder="Search articles and code snippets..."
              className="input flex-1"
            />
            <button type="submit" className="btn-primary">
              Search
            </button>
          </div>
        </form>

        {query && (
          <>
            <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
              Search Results for "{query}"
            </h1>
            <p className="text-gray-600 dark:text-gray-400 mb-6">
              {totalResults} result{totalResults !== 1 ? 's' : ''} found
              {results && (
                <> ({results.totalArticles} articles, {results.totalSnippets} snippets)</>
              )}
            </p>

            {error && (
              <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4 mb-6">
                <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
              </div>
            )}

            {loading ? (
              <div className="flex justify-center py-12">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              </div>
            ) : totalResults === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  No results found matching your search.
                </p>
                <Link to="/articles" className="btn-primary">
                  Browse All Articles
                </Link>
              </div>
            ) : (
              <>
                {/* Tabs */}
                <div className="flex gap-4 mb-6 border-b border-gray-200 dark:border-gray-700">
                  <button
                    onClick={() => setActiveTab('all')}
                    className={`pb-2 px-1 text-sm font-medium border-b-2 transition-colors ${
                      activeTab === 'all'
                        ? 'border-blue-600 text-blue-600 dark:text-blue-400 dark:border-blue-400'
                        : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
                    }`}
                  >
                    All ({totalResults})
                  </button>
                  <button
                    onClick={() => setActiveTab('articles')}
                    className={`pb-2 px-1 text-sm font-medium border-b-2 transition-colors ${
                      activeTab === 'articles'
                        ? 'border-blue-600 text-blue-600 dark:text-blue-400 dark:border-blue-400'
                        : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
                    }`}
                  >
                    Articles ({results?.totalArticles || 0})
                  </button>
                  <button
                    onClick={() => setActiveTab('snippets')}
                    className={`pb-2 px-1 text-sm font-medium border-b-2 transition-colors ${
                      activeTab === 'snippets'
                        ? 'border-blue-600 text-blue-600 dark:text-blue-400 dark:border-blue-400'
                        : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
                    }`}
                  >
                    Code Snippets ({results?.totalSnippets || 0})
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Article Results */}
                  {(activeTab === 'all' || activeTab === 'articles') && results?.articles?.map((article) => (
                    <Link
                      key={article.articleId}
                      to={`/articles/${article.slug}`}
                      className="card hover:shadow-lg transition-shadow block"
                    >
                      <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                        {article.title}
                      </h2>
                      <p className="text-gray-600 dark:text-gray-400 mb-4">{article.summary}</p>
                      <div className="flex justify-between text-sm text-gray-500 dark:text-gray-400">
                        <span className="inline-block px-3 py-1 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded">
                          {article.categoryName}
                        </span>
                        <div>
                          <span>By {article.authorName}</span>
                          <span className="mx-2">•</span>
                          <span>{article.viewCount} views</span>
                        </div>
                      </div>
                    </Link>
                  ))}

                  {/* Snippet Results */}
                  {(activeTab === 'all' || activeTab === 'snippets') && results?.codeSnippets?.map((snippet) => (
                    <Link
                      key={snippet.snippetId}
                      to={`/articles/${snippet.articleSlug}`}
                      className="card hover:shadow-lg transition-shadow block"
                    >
                      <div className="flex items-center gap-2 mb-2">
                        <h3 className="text-xl font-bold text-gray-900 dark:text-white">
                          {snippet.title}
                        </h3>
                        <span className={`inline-block px-2 py-0.5 text-xs font-medium rounded ${languageBadge(snippet.language)}`}>
                          {snippet.language}
                        </span>
                      </div>
                      {snippet.description && (
                        <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">{snippet.description}</p>
                      )}
                      <pre className="bg-gray-900 dark:bg-gray-950 text-gray-100 rounded-lg p-3 overflow-x-auto text-sm mb-2">
                        <code>{snippet.codePreview}</code>
                      </pre>
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        In article: {snippet.articleTitle}
                      </p>
                    </Link>
                  ))}
                </div>
              </>
            )}
          </>
        )}
      </div>
    </div>
  );
}
