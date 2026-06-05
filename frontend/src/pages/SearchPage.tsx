import { useEffect, useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import api from '../services/api';
import { ApiResponse } from '../types';

interface SearchResult {
  articleId: string;
  title: string;
  slug: string;
  summary: string;
  authorName: string;
  categoryName: string;
  viewCount: number;
}

interface PaginatedResult {
  items: SearchResult[];
  page: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

export default function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const query = searchParams.get('q') || '';

  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [searchInput, setSearchInput] = useState(query);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    if (!query) return;

    const fetchResults = async () => {
      setLoading(true);
      try {
        const response = await api.get<ApiResponse<PaginatedResult>>('/search', {
          params: { q: query, page, pageSize: 20 }
        });

        if (response.data.success && response.data.data) {
          setResults(response.data.data.items);
          setTotalPages(response.data.data.totalPages);
          setError('');
        }
      } catch (err) {
        setError('Error searching articles');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchResults();
  }, [query, page]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchInput.trim()) {
      setPage(1);
      setSearchParams({ q: searchInput.trim() });
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link to="/" className="text-2xl font-bold text-gray-900 dark:text-white">
              DevWiki
            </Link>
            <Link to="/articles" className="text-blue-600 hover:text-blue-700 dark:text-blue-400">
              Articles
            </Link>
          </div>
        </div>
      </nav>

      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <form onSubmit={handleSearch} className="mb-8">
          <div className="flex gap-2">
            <input
              type="text"
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              placeholder="Search articles..."
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
            <p className="text-gray-600 dark:text-gray-400 mb-8">
              {results.length} result{results.length !== 1 ? 's' : ''} found
            </p>

            {error && (
              <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4 mb-6">
                <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
              </div>
            )}

            {loading ? (
              <div className="flex justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              </div>
            ) : results.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  No articles found matching your search.
                </p>
                <Link to="/articles" className="btn-primary">
                  Browse All Articles
                </Link>
              </div>
            ) : (
              <>
                <div className="space-y-6 mb-8">
                  {results.map((result) => (
                    <Link
                      key={result.articleId}
                      to={`/articles/${result.slug}`}
                      className="card hover:shadow-lg transition-shadow"
                    >
                      <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                        {result.title}
                      </h2>
                      <p className="text-gray-600 dark:text-gray-400 mb-4">{result.summary}</p>
                      <div className="flex justify-between text-sm text-gray-500 dark:text-gray-400">
                        <div>
                          <span className="inline-block px-3 py-1 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded mr-2">
                            {result.categoryName}
                          </span>
                        </div>
                        <div>
                          <span>By {result.authorName}</span>
                          <span className="mx-2">•</span>
                          <span>{result.viewCount} views</span>
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>

                {totalPages > 1 && (
                  <div className="flex justify-center gap-2">
                    {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
                      <button
                        key={p}
                        onClick={() => setPage(p)}
                        className={`px-4 py-2 rounded ${
                          page === p
                            ? 'bg-blue-600 text-white'
                            : 'bg-white dark:bg-gray-800 text-gray-900 dark:text-white border border-gray-300 dark:border-gray-700'
                        }`}
                      >
                        {p}
                      </button>
                    ))}
                  </div>
                )}
              </>
            )}
          </>
        )}
      </div>
    </div>
  );
}
