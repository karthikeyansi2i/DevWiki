import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../services/api';
import type { ApiResponse } from '../types';
import Header from '../components/Header';


interface Category {
  categoryId: number;
  name: string;
  slug: string;
}

interface Tag {
  tagId: number;
  name: string;
  slug: string;
}

export default function ImportPage() {
  const navigate = useNavigate();
  const [content, setContent] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [selectedTags, setSelectedTags] = useState<number[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [tags, setTags] = useState<Tag[]>([]);
  const [loading, setLoading] = useState(true);
  const [importing, setImporting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [catRes, tagRes] = await Promise.all([
          api.get<ApiResponse<Category[]>>('/categories'),
          api.get<ApiResponse<Tag[]>>('/tags')
        ]);

        if (catRes.data.success && catRes.data.data) {
          setCategories(catRes.data.data);
          setCategoryId(catRes.data.data[0]?.categoryId?.toString() || '');
        }

        if (tagRes.data.success && tagRes.data.data) {
          setTags(tagRes.data.data);
        }
      } catch (err) {
        setError('Error loading categories and tags');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleImport = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setImporting(true);

    try {
      const response = await api.post('/articles/import', {
        content,
        categoryId: parseInt(categoryId),
        tagIds: selectedTags
      });

      if (response.data.success) {
        setSuccess(`Successfully imported ${response.data.data.createdArticles} articles!`);
        setContent('');
        setSelectedTags([]);
        setTimeout(() => navigate('/articles'), 2000);
      } else {
        setError('Import failed: ' + response.data.errors?.join(', '));
      }
    } catch (err: any) {
      setError('Error importing articles');
      console.error(err);
    } finally {
      setImporting(false);
    }
  };

  const toggleTag = (tagId: number) => {
    setSelectedTags((prev) =>
      prev.includes(tagId) ? prev.filter((id) => id !== tagId) : [...prev, tagId]
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Header />

      <div className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-8">
          Import Markdown Articles
        </h1>

        <p className="text-gray-600 dark:text-gray-400 mb-8">
          Paste markdown content with multiple articles. Each article should start with a h1 heading.
        </p>

        {error && (
          <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4 mb-6">
            <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
          </div>
        )}

        {success && (
          <div className="rounded-md bg-green-50 dark:bg-green-900/20 p-4 mb-6">
            <p className="text-sm text-green-600 dark:text-green-400">{success}</p>
          </div>
        )}

        <form onSubmit={handleImport} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Category *
            </label>
            <select
              value={categoryId}
              onChange={(e) => setCategoryId(e.target.value)}
              className="input"
              required
            >
              <option value="">Select a category</option>
              {categories.map((cat) => (
                <option key={cat.categoryId} value={cat.categoryId}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Tags
            </label>
            <div className="space-y-2">
              {tags.map((tag) => (
                <label key={tag.tagId} className="flex items-center">
                  <input
                    type="checkbox"
                    checked={selectedTags.includes(tag.tagId)}
                    onChange={() => toggleTag(tag.tagId)}
                    className="rounded border-gray-300"
                  />
                  <span className="ml-2 text-gray-700 dark:text-gray-300">{tag.name}</span>
                </label>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Markdown Content *
            </label>
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="input h-96"
              placeholder="# Article 1&#10;Content here...&#10;&#10;# Article 2&#10;More content..."
              required
            />
          </div>

          <div className="flex gap-4">
            <button type="submit" disabled={importing} className="btn-primary flex-1">
              {importing ? 'Importing...' : 'Import Articles'}
            </button>
            <Link to="/articles" className="btn-secondary flex-1 text-center">
              Cancel
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
