import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Header() {
  const { user, logout } = useAuth();

  return (
    <nav className="bg-white dark:bg-gray-800 shadow">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link to="/" className="text-2xl font-bold text-gray-900 dark:text-white">
            DevWiki
          </Link>
          <div className="flex items-center space-x-4">
            <Link to="/articles" className="text-blue-600 hover:text-blue-700 dark:text-blue-400">
              Articles
            </Link>
            <Link to="/search" className="text-blue-600 hover:text-blue-700 dark:text-blue-400">
              Search
            </Link>
            {user && (
              <div className="flex items-center space-x-2">
                <span className="text-gray-600 dark:text-gray-400">
                  {user.firstName} {user.lastName}
                </span>
                <button
                  onClick={logout}
                  className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition-colors text-sm"
                >
                  Logout
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}
