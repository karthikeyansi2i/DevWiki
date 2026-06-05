import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import api from '../services/api';
import { ApiResponse } from '../types';
import { useAuth } from '../context/AuthContext';

interface Article {
  articleId: string;
  title: string;
  slug: string;
  content: string;
  summary: string;
  authorName: string;
  categoryName: string;
  tags: Array<{ tagId: number; name: string }>;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}

export default function ArticleDetailPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [article, setArticle] = useState<Article | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchArticle = async () => {
      if (!slug) return;

      setLoading(true);
      try {
        const response = await api.get<ApiResponse<Article>>(`/articles/${slug}`);

        if (response.data.success && response.data.data) {
          setArticle(response.data.data);
        } else {
          setError('Article not found');
        }
      } catch (err) {
        setError('Error loading article');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchArticle();
  }, [slug]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading...</p>
        </div>
      </div>
    );
  }

  if (error || !article) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <p className="text-xl text-red-600 dark:text-red-400">{error}</p>
          <Link to="/articles" className="mt-4 inline-block btn-primary">
            Back to Articles
          </Link>
        </div>
      </div>
    );
  }

  const isAuthor = user?.userId === article.authorName;

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
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

      <article className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <header className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
            {article.title}
          </h1>

          <div className="flex flex-wrap gap-4 text-sm text-gray-600 dark:text-gray-400 mb-6">
            <span>By {article.authorName}</span>
            <span>In {article.categoryName}</span>
            <span>{article.viewCount} views</span>
            <span>Updated {new Date(article.updatedAt).toLocaleDateString()}</span>
          </div>

          <div className="flex flex-wrap gap-2 mb-6">
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

          {isAuthor && (
            <div className="flex gap-2">
              <button onClick={() => navigate(`/articles/${article.slug}/edit`)} className="btn-primary">
                Edit
              </button>
              <button className="btn-secondary">Delete</button>
            </div>
          )}
        </header>

        <div className="prose dark:prose-invert max-w-none">
          <ReactMarkdown>{article.content}</ReactMarkdown>
        </div>
      </article>
    </div>
  );
}
