-- ============================================
-- 08_articles_react.sql
-- 8 articles in the React category (CategoryId = 4)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000018',
  'React Hooks: A Comprehensive Guide',
  'react-hooks-comprehensive-guide',
  'A deep dive into React Hooks covering useState, useEffect, useContext, useRef, useMemo, useCallback, and custom hooks with practical examples and best practices.',
  $$
## Introduction

React Hooks, introduced in React 16.8, revolutionized how developers write components by enabling state and lifecycle features in functional components. Before hooks, class components were the only way to manage state and side effects. Hooks provide a more direct API for these concepts, resulting in cleaner, more composable code.

## useState

The `useState` hook is the primary mechanism for adding local state to functional components:

```tsx
import { useState } from 'react';

interface CounterProps {
  initialValue?: number;
}

export function Counter({ initialValue = 0 }: CounterProps) {
  const [count, setCount] = useState(initialValue);
  const [history, setHistory] = useState<number[]>([]);

  const increment = () => {
    setCount(prev => {
      const next = prev + 1;
      setHistory(h => [...h, next]);
      return next;
    });
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>Increment</button>
      <p>Changes: {history.length}</p>
    </div>
  );
}
```

State updates are asynchronous and batched in React 18. Always use the functional updater form when the new state depends on the previous state.

## useEffect

The `useEffect` hook handles side effects such as data fetching, subscriptions, and DOM manipulation:

```tsx
import { useState, useEffect } from 'react';

interface User {
  id: number;
  name: string;
  email: string;
}

export function UserProfile({ userId }: { userId: number }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function fetchUser() {
      setLoading(true);
      try {
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();
        if (!cancelled) {
          setUser(data);
        }
      } catch (error) {
        if (!cancelled) {
          console.error('Failed to fetch user:', error);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchUser();
    return () => { cancelled = true; };
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}
```

The cleanup function returned by `useEffect` prevents memory leaks and race conditions.

## useRef

`useRef` persists values across renders without causing re-renders:

```tsx
import { useRef, useEffect } from 'react';

export function AutoFocusInput() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return <input ref={inputRef} type="text" placeholder="Auto-focused" />;
}
```

## Performance Hooks

| Hook | Purpose | When to Use |
|---|---|---|
| `useMemo` | Memoizes computed values | Expensive calculations |
| `useCallback` | Memoizes function references | Passing callbacks to memoized children |
| `useMemo` | Reference stability | Preventing unnecessary re-renders |

```tsx
import { useMemo, useCallback, useState } from 'react';

export function SearchList({ items }: { items: string[] }) {
  const [query, setQuery] = useState('');

  const filteredItems = useMemo(
    () => items.filter(item => item.toLowerCase().includes(query.toLowerCase())),
    [items, query]
  );

  const handleSearch = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => setQuery(e.target.value),
    []
  );

  return (
    <div>
      <input type="text" onChange={handleSearch} placeholder="Search..." />
      <ul>
        {filteredItems.map((item, i) => <li key={i}>{item}</li>)}
      </ul>
    </div>
  );
}
```

## Rules of Hooks

- Only call hooks at the top level of a component or custom hook
- Only call hooks from React function components or custom hooks
- Do not call hooks inside conditions, loops, or nested functions

## References

- [React Hooks Documentation](https://react.dev/reference/react)
- [Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks)
- [Using the Effect Hook](https://react.dev/reference/react/useEffect)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  8920,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000019',
  'State Management with React Context',
  'state-management-with-react-context',
  'Learn how to manage application state using the React Context API, including Context creation, Provider patterns, performance considerations, and when to choose Context over Redux.',
  $$
## Introduction

The React Context API provides a built-in mechanism for sharing state across a component tree without prop drilling. While it is not a full state management solution like Redux or Zustand, it handles many common use cases effectively with zero additional dependencies.

## Creating a Context

A Context consists of a provider that supplies values and consumers that read them:

```tsx
import { createContext, useContext, useState, ReactNode } from 'react';

interface AuthState {
  user: { id: string; name: string; role: string } | null;
  token: string | null;
}

interface AuthContextValue extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthState['user']>(null);
  const [token, setToken] = useState<string | null>(null);

  const login = async (email: string, password: string) => {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await response.json();
    setUser(data.user);
    setToken(data.token);
    localStorage.setItem('token', data.token);
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem('token');
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        login,
        logout,
        isAuthenticated: !!user,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
```

## Consuming Context

Custom hooks provide type-safe access to context values:

```tsx
import { useAuth } from './AuthContext';

export function UserMenu() {
  const { user, logout, isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <a href="/login">Sign In</a>;
  }

  return (
    <div className="user-menu">
      <span>Welcome, {user?.name}</span>
      <button onClick={logout}>Sign Out</button>
    </div>
  );
}
```

## Performance Considerations

Context re-renders all consumers when any value in the provider changes. Mitigate this with:

| Strategy | Approach | Best For |
|---|---|---|
| Split contexts | Separate concerns into multiple contexts | Unrelated state domains |
| useMemo | Memoize the context value object | Stable reference requirements |
| Component composition | Pass children as props | Layout state |

```tsx
// Split contexts to avoid unnecessary re-renders
const ThemeContext = createContext<ThemeValue>(defaultTheme);
const UserContext = createContext<UserValue | null>(null);

export function AppProviders({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <UserProvider>
        {children}
      </UserProvider>
    </ThemeProvider>
  );
}
```

## Context vs Redux

| Feature | Context | Redux |
|---|---|---|
| Boilerplate | Minimal | Significant |
| Middleware | None | Extensive middleware ecosystem |
| DevTools | Basic | Rich DevTools |
| Performance | Re-renders all consumers | Selector-based subscriptions |
| Best for | Small to medium apps, theme, auth | Large apps, complex state logic |

## References

- [React Context Documentation](https://react.dev/reference/react/createContext)
- [Context API Best Practices](https://react.dev/learn/scaling-up-with-reducer-and-context)
- [When to Use Context vs Redux](https://redux.js.org/usage/usage-with-typescript)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  7431,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000001a',
  'React Router v6 Complete Guide',
  'react-router-v6-complete-guide',
  'A comprehensive guide to React Router v6 covering client-side routing, nested routes, loaders, actions, route parameters, and navigation patterns for modern React applications.',
  $$
## Introduction

React Router v6 represents a significant evolution from previous versions, introducing a declarative, component-based routing API built on modern React patterns. It embraces nested routing, relative links, and data-loading primitives that streamline building multi-page applications.

## Setting Up Routes

The foundation of React Router is the `BrowserRouter` and `Routes` components:

```bash
npm install react-router-dom
```

```tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { Articles } from './pages/Articles';
import { ArticleDetail } from './pages/ArticleDetail';
import { NotFound } from './pages/NotFound';

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    errorElement: <NotFound />,
    children: [
      { index: true, element: <Dashboard /> },
      {
        path: 'articles',
        element: <Articles />,
      },
      {
        path: 'articles/:slug',
        element: <ArticleDetail />,
      },
    ],
  },
]);

export function App() {
  return <RouterProvider router={router} />;
}
```

## Nested Routes and Layouts

Nested routes allow parent layouts to persist while child content changes:

```tsx
import { Outlet, NavLink } from 'react-router-dom';

export function Layout() {
  return (
    <div>
      <nav>
        <NavLink to="/" end>Dashboard</NavLink>
        <NavLink to="/articles">Articles</NavLink>
      </nav>
      <main>
        <Outlet />
      </main>
    </div>
  );
}
```

The `Outlet` component renders the matched child route, enabling persistent layouts.

## Route Parameters and Navigation

Access dynamic segments with `useParams` and navigate programmatically with `useNavigate`:

```tsx
import { useParams, useNavigate, Link } from 'react-router-dom';

interface ArticleParams {
  slug: string;
}

export function ArticleDetail() {
  const { slug } = useParams<ArticleParams>();
  const navigate = useNavigate();

  // Fetch article by slug
  const article = useArticle(slug);

  if (!article) {
    return <div>Article not found</div>;
  }

  return (
    <article>
      <button onClick={() => navigate('/articles')}>
        Back to Articles
      </button>
      <h1>{article.title}</h1>
      <div>{article.content}</div>
      <Link to={`/articles/${slug}/edit`}>Edit</Link>
    </article>
  );
}
```

## Data Loading with Loaders

React Router v6.4+ introduced loaders for fetching data before rendering:

```tsx
import { defer, LoaderFunctionArgs } from 'react-router-dom';

async function getArticles() {
  const response = await fetch('/api/articles');
  return response.json();
}

export async function articlesLoader() {
  return defer({
    articles: getArticles(),
  });
}

// Route definition
const router = createBrowserRouter([
  {
    path: '/articles',
    element: <Articles />,
    loader: articlesLoader,
  },
]);
```

## Route Comparison

| Feature | v5 | v6 |
|---|---|---|
| Route definition | `<Route component={...}>` | `<Route element={...}>` |
| Exact matching | `exact` prop | `index` or path specificity |
| Nested routes | Manual nesting | Automatic with `<Outlet>` |
| Navigation | `history.push` | `useNavigate` |
| Data loading | Manual in component | Loaders and actions |
| Relative links | Absolute paths | Relative by default |

## References

- [React Router Documentation](https://reactrouter.com/en/main)
- [React Router v6 Upgrade Guide](https://reactrouter.com/en/main/upgrading/remix)
- [Data Loading with React Router](https://reactrouter.com/en/main/route/loader)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  6280,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000001b',
  'Performance Optimization in React',
  'performance-optimization-in-react',
  'Master React performance optimization techniques including React.memo, useMemo, useCallback, code splitting, virtualization, and profiling to build fast, responsive UIs.',
  $$
## Introduction

Performance optimization in React requires understanding when and why components re-render. By identifying unnecessary renders, optimizing expensive computations, and leveraging React's built-in tools, you can build applications that remain responsive even as complexity grows.

## Profiling First

Always measure before optimizing. React DevTools Profiler records render timings:

```tsx
import { Profiler } from 'react';

function onRenderCallback(
  id: string,
  phase: 'mount' | 'update',
  actualDuration: number,
  baseDuration: number,
  startTime: number,
  commitTime: number
) {
  console.log(`Component ${id} ${phase}: ${actualDuration}ms`);
}

export function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Dashboard />
    </Profiler>
  );
}
```

## React.memo

`React.memo` prevents re-renders when props remain the same:

```tsx
import { memo } from 'react';

interface ExpenseRowProps {
  label: string;
  amount: number;
  currency: string;
}

export const ExpenseRow = memo(function ExpenseRow({
  label,
  amount,
  currency,
}: ExpenseRowProps) {
  return (
    <tr>
      <td>{label}</td>
      <td>{amount.toFixed(2)} {currency}</td>
    </tr>
  );
});

// Parent component
export function ExpenseTable({ expenses }: { expenses: ExpenseRowProps[] }) {
  return (
    <table>
      <tbody>
        {expenses.map((exp, i) => (
          <ExpenseRow key={i} {...exp} />
        ))}
      </tbody>
    </table>
  );
}
```

## Code Splitting

Lazy loading reduces initial bundle size by splitting code at route boundaries:

```tsx
import { lazy, Suspense } from 'react';

const ArticleEditor = lazy(() => import('./pages/ArticleEditor'));
const AnalyticsDashboard = lazy(() => import('./pages/AnalyticsDashboard'));

export function App() {
  return (
    <Suspense fallback={<div className="spinner">Loading...</div>}>
      <Routes>
        <Route path="/editor" element={<ArticleEditor />} />
        <Route path="/analytics" element={<AnalyticsDashboard />} />
      </Routes>
    </Suspense>
  );
}
```

## Virtualization

For long lists, virtualization renders only visible items:

```tsx
import { useRef, useCallback } from 'react';

interface VirtualListProps<T> {
  items: T[];
  itemHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
  overscan?: number;
}

export function VirtualList<T>({
  items,
  itemHeight,
  renderItem,
  overscan = 5,
}: VirtualListProps<T>) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [scrollTop, setScrollTop] = useState(0);
  const containerHeight = containerRef.current?.clientHeight ?? 600;

  const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - overscan);
  const endIndex = Math.min(
    items.length,
    Math.ceil((scrollTop + containerHeight) / itemHeight) + overscan
  );

  const visibleItems = items.slice(startIndex, endIndex);
  const offsetY = startIndex * itemHeight;

  return (
    <div
      ref={containerRef}
      onScroll={() => setScrollTop(containerRef.current?.scrollTop ?? 0)}
      style={{ height: '600px', overflow: 'auto' }}
    >
      <div style={{ height: items.length * itemHeight, position: 'relative' }}>
        <div style={{ transform: `translateY(${offsetY}px)` }}>
          {visibleItems.map((item, i) => renderItem(item, startIndex + i))}
        </div>
      </div>
    </div>
  );
}
```

## Optimization Checklist

| Technique | Impact | Complexity |
|---|---|---|
| React.memo | Medium | Low |
| useMemo/useCallback | Medium | Low |
| Code splitting | High | Medium |
| Virtualization | High | Medium |
| Suspense streaming | High | High |
| Image lazy loading | Medium | Low |

## References

- [React Performance Optimization](https://react.dev/reference/react/memo)
- [React DevTools Profiler](https://react.dev/learn/react-developer-tools)
- [Code Splitting in React](https://react.dev/reference/react/lazy)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  9578,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000001c',
  'Testing React Components',
  'testing-react-components',
  'Learn how to test React components effectively using React Testing Library and Vitest, covering unit tests, integration tests, user interaction tests, and async behavior.',
  $$
## Introduction

Testing React components ensures your UI behaves as expected and prevents regressions. React Testing Library (RTL) encourages testing components from the user's perspective — focusing on behavior rather than implementation details.

## Setting Up Testing

Install the required testing dependencies:

```bash
npm install vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
```

Configure Vitest in `vitest.config.ts`:

```tsx
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test-setup.ts'],
  },
});
```

Create a setup file to extend matchers:

```tsx
import '@testing-library/jest-dom/vitest';
```

## Testing Basic Rendering

Test that components render expected content:

```tsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { Greeting } from './Greeting';

describe('Greeting', () => {
  it('renders the user name when provided', () => {
    render(<Greeting name="Alice" />);
    expect(screen.getByText('Hello, Alice!')).toBeInTheDocument();
  });

  it('renders a default greeting when no name is provided', () => {
    render(<Greeting />);
    expect(screen.getByText('Hello, Guest!')).toBeInTheDocument();
  });
});
```

```tsx
// Component under test
interface GreetingProps {
  name?: string;
}

export function Greeting({ name }: GreetingProps) {
  return <h1>Hello, {name ?? 'Guest'}!</h1>;
}
```

## Testing User Interactions

Use `@testing-library/user-event` to simulate realistic interactions:

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { vi } from 'vitest';
import { SearchBox } from './SearchBox';

describe('SearchBox', () => {
  it('calls onSearch when the user types and submits', async () => {
    const onSearch = vi.fn();
    const user = userEvent.setup();

    render(<SearchBox onSearch={onSearch} />);

    const input = screen.getByPlaceholderText('Search...');
    await user.type(input, 'React testing');
    await user.keyboard('{Enter}');

    expect(onSearch).toHaveBeenCalledWith('React testing');
  });

  it('clears the input after submission', async () => {
    const user = userEvent.setup();
    render(<SearchBox onSearch={vi.fn()} />);

    const input = screen.getByPlaceholderText('Search...');
    await user.type(input, 'clear me');
    await user.keyboard('{Enter}');

    expect(input).toHaveValue('');
  });
});
```

## Testing Async Operations

Components that fetch data need async test utilities:

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import { UserProfile } from './UserProfile';

describe('UserProfile', () => {
  it('displays user data after loading', async () => {
    const mockUser = { id: 1, name: 'Bob', email: 'bob@example.com' };
    global.fetch = vi.fn().mockResolvedValue({
      json: () => Promise.resolve(mockUser),
    });

    render(<UserProfile userId={1} />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('Bob')).toBeInTheDocument();
    });

    expect(screen.getByText('bob@example.com')).toBeInTheDocument();
  });

  it('handles fetch errors gracefully', async () => {
    global.fetch = vi.fn().mockRejectedValue(new Error('Network error'));

    render(<UserProfile userId={1} />);

    await waitFor(() => {
      expect(screen.getByText(/failed/i)).toBeInTheDocument();
    });
  });
});
```

## Testing Best Practices

| Practice | Why |
|---|---|
| Test by accessible roles | `getByRole('button')` over `getByText('Submit')` |
| Avoid testing implementation | Test behavior, not internal state |
| Use `findBy*` for async elements | Combines `waitFor` + `getBy*` |
| Test error states | Ensure error boundaries work |

## References

- [React Testing Library Docs](https://testing-library.com/docs/react-testing-library/intro)
- [Vitest Documentation](https://vitest.dev/guide/)
- [Common Testing Mistakes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  5187,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000001d',
  'Building Forms in React',
  'building-forms-in-react',
  'A practical guide to building forms in React covering controlled and uncontrolled components, validation strategies, form libraries like React Hook Form, and accessibility.',
  $$
## Introduction

Forms are a critical part of most web applications. React provides several approaches for form handling, from simple controlled components to sophisticated libraries like React Hook Form and Formik. Choosing the right approach depends on form complexity, validation requirements, and performance needs.

## Controlled Components

Controlled components store form state in React state, giving full control over values and validation:

```tsx
import { useState, FormEvent } from 'react';

interface LoginFormState {
  email: string;
  password: string;
}

interface ValidationErrors {
  email?: string;
  password?: string;
}

export function LoginForm() {
  const [values, setValues] = useState<LoginFormState>({
    email: '',
    password: '',
  });
  const [errors, setErrors] = useState<ValidationErrors>({});
  const [submitting, setSubmitting] = useState(false);

  const validate = (): boolean => {
    const newErrors: ValidationErrors = {};

    if (!values.email) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(values.email)) {
      newErrors.email = 'Invalid email format';
    }

    if (!values.password) {
      newErrors.password = 'Password is required';
    } else if (values.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setValues(prev => ({ ...prev, [name]: value }));
    if (errors[name as keyof ValidationErrors]) {
      setErrors(prev => ({ ...prev, [name]: undefined }));
    }
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setSubmitting(true);
    try {
      await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(values),
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          value={values.email}
          onChange={handleChange}
          aria-invalid={!!errors.email}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {errors.email && (
          <span id="email-error" role="alert">{errors.email}</span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          name="password"
          type="password"
          value={values.password}
          onChange={handleChange}
          aria-invalid={!!errors.password}
        />
        {errors.password && (
          <span role="alert">{errors.password}</span>
        )}
      </div>

      <button type="submit" disabled={submitting}>
        {submitting ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  );
}
```

## React Hook Form

For complex forms, React Hook Form reduces boilerplate and improves performance by isolating re-renders:

```bash
npm install react-hook-form @hookform/resolvers zod
```

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  fullName: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  age: z.coerce.number().min(18, 'Must be 18 or older'),
  bio: z.string().max(500, 'Bio must be under 500 characters').optional(),
});

type ProfileFormData = z.infer<typeof schema>;

export function ProfileForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ProfileFormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      fullName: '',
      email: '',
      bio: '',
    },
  });

  const onSubmit = async (data: ProfileFormData) => {
    await fetch('/api/profile', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="fullName">Full Name</label>
        <input id="fullName" {...register('fullName')} />
        {errors.fullName && <span role="alert">{errors.fullName.message}</span>}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input id="email" type="email" {...register('email')} />
        {errors.email && <span role="alert">{errors.email.message}</span>}
      </div>

      <div>
        <label htmlFor="age">Age</label>
        <input id="age" type="number" {...register('age')} />
        {errors.age && <span role="alert">{errors.age.message}</span>}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Saving...' : 'Save Profile'}
      </button>
    </form>
  );
}
```

## Form Comparison

| Approach | Learning Curve | Bundle Size | Performance | Best For |
|---|---|---|---|---|
| Controlled components | Low | None | Moderate | Simple forms |
| React Hook Form | Medium | ~8 KB | Excellent | Complex, large forms |
| Formik | Medium | ~12 KB | Good | Moderate forms |
| Final Form | Medium | ~10 KB | Good | Subscription-based forms |

## References

- [React Forms Documentation](https://react.dev/reference/react-dom/components/input)
- [React Hook Form](https://react-hook-form.com/)
- [Formik Documentation](https://formik.org/docs/overview)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  4396,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000001e',
  'Custom Hooks for Reusable Logic',
  'custom-hooks-for-reusable-logic',
  'Master the art of creating custom React hooks to extract and reuse stateful logic across components, with practical examples including useLocalStorage, useDebounce, useAsync, and useMediaQuery.',
  $$
## Introduction

Custom hooks are the primary mechanism for reusing stateful logic in React. They allow you to extract component logic into reusable functions that can share state, effects, and callbacks without altering the component hierarchy. This pattern reduces duplication, improves testability, and enforces separation of concerns.

## Hook Patterns

A custom hook is a JavaScript function that starts with `use` and may call other hooks:

```tsx
import { useState, useCallback } from 'react';

// useToggle — a simple boolean toggle hook
export function useToggle(initial = false) {
  const [value, setValue] = useState(initial);

  const toggle = useCallback(() => setValue(prev => !prev), []);
  const setTrue = useCallback(() => setValue(true), []);
  const setFalse = useCallback(() => setValue(false), []);

  return { value, toggle, setTrue, setFalse, setValue };
}

// Usage
function ExpandableSection({ title, children }: { title: string; children: React.ReactNode }) {
  const { value: isOpen, toggle } = useToggle(false);

  return (
    <section>
      <button onClick={toggle} aria-expanded={isOpen}>
        {title} {isOpen ? '▲' : '▼'}
      </button>
      {isOpen && <div>{children}</div>}
    </section>
  );
}
```

## useLocalStorage

Persist state across sessions with localStorage:

```tsx
import { useState, useEffect, useCallback } from 'react';

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = useCallback(
    (value: T | ((val: T) => T)) => {
      setStoredValue(prev => {
        const nextValue = value instanceof Function ? value(prev) : value;
        try {
          window.localStorage.setItem(key, JSON.stringify(nextValue));
        } catch (error) {
          console.error(`Error writing localStorage key "${key}":`, error);
        }
        return nextValue;
      });
    },
    [key]
  );

  return [storedValue, setValue] as const;
}

// Usage
function ThemeToggle() {
  const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light');

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
  }, [theme]);

  return (
    <button onClick={() => setTheme(prev => prev === 'light' ? 'dark' : 'light')}>
      Switch to {theme === 'light' ? 'Dark' : 'Light'} Mode
    </button>
  );
}
```

## useDebounce

Debounce rapidly changing values for search or autocomplete:

```tsx
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delayMs: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delayMs);
    return () => clearTimeout(timer);
  }, [value, delayMs]);

  return debouncedValue;
}

// Usage in search
function SearchResults() {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 400);
  const [results, setResults] = useState<string[]>([]);

  useEffect(() => {
    if (!debouncedQuery) {
      setResults([]);
      return;
    }

    const controller = new AbortController();

    fetch(`/api/search?q=${encodeURIComponent(debouncedQuery)}`, {
      signal: controller.signal,
    })
      .then(res => res.json())
      .then(data => setResults(data))
      .catch(err => {
        if (err.name !== 'AbortError') console.error(err);
      });

    return () => controller.abort();
  }, [debouncedQuery]);

  return (
    <div>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <ul>
        {results.map((r, i) => <li key={i}>{r}</li>)}
      </ul>
    </div>
  );
}
```

## useMediaQuery

Respond to CSS media queries in component logic:

```tsx
import { useState, useEffect } from 'react';

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => window.matchMedia(query).matches);

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);

    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, [query]);

  return matches;
}

// Usage
function ResponsiveLayout() {
  const isMobile = useMediaQuery('(max-width: 768px)');
  const isTablet = useMediaQuery('(min-width: 769px) and (max-width: 1024px)');
  const isDesktop = useMediaQuery('(min-width: 1025px)');

  return (
    <div>
      {isMobile && <MobileNavigation />}
      {isTablet && <TabletNavigation />}
      {isDesktop && <FullNavigation />}
    </div>
  );
}
```

## Hook Composition

Combine custom hooks to build more complex behavior:

```tsx
export function useSearch(searchApi: string) {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);
  const { data, loading, error } = useAsync(
    () => fetch(`${searchApi}?q=${debouncedQuery}`).then(r => r.json()),
    [debouncedQuery]
  );

  return { query, setQuery, results: data, loading, error };
}
```

## References

- [Custom Hooks in React Docs](https://react.dev/learn/reusing-logic-with-custom-hooks)
- [React Hooks API Reference](https://react.dev/reference/react)
- [Collection of Custom Hooks](https://usehooks.com/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  6824,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000001f',
  'React with TypeScript Integration',
  'react-with-typescript-integration',
  'A comprehensive guide to integrating TypeScript with React, covering component typing, hooks, event handlers, generics, and patterns for type-safe React applications.',
  $$
## Introduction

TypeScript adds static type checking to React applications, catching bugs at compile time and providing better IDE support. When combined with React's component model, TypeScript enables strongly typed props, state, events, and refs, making code more predictable and maintainable.

## Typing Components

TypeScript interfaces should describe component props explicitly:

```tsx
import { ReactNode } from 'react';

interface CardProps {
  title: string;
  description?: string;
  children?: ReactNode;
  variant?: 'elevated' | 'outlined' | 'flat';
  onAction?: (id: string) => void;
}

export function Card({
  title,
  description,
  children,
  variant = 'elevated',
  onAction,
}: CardProps) {
  return (
    <article className={`card card--${variant}`}>
      <h2>{title}</h2>
      {description && <p className="card__desc">{description}</p>}
      {children && <div className="card__content">{children}</div>}
      {onAction && (
        <button onClick={() => onAction(title)}>Action</button>
      )}
    </article>
  );
}
```

## Generic Components

Create reusable components with type parameters:

```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => ReactNode;
  keyExtractor: (item: T) => string;
  emptyState?: ReactNode;
}

export function List<T>({
  items,
  renderItem,
  keyExtractor,
  emptyState,
}: ListProps<T>) {
  if (items.length === 0) {
    return emptyState ?? <p>No items to display</p>;
  }

  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>{renderItem(item, index)}</li>
      ))}
    </ul>
  );
}

// Usage with inferred types
interface Article {
  id: string;
  title: string;
}

function ArticleList({ articles }: { articles: Article[] }) {
  return (
    <List
      items={articles}
      keyExtractor={a => a.id}
      renderItem={article => <ArticleCard article={article} />}
      emptyState={<p>No articles published yet.</p>}
    />
  );
}
```

## Typing Hooks

TypeScript enhances hooks with proper type inference:

```tsx
import { useReducer } from 'react';

// Discriminated union for actions
type ArticleAction =
  | { type: 'SET_TITLE'; payload: string }
  | { type: 'SET_CONTENT'; payload: string }
  | { type: 'SET_TAGS'; payload: string[] }
  | { type: 'RESET' };

interface ArticleState {
  title: string;
  content: string;
  tags: string[];
  isDirty: boolean;
}

const initialState: ArticleState = {
  title: '',
  content: '',
  tags: [],
  isDirty: false,
};

function articleReducer(state: ArticleState, action: ArticleAction): ArticleState {
  switch (action.type) {
    case 'SET_TITLE':
      return { ...state, title: action.payload, isDirty: true };
    case 'SET_CONTENT':
      return { ...state, content: action.payload, isDirty: true };
    case 'SET_TAGS':
      return { ...state, tags: action.payload, isDirty: true };
    case 'RESET':
      return initialState;
    default:
      return state;
  }
}

export function useArticleForm(initial?: Partial<ArticleState>) {
  const [state, dispatch] = useReducer(articleReducer, {
    ...initialState,
    ...initial,
  });

  return {
    ...state,
    setTitle: (title: string) => dispatch({ type: 'SET_TITLE', payload: title }),
    setContent: (content: string) => dispatch({ type: 'SET_CONTENT', payload: content }),
    setTags: (tags: string[]) => dispatch({ type: 'SET_TAGS', payload: tags }),
    reset: () => dispatch({ type: 'RESET' }),
  };
}
```

## Event Handlers

TypeScript provides precise event types:

| Element | Event Type | Common Use |
|---|---|---|
| `<input>`, `<textarea>` | `ChangeEvent<HTMLInputElement>` | Form inputs |
| `<button>`, `<div>` | `MouseEvent<HTMLElement>` | Click handlers |
| `<form>` | `FormEvent<HTMLFormElement>` | Form submission |
| `<select>` | `ChangeEvent<HTMLSelectElement>` | Dropdowns |

```tsx
import { ChangeEvent, MouseEvent, FormEvent } from 'react';

export function EventHandlers() {
  const handleInput = (e: ChangeEvent<HTMLInputElement>) => {
    console.log(e.currentTarget.value);
  };

  const handleClick = (e: MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    console.log('Clicked at', e.clientX, e.clientY);
  };

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    console.log(Object.fromEntries(formData));
  };

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleInput} name="query" />
      <button type="submit" onClick={handleClick}>Submit</button>
    </form>
  );
}
```

## Type Safety Tips

| Pattern | Benefit |
|---|---|
| Use `satisfies` for complex object checks | Narrow types without assertions |
| Prefer `interface` over `type` for props | Better error messages |
| Use `as const` for literal union types | Preserve literal types |
| Avoid `any` — prefer `unknown` | Force type narrowing |

## References

- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [TypeScript React Docs](https://www.typescriptlang.org/docs/handbook/react-&-webpack.html)
- [React + TypeScript Guide](https://react.dev/learn/typescript)
  $$,
  '11111111-1111-1111-1111-111111111111',
  4,
  1,
  7895,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs

-- ============================================
-- TAG MAPPINGS
-- ============================================
-- TAG_MAPPINGS_START
-- [
--   {"articleGuid": "a0000001-0000-0000-0000-000000000018", "tagIds": [10, 12, 25]},
--   {"articleGuid": "a0000001-0000-0000-0000-000000000019", "tagIds": [11, 12, 13]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000001a", "tagIds": [12, 18]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000001b", "tagIds": [9, 12]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000001c", "tagIds": [12, 25]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000001d", "tagIds": [12, 13]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000001e", "tagIds": [10, 12]},
--   {"articleGuid": "a0000001-0000-0000-0000-00000000001f", "tagIds": [12, 13]}
-- ]
-- TAG_MAPPINGS_END




