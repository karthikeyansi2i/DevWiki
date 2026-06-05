import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../services/api';
import { ApiResponse } from '../types';
import { useAuth } from '../context/AuthContext';

interface Statistics {
  totalArticles: number;
  totalCategories: number;
  totalTags: number;
  activeEditors: number;
  articlesThisMonth: number;
  mostViewedCount: number;
}

interface RecentArticle {
  articleId: string;
  title: string;
  slug: string;
  authorName: string;
  updatedAt: string;
}

export default function DashboardPage() {
  const { user, logout } = useAuth();
  const [stats, setStats] = useState<Statistics | null>(null);
  const [recentArticles, setRecentArticles] = useState<RecentArticle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchDashboardData = async () => {
      setLoading(true);
      try {
        const [statsRes, recentRes] = await Promise.all([
          api.get<ApiResponse<Statistics>>('/dashboard/statistics'),
          api.get<ApiResponse<RecentArticle[]>>('/dashboard/recent-articles')
        ]);

        if (statsRes.data.success && statsRes.data.data) {
          setStats(statsRes.data.data);
        }

        if (recentRes.data.success && recentRes.data.data) {
          setRecentArticles(recentRes.data.data);
        }
      } catch (err) {
        setError('Error loading dashboard data');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">DevWiki</h1>
            <div className="flex items-center space-x-4">
              <Link to="/articles" className="text-blue-600 hover:text-blue-700 dark:text-blue-400">
                Articles
              </Link>
              <Link to="/search" className="text-blue-600 hover:text-blue-700 dark:text-blue-400">
                Search
              </Link>
              <div className="flex items-center space-x-2">
                <span className="text-gray-600 dark:text-gray-400">
                  {user?.firstName} {user?.lastName}
                </span>
                <button
                  onClick={logout}
                  className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition-colors text-sm"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900 dark:text-white">
            Welcome to DevWiki
          </h2>
          <p className="text-gray-600 dark:text-gray-400 mt-2">
            Your internal engineering knowledge base
          </p>
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
        ) : (
          <>
            {stats && (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
                <div className="card">
                  <h3 className="text-gray-600 dark:text-gray-400 text-sm font-semibold">
                    Total Articles
                  </h3>
                  <p className="text-4xl font-bold text-gray-900 dark:text-white mt-2">
                    {stats.totalArticles}
                  </p>
                </div>

                <div className="card">
                  <h3 className="text-gray-600 dark:text-gray-400 text-sm font-semibold">
                    Categories
                  </h3>
                  <p className="text-4xl font-bold text-gray-900 dark:text-white mt-2">
                    {stats.totalCategories}
                  </p>
                </div>

                <div className="card">
                  <h3 className="text-gray-600 dark:text-gray-400 text-sm font-semibold">Tags</h3>
                  <p className="text-4xl font-bold text-gray-900 dark:text-white mt-2">
                    {stats.totalTags}
                  </p>
                </div>

                <div className="card">
                  <h3 className="text-gray-600 dark:text-gray-400 text-sm font-semibold">
                    Active Editors
                  </h3>
                  <p className="text-4xl font-bold text-gray-900 dark:text-white mt-2">
                    {stats.activeEditors}
                  </p>
                </div>

                <div className="card">
                  <h3 className="text-gray-600 dark:text-gray-400 text-sm font-semibold">
                    This Month
                  </h3>
                  <p className="text-4xl font-bold text-gray-900 dark:text-white mt-2">
                    {stats.articlesThisMonth}
                  </p>
                </div>

                <div className="card">
                  <h3 className="text-gray-600 dark:text-gray-400 text-sm font-semibold">
                    Most Viewed
                  </h3>
                  <p className="text-4xl font-bold text-gray-900 dark:text-white mt-2">
                    {stats.mostViewedCount}
                  </p>
                </div>
              </div>
            )}

            {recentArticles.length > 0 && (
              <div className="bg-white dark:bg-gray-800 rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
                  <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                    Recent Articles
                  </h3>
                </div>
                <div className="divide-y divide-gray-200 dark:divide-gray-700">
                  {recentArticles.map((article) => (
                    <Link
                      key={article.articleId}
                      to={`/articles/${article.slug}`}
                      className="px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors block"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <h4 className="text-blue-600 dark:text-blue-400 font-medium hover:underline">
                            {article.title}
                          </h4>
                          <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                            By {article.authorName}
                          </p>
                        </div>
                        <span className="text-xs text-gray-500 dark:text-gray-400">
                          {new Date(article.updatedAt).toLocaleDateString()}
                        </span>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
