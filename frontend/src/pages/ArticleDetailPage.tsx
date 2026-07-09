import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import api from '../services/api';
import { snippetsAPI } from '../services/api';
import type { ApiResponse, CodeSnippet } from '../types';
import { useAuth } from '../context/AuthContext';
import SnippetCard from '../components/SnippetCard';
import SnippetForm from '../components/SnippetForm';
import Header from '../components/Header';


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
  const [snippets, setSnippets] = useState<CodeSnippet[]>([]);
  const [snippetsLoading, setSnippetsLoading] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [editingSnippet, setEditingSnippet] = useState<CodeSnippet | null>(null);

  useEffect(() => {
    const fetchArticle = async () => {
      if (!slug) return;

      setLoading(true);
      try {
        const response = await api.get<ApiResponse<Article>>(`/articles/by-slug/${slug}`);

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

  useEffect(() => {
    if (!article?.articleId) return;

    const fetchSnippets = async () => {
      setSnippetsLoading(true);
      try {
        const response = await snippetsAPI.getArticleSnippets(article.articleId);
        if (response.success && response.data) {
          setSnippets(response.data);
        }
      } catch {
        // silently fail - snippets are optional
      } finally {
        setSnippetsLoading(false);
      }
    };

    fetchSnippets();
  }, [article?.articleId]);

  const handleCreateSnippet = async (data: { title: string; description?: string; language: string; code: string }) => {
    if (!article) return;
    const response = await snippetsAPI.create(article.articleId, data);
    if (response.success && response.data) {
      setSnippets((prev) => [response.data!, ...prev]);
      setShowForm(false);
    }
  };

  const handleEditSnippet = async (data: { title: string; description?: string; language: string; code: string }) => {
    if (!editingSnippet) return;
    const response = await snippetsAPI.update(editingSnippet.snippetId, data);
    if (response.success && response.data) {
      setSnippets((prev) => prev.map((s) => s.snippetId === editingSnippet.snippetId ? response.data! : s));
      setEditingSnippet(null);
      setShowForm(false);
    }
  };

  const handleDeleteSnippet = async (id: string) => {
    if (!confirm('Delete this snippet?')) return;
    const response = await snippetsAPI.delete(id);
    if (response.success) {
      setSnippets((prev) => prev.filter((s) => s.snippetId !== id));
    }
  };

  const openEditForm = (snippet: CodeSnippet) => {
    setEditingSnippet(snippet);
    setShowForm(true);
  };

  const openCreateForm = () => {
    setEditingSnippet(null);
    setShowForm(true);
  };

  const closeForm = () => {
    setShowForm(false);
    setEditingSnippet(null);
  };

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
      <Header />

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

        {/* Code Snippets Section */}
        <section className="mt-12">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Code Snippets
              {snippets.length > 0 && (
                <span className="ml-2 text-lg font-normal text-gray-500 dark:text-gray-400">({snippets.length})</span>
              )}
            </h2>
            {user && (
              <button onClick={openCreateForm} className="btn-primary text-sm">
                Add Snippet
              </button>
            )}
          </div>

          {snippetsLoading && (
            <div className="text-center py-8">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          )}

          {!snippetsLoading && snippets.length === 0 && (
            <div className="text-center py-8 text-gray-500 dark:text-gray-400">
              <p>No code snippets yet.</p>
              {user && (
                <button onClick={openCreateForm} className="mt-2 text-blue-600 dark:text-blue-400 hover:underline">
                  Add the first snippet
                </button>
              )}
            </div>
          )}

          <div className="space-y-4">
            {snippets.map((snippet) => (
              <SnippetCard
                key={snippet.snippetId}
                snippet={snippet}
                onEdit={openEditForm}
                onDelete={handleDeleteSnippet}
              />
            ))}
          </div>
        </section>
      </article>

      {showForm && (
        <SnippetForm
          snippet={editingSnippet}
          onSubmit={editingSnippet ? handleEditSnippet : handleCreateSnippet}
          onCancel={closeForm}
        />
      )}
    </div>
  );
}
