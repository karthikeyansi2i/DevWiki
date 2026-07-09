import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../services/api';
import type { ApiResponse } from '../types';
import Header from '../components/Header';


interface Article {
  articleId: string;
  title: string;
  slug: string;
  summary: string;
  authorName: string;
  categoryName: string;
  tags: Array<{ tagId: number; name: string }>;
  viewCount: number;
  updatedAt: string;
}

interface PaginatedResult {
  items: Article[];
  page: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

export default function ArticlesPage() {
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    const fetchArticles = async () => {
      setLoading(true);
      try {
        const response = await api.get<ApiResponse<PaginatedResult>>('/articles', {
          params: { page, pageSize: 20 }
        });

        if (response.data.success && response.data.data) {
          setArticles(response.data.data.items);
          setTotalPages(response.data.data.totalPages);
        } else {
          setError('Failed to load articles');
        }
      } catch (err) {
        setError('Error loading articles');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchArticles();
  }, [page]);

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Header />

      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 dark:text-white">Articles</h1>
          <Link to="/articles/new" className="btn-primary">
            New Article
          </Link>
        </div>

        {error && (
          <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4 mb-6">
            <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
          </div>
        )}

        {loading ? (
          <div className="flex justify-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : articles.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600 dark:text-gray-400">No articles found</p>
            <Link to="/articles/new" className="mt-4 inline-block btn-primary">
              Create First Article
            </Link>
          </div>
        ) : (
          <div className="space-y-6">
            {articles.map((article) => (
              <Link
                key={article.articleId}
                to={`/articles/${article.slug}`}
                className="card hover:shadow-lg transition-shadow"
              >
                <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
                  {article.title}
                </h2>
                <p className="text-gray-600 dark:text-gray-400 mb-4">{article.summary}</p>
                <div className="flex flex-wrap gap-2 mb-4">
                  <span className="inline-block px-3 py-1 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 text-sm rounded">
                    {article.categoryName}
                  </span>
                  {article.tags.map((tag) => (
                    <span
                      key={tag.tagId}
                      className="inline-block px-3 py-1 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-300 text-sm rounded"
                    >
                      {tag.name}
                    </span>
                  ))}
                </div>
                <div className="flex justify-between text-sm text-gray-500 dark:text-gray-400">
                  <span>By {article.authorName}</span>
                  <span>{article.viewCount} views</span>
                </div>
              </Link>
            ))}
          </div>
        )}

        {!loading && totalPages > 1 && (
          <div className="mt-8 flex justify-center gap-2">
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
      </div>
    </div>
  );
}
