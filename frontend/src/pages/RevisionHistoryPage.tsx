import { useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import api from '../services/api';
import type { ApiResponse } from '../types';
import Header from '../components/Header';


interface Revision {
  revisionId: string;
  revisionNumber: number;
  updatedByName: string;
  updatedAt: string;
  changeDescription?: string;
}

export default function RevisionHistoryPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [revisions, setRevisions] = useState<Revision[]>([]);
  const [articleId, setArticleId] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchRevisions = async () => {
      if (!slug) return;

      setLoading(true);
      try {
        const articleRes = await api.get<any>(`/articles/by-slug/${slug}`);
        if (articleRes.data.success && articleRes.data.data) {
          setArticleId(articleRes.data.data.articleId);

          const revisionsRes = await api.get<ApiResponse<Revision[]>>(
            `/articles/${articleRes.data.data.articleId}/revisions`
          );

          if (revisionsRes.data.success && revisionsRes.data.data) {
            setRevisions(revisionsRes.data.data);
          }
        }
      } catch (err) {
        setError('Error loading revision history');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchRevisions();
  }, [slug]);

  const handleRestore = async (revisionId: string) => {
    if (!articleId) return;

    if (confirm('Are you sure you want to restore this revision?')) {
      try {
        await api.post(`/articles/${articleId}/revisions/${revisionId}/restore`);
        navigate(`/articles/${slug}`);
      } catch (err) {
        alert('Error restoring revision');
        console.error(err);
      }
    }
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
          Revision History
        </h1>

        {error && (
          <div className="rounded-md bg-red-50 dark:bg-red-900/20 p-4 mb-6">
            <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
          </div>
        )}

        {revisions.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600 dark:text-gray-400">No revisions found</p>
          </div>
        ) : (
          <div className="space-y-4">
            {revisions.map((revision) => (
              <div key={revision.revisionId} className="card">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                      Revision #{revision.revisionNumber}
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      By {revision.updatedByName} on{' '}
                      {new Date(revision.updatedAt).toLocaleString()}
                    </p>
                  </div>
                  <button
                    onClick={() => handleRestore(revision.revisionId)}
                    className="btn-primary text-sm"
                  >
                    Restore
                  </button>
                </div>

                {revision.changeDescription && (
                  <p className="text-gray-700 dark:text-gray-300">
                    {revision.changeDescription}
                  </p>
                )}
              </div>
            ))}
          </div>
        )}

        <div className="mt-8">
          <Link to={`/articles/${slug}`} className="text-blue-600 hover:text-blue-700">
            Back to Article
          </Link>
        </div>
      </div>
    </div>
  );
}
