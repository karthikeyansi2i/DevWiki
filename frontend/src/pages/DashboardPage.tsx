import { useAuth } from '../context/AuthContext';

export default function DashboardPage() {
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900 dark:text-white">DevWiki</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-gray-600 dark:text-gray-400">
                {user?.firstName} {user?.lastName}
              </span>
              <button
                onClick={logout}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow">
          <div className="px-4 py-6 sm:px-6">
            <h2 className="text-lg font-medium text-gray-900 dark:text-white mb-4">
              Welcome to DevWiki
            </h2>
            <p className="text-gray-600 dark:text-gray-400">
              You are logged in as <strong>{user?.email}</strong> with role <strong>{user?.role}</strong>.
            </p>
            <p className="mt-4 text-gray-600 dark:text-gray-400">
              Phase 1 is ready! Articles, categories, and search will be available in Phase 2.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
