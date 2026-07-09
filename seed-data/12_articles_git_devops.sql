-- ============================================
-- 12_articles_git_devops.sql
-- 11 articles: TypeScript (Cat 5), Git (Cat 9), DevOps (Cat 10)
-- Articles 50-60
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000032',
  'TypeScript Generics Explained',
  'typescript-generics-explained',
  'A comprehensive guide to TypeScript generics — from basic syntax to advanced patterns like conditional types, mapped types, and generic constraints with practical real-world examples.',
  $$
## Introduction

Generics are one of TypeScript's most powerful features. They allow you to create reusable components that work with a variety of types while preserving type safety. Instead of using the `any` type which disables type checking, generics capture the type information and make it available throughout your code.

## The Problem Generics Solve

Without generics, you would write functions that either operate on a specific type or use `any`:

```typescript
function identity(value: any): any {
  return value;
}
```

The return type is `any`, so you lose all type information. With generics, the type is captured and preserved:

```typescript
function identity<T>(value: T): T {
  return value;
}

const result = identity(42); // type is number
const text = identity("hello"); // type is string
```

## Generic Constraints

Type constraints restrict which types can be used with a generic parameter:

```typescript
interface HasId {
  id: number;
}

function findById<T extends HasId>(items: T[], id: number): T | undefined {
  return items.find(item => item.id === id);
}

interface User extends HasId {
  name: string;
}

const users: User[] = [
  { id: 1, name: "Alice" },
  { id: 2, name: "Bob" }
];

const user = findById(users, 1); // type is User | undefined
```

## Multiple Type Parameters

Generics support multiple type parameters:

```typescript
function createPair<T, U>(first: T, second: U): [T, U] {
  return [first, second];
}

const pair = createPair("key", 100); // type is [string, number]
```

## Generic Interfaces

Interfaces can be parameterized to create reusable type definitions:

```typescript
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
  timestamp: string;
}

interface UserProfile {
  id: number;
  email: string;
  displayName: string;
}

async function fetchUser(id: number): Promise<ApiResponse<UserProfile>> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

## Generic Classes

Classes can use generics to work with multiple types:

```typescript
class Queue<T> {
  private items: T[] = [];

  enqueue(item: T): void {
    this.items.push(item);
  }

  dequeue(): T | undefined {
    return this.items.shift();
  }

  peek(): T | undefined {
    return this.items[0];
  }

  get length(): number {
    return this.items.length;
  }
}

const queue = new Queue<string>();
queue.enqueue("first");
queue.enqueue("second");
console.log(queue.dequeue()); // "first"
```

## Type Parameters in Generic Constraints

You can use type parameters in constraint expressions:

```typescript
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const article = { title: "Generics", views: 100, published: true };
const title = getProperty(article, "title"); // type is string
const views = getProperty(article, "views"); // type is number
```

## Conditional Types

Conditional types select one of two types based on a condition:

```typescript
type IsArray<T> = T extends any[] ? true : false;

type A = IsArray<string[]>; // true
type B = IsArray<number>; // false

type ElementType<T> = T extends (infer U)[] ? U : T;

type C = ElementType<string[]>; // string
type D = ElementType<number>; // number
```

## Mapped Types with Generics

Mapped types transform existing types into new ones:

```typescript
type Readonly<T> = {
  readonly [K in keyof T]: T[K];
};

type Optional<T> = {
  [K in keyof T]?: T[K];
};

type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

interface Config {
  url: string;
  timeout: number;
  retries: number;
}

type ReadonlyConfig = Readonly<Config>;
// { readonly url: string; readonly timeout: number; readonly retries: number; }
```

## Practical Example: Generic API Client

```typescript
class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async get<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }

  async post<TBody, TResponse>(endpoint: string, body: TBody): Promise<TResponse> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
    return response.json();
  }
}

interface CreateArticleRequest {
  title: string;
  content: string;
}

interface ArticleResponse {
  id: string;
  title: string;
  createdAt: string;
}

const client = new ApiClient("https://api.example.com");
const articles = await client.get<ArticleResponse[]>("/articles");
const created = await client.post<CreateArticleRequest, ArticleResponse>(
  "/articles",
  { title: "New Article", content: "Content here..." }
);
```

## Best Practices

| Practice | Reason |
|---|---|
| Use descriptive type parameter names | Improves readability for complex generics |
| Constrain type parameters with extends | Catches errors at compile time |
| Prefer generic functions over any | Preserves type safety |
| Use inference when possible | Reduces code verbosity |
| Document complex generic signatures | Helps team understanding |

## References

- [TypeScript Handbook: Generics](https://www.typescriptlang.org/docs/handbook/2/generics.html)
- [TypeScript Deep Dive: Generics](https://basarat.gitbook.io/typescript/type-system/generics)
- [Microsoft Learn: TypeScript Generics](https://docs.microsoft.com/en-us/training/modules/typescript-generics/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  5, 1, 4521,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000033',
  'Advanced TypeScript Types',
  'advanced-typescript-types',
  'Master advanced TypeScript type features including union and intersection types, discriminated unions, template literal types, conditional types, and type inference patterns.',
  $$
## Introduction

TypeScript's type system goes far beyond simple primitive types. Advanced type features allow you to model complex data shapes, enforce business rules at compile time, and build highly expressive APIs. This article explores the most powerful advanced type techniques.

## Union and Intersection Types

Union types represent values that can be one of several types. Intersection types combine multiple types into one:

```typescript
type Status = "draft" | "published" | "archived";

type Identifiable = { id: number };
type Timestamped = { createdAt: Date; updatedAt: Date };

type Entity = Identifiable & Timestamped;

const article: Entity = {
  id: 1,
  createdAt: new Date(),
  updatedAt: new Date()
};
```

## Discriminated Unions

Discriminated unions use a common property to distinguish between different shapes:

```typescript
type ApiEvent =
  | { type: "user_created"; payload: { userId: number; email: string } }
  | { type: "article_published"; payload: { articleId: number; slug: string } }
  | { type: "error"; payload: { code: number; message: string } };

function handleEvent(event: ApiEvent): void {
  switch (event.type) {
    case "user_created":
      console.log(`New user: ${event.payload.email}`);
      break;
    case "article_published":
      console.log(`Article: ${event.payload.slug}`);
      break;
    case "error":
      console.error(`Error ${event.payload.code}: ${event.payload.message}`);
      break;
  }
}
```

## Template Literal Types

Template literal types create string types from other types:

```typescript
type EventName = "created" | "updated" | "deleted";
type EntityType = "user" | "article" | "comment";

type EventKey = `${EntityType}_${EventName}`;
// "user_created" | "user_updated" | "user_deleted"
// | "article_created" | "article_updated" | "article_deleted"
// | "comment_created" | "comment_updated" | "comment_deleted"

function on(event: EventKey, handler: (data: unknown) => void): void {
  // Implementation
}

on("user_created", (data) => console.log(data));
// on("invalid_event", () => {}); // Type error
```

## Key remapping with Mapped Types

You can remap keys using the `as` clause:

```typescript
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number; }
```

## The infer Keyword

The `infer` keyword allows you to extract types from within conditional types:

```typescript
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

function fetchData(): Promise<string[]> {
  return Promise.resolve(["a", "b"]);
}

type FetchResult = ReturnType<typeof fetchData>; // Promise<string[]>

// Extract promise inner type
type Unwrap<T> = T extends Promise<infer U> ? U : T;
type Unwrapped = Unwrap<Promise<number>>; // number
```

## Branded Types

Branded types prevent accidental mixing of compatible values:

```typescript
type Brand<T, B> = T & { __brand: B };

type UserId = Brand<number, "UserId">;
type ArticleId = Brand<number, "ArticleId">;

function getUser(id: UserId): void { /* ... */ }
function getArticle(id: ArticleId): void { /* ... */ }

const userId = 1 as UserId;
const articleId = 2 as ArticleId;

getUser(userId); // OK
getArticle(articleId); // OK
// getUser(articleId); // Type error
// getArticle(userId); // Type error
```

## Satisfies Operator

The `satisfies` operator validates types without widening:

```typescript
const config = {
  url: "https://api.example.com",
  timeout: 5000,
  retry: true,
  headers: { "Content-Type": "application/json" }
} satisfies Record<string, unknown>;

// url is still typed as string literal, not widened to string
```

## Type Guards and Type Predicates

Custom type guards narrow types at runtime:

```typescript
interface Article {
  type: "article";
  title: string;
  body: string;
}

interface Comment {
  type: "comment";
  text: string;
  author: string;
}

type Content = Article | Comment;

function isArticle(content: Content): content is Article {
  return content.type === "article";
}

function renderContent(content: Content): string {
  if (isArticle(content)) {
    return `<article><h1>${content.title}</h1>${content.body}</article>`;
  }
  return `<blockquote>${content.text}</blockquote>`;
}
```

## Assertion Functions

Assertion functions narrow types by throwing on invalid states:

```typescript
function assertDefined<T>(value: T | null | undefined, message: string): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(message);
  }
}

function processArticle(title: string | null): void {
  assertDefined(title, "Title is required");
  console.log(title.toUpperCase()); // title is narrowed to string
}
```

## Type Performance Considerations

| Pattern | Performance Impact | Alternative |
|---|---|---|
| Deep recursive types | Slow compilation | Flatten where possible |
| Large union types | Increased check time | Use interfaces |
| Complex conditional types | Higher memory usage | Simplify with mapped types |
| Excessive tuple manipulation | Slower inference | Use arrays where appropriate |

## References

- [TypeScript Handbook: Advanced Types](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html)
- [TypeScript Deep Dive: Type System](https://basarat.gitbook.io/typescript/type-system)
- [TypeScript Weekly: Advanced Patterns](https://typescript-weekly.com/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  5, 1, 3210,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000034',
  'TypeScript with React Best Practices',
  'typescript-with-react-best-practices',
  'Best practices for using TypeScript with React — typing props and state, custom hooks, context patterns, event handlers, and advanced patterns for maintainable React applications.',
  $$
## Introduction

Combining TypeScript with React provides type safety for props, state, events, and hooks. This guide covers the essential patterns and conventions for building type-safe React applications that are easier to refactor and maintain.

## Typing Components

### Function Components

Type props and return values explicitly:

```typescript
interface ArticleCardProps {
  title: string;
  summary: string;
  readingTime: number;
  tags: string[];
  onBookmark?: (articleId: string) => void;
}

export function ArticleCard({
  title,
  summary,
  readingTime,
  tags,
  onBookmark
}: ArticleCardProps): JSX.Element {
  return (
    <div className="card">
      <h2>{title}</h2>
      <p>{summary}</p>
      <span>{readingTime} min read</span>
      {tags.map(tag => <span key={tag} className="tag">{tag}</span>)}
    </div>
  );
}
```

## Typing useState

Use type inference or explicit generics for complex state:

```typescript
interface UserProfile {
  id: string;
  name: string;
  email: string;
}

// Inference works for simple types
const [count, setCount] = useState(0);

// Explicit generic for complex or nullable state
const [user, setUser] = useState<UserProfile | null>(null);

// Union types for finite states
type FetchState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: string };

const [fetchState, setFetchState] = useState<FetchState<Article[]>>({
  status: "idle"
});
```

## Typing useReducer

Reducers benefit greatly from typed actions:

```typescript
type ArticleAction =
  | { type: "SET_TITLE"; payload: string }
  | { type: "SET_CONTENT"; payload: string }
  | { type: "SET_TAGS"; payload: string[] }
  | { type: "RESET" };

interface ArticleState {
  title: string;
  content: string;
  tags: string[];
  isDirty: boolean;
}

const initialState: ArticleState = {
  title: "",
  content: "",
  tags: [],
  isDirty: false
};

function articleReducer(state: ArticleState, action: ArticleAction): ArticleState {
  switch (action.type) {
    case "SET_TITLE":
      return { ...state, title: action.payload, isDirty: true };
    case "SET_CONTENT":
      return { ...state, content: action.payload, isDirty: true };
    case "SET_TAGS":
      return { ...state, tags: action.payload, isDirty: true };
    case "RESET":
      return initialState;
  }
}

export function ArticleEditor(): JSX.Element {
  const [state, dispatch] = useReducer(articleReducer, initialState);

  return (
    <form>
      <input
        value={state.title}
        onChange={e => dispatch({ type: "SET_TITLE", payload: e.target.value })}
      />
      <textarea
        value={state.content}
        onChange={e => dispatch({ type: "SET_CONTENT", payload: e.target.value })}
      />
    </form>
  );
}
```

## Typing Custom Hooks

Custom hooks with proper return types improve reusability:

```typescript
interface UseArticleOptions {
  id: string;
  autoFetch?: boolean;
}

interface UseArticleReturn {
  article: Article | null;
  isLoading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
}

function useArticle({ id, autoFetch = true }: UseArticleOptions): UseArticleReturn {
  const [article, setArticle] = useState<Article | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchArticle = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await api.get<Article>(`/articles/${id}`);
      setArticle(response);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to fetch");
    } finally {
      setIsLoading(false);
    }
  }, [id]);

  useEffect(() => {
    if (autoFetch) {
      fetchArticle();
    }
  }, [autoFetch, fetchArticle]);

  return { article, isLoading, error, refetch: fetchArticle };
}
```

## Typing Context

Create type-safe React context:

```typescript
interface AuthContextValue {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}

function AuthProvider({ children }: { children: ReactNode }): JSX.Element {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const login = useCallback(async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const response = await api.post<{ user: User }>("/auth/login", { email, password });
      setUser(response.user);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider
      value={{ user, isAuthenticated: user !== null, login, logout, isLoading }}
    >
      {children}
    </AuthContext.Provider>
  );
}
```

## Event Handlers

Type event handlers correctly:

```typescript
// Form submissions
function handleSubmit(e: FormEvent<HTMLFormElement>): void {
  e.preventDefault();
  // Process form
}

// Input changes
function handleInputChange(e: ChangeEvent<HTMLInputElement>): void {
  const { name, value } = e.target;
  setForm(prev => ({ ...prev, [name]: value }));
}

// Keyboard events
function handleKeyDown(e: KeyboardEvent<HTMLTextAreaElement>): void {
  if (e.key === "Enter" && e.ctrlKey) {
    submitForm();
  }
}
```

## forwardRef with Generics

Type forwardRef components with generics:

```typescript
interface InputProps {
  label: string;
  error?: string;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, ...props }, ref) => (
    <div>
      <label>{label}</label>
      <input ref={ref} {...props} />
      {error && <span className="error">{error}</span>}
    </div>
  )
);
```

## Common Patterns Reference

| Pattern | Type Signature | Use Case |
|---|---|---|
| Generic component | `<T extends unknown>` | Reusable list, table |
| Polymorphic component | `as` prop pattern | Flexible element rendering |
| Render props | `children: (value: T) => ReactNode` | Shared logic |
| Higher-order component | `(Component) => EnhancedComponent` | Cross-cutting concerns |

## References

- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [TypeScript Handbook: JSX](https://www.typescriptlang.org/docs/handbook/jsx.html)
- [React Official Docs: TypeScript](https://react.dev/learn/typescript)
  $$,
  '11111111-1111-1111-1111-111111111111',
  5, 1, 5678,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000035',
  'TypeScript Decorators Guide',
  'typescript-decorators-guide',
  'A thorough guide to TypeScript decorators — class, method, accessor, property, and parameter decorators with real-world use cases in logging, validation, authorization, and dependency injection.',
  $$
## Introduction

Decorators are a powerful feature in TypeScript that allow you to annotate and modify classes, methods, properties, and parameters at design time. They provide a declarative way to add cross-cutting concerns like logging, validation, and authorization to your code.

## Enabling Decorators

Decorators are an experimental feature in TypeScript. Enable them in your configuration:

```json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  }
}
```

## Class Decorators

Class decorators are applied to the constructor and can modify or replace the class:

```typescript
function sealed(constructor: Function): void {
  Object.seal(constructor);
  Object.seal(constructor.prototype);
}

function singleton<T extends { new (...args: any[]): {} }>(constructor: T): T {
  let instance: InstanceType<T>;

  return class extends constructor {
    constructor(...args: any[]) {
      super(...args);
      if (!instance) {
        instance = this as InstanceType<T>;
      }
      return instance;
    }
  } as T;
}

@sealed
@singleton
class DatabaseService {
  connect(): void {
    console.log("Connected to database");
  }
}
```

## Method Decorators

Method decorators can intercept, modify, or replace method behavior:

```typescript
function log(target: any, propertyKey: string, descriptor: PropertyDescriptor): PropertyDescriptor {
  const originalMethod = descriptor.value;

  descriptor.value = function (...args: any[]) {
    const start = Date.now();
    const result = originalMethod.apply(this, args);
    const duration = Date.now() - start;

    console.log(`[LOG] ${propertyKey} called with:`, args);
    console.log(`[LOG] ${propertyKey} returned:`, result);
    console.log(`[LOG] ${propertyKey} took ${duration}ms`);

    return result;
  };

  return descriptor;
}

function measure<T>(target: any, propertyKey: string, descriptor: TypedPropertyDescriptor<T>): void {
  const originalMethod = descriptor.value as unknown as (...args: any[]) => any;

  descriptor.value = function (...args: any[]) {
    const start = performance.now();
    const result = originalMethod.apply(this, args);
    const duration = performance.now() - start;

    console.log(`[PERF] ${propertyKey}: ${duration.toFixed(2)}ms`);
    return result;
  } as unknown as T;
}

class ArticleService {
  @log
  @measure
  getArticle(id: number): { id: number; title: string } {
    // Simulate database query
    for (let i = 0; i < 1000000; i++) {}
    return { id, title: "Sample Article" };
  }
}
```

## Accessor Decorators

Accessor decorators apply to getters and setters:

```typescript
function configurable(value: boolean) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor): void {
    descriptor.configurable = value;
  };
}

function enumerable(value: boolean) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor): void {
    descriptor.enumerable = value;
  };
}

class User {
  private _email: string = "";

  @enumerable(true)
  @configurable(false)
  get email(): string {
    return this._email;
  }

  set email(value: string) {
    if (!value.includes("@")) {
      throw new Error("Invalid email format");
    }
    this._email = value;
  }
}
```

## Property Decorators

Property decorators observe or modify property definitions:

```typescript
function required(target: any, propertyKey: string): void {
  const privateKey = `_${propertyKey}`;

  Object.defineProperty(target, propertyKey, {
    get() {
      return this[privateKey];
    },
    set(value: any) {
      if (value === null || value === undefined) {
        throw new Error(`${propertyKey} is required`);
      }
      this[privateKey] = value;
    },
    enumerable: true,
    configurable: true
  });
}

function format(formatFn: (value: any) => string) {
  return function (target: any, propertyKey: string): void {
    const privateKey = `_${propertyKey}`;

    Object.defineProperty(target, propertyKey, {
      get() {
        return formatFn(this[privateKey]);
      },
      set(value: any) {
        this[privateKey] = value;
      },
      enumerable: true,
      configurable: false
    });
  };
}

class Article {
  @required
  title: string = "";

  @required
  content: string = "";

  @format((date: Date) => date.toISOString().split("T")[0])
  publishedAt: Date = new Date();
}
```

## Parameter Decorators

Parameter decorators observe parameters on methods:

```typescript
import "reflect-metadata";

function validate(target: any, propertyKey: string, parameterIndex: number): void {
  const existingValidatedParams: number[] =
    Reflect.getOwnMetadata("validate:params", target, propertyKey) || [];
  existingValidatedParams.push(parameterIndex);
  Reflect.defineMetadata("validate:params", existingValidatedParams, target, propertyKey);
}

function required(target: any, propertyKey: string, parameterIndex: number): void {
  const existingRequiredParams: number[] =
    Reflect.getOwnMetadata("required:params", target, propertyKey) || [];
  existingRequiredParams.push(parameterIndex);
  Reflect.defineMetadata("required:params", existingRequiredParams, target, propertyKey);
}

class ArticleController {
  updateArticle(
    @validate @required id: number,
    @validate title: string,
    content: string
  ): void {
    console.log(`Updating article ${id}: ${title}`);
  }
}
```

## Real-World Use Cases

### Authorization Decorator

```typescript
function authorize(...roles: string[]) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor): void {
    const originalMethod = descriptor.value;

    descriptor.value = function (...args: any[]) {
      const user = getUserFromContext(this);
      if (!user || !roles.includes(user.role)) {
        throw new Error("Unauthorized");
      }
      return originalMethod.apply(this, args);
    };
  };
}

class AdminController {
  @authorize("admin")
  deleteUser(userId: number): void {
    console.log(`Deleting user ${userId}`);
  }

  @authorize("admin", "editor")
  updateArticle(articleId: number, data: unknown): void {
    console.log(`Updating article ${articleId}`);
  }
}
```

### Retry Decorator

```typescript
function retry(maxAttempts: number = 3, delayMs: number = 1000) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor): void {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      let lastError: Error | null = null;

      for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          return await originalMethod.apply(this, args);
        } catch (error) {
          lastError = error as Error;
          if (attempt < maxAttempts) {
            await new Promise(resolve => setTimeout(resolve, delayMs * attempt));
          }
        }
      }

      throw lastError;
    };
  };
}

class ExternalApiClient {
  @retry(3, 500)
  async fetchData(): Promise<unknown> {
    const response = await fetch("https://api.example.com/data");
    return response.json();
  }
}
```

## Decorator Composition

Multiple decorators apply in reverse order:

```typescript
@sealed
@singleton
class ApplicationService {
  @log
  @measure
  @retry(2)
  async processData(@validate data: string): Promise<void> {
    // Implementation
  }
}
```

## References

- [TypeScript Handbook: Decorators](https://www.typescriptlang.org/docs/handbook/decorators.html)
- [ECMAScript Decorators Proposal](https://github.com/tc39/proposal-decorators)
- [NestJS Decorators Documentation](https://docs.nestjs.com/custom-decorators)
  $$,
  '11111111-1111-1111-1111-111111111111',
  5, 1, 2100,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000036',
  'TypeScript Utility Types Deep Dive',
  'typescript-utility-types-deep-dive',
  'An in-depth exploration of TypeScript built-in utility types — Partial, Required, Pick, Omit, Record, Exclude, Extract, NonNullable, Parameters, ReturnType, and practical composition patterns.',
  $$
## Introduction

TypeScript ships with a rich set of built-in utility types that make common type transformations concise and readable. Understanding these utilities allows you to write more expressive and maintainable type definitions without reinventing the wheel.

## Partial and Required

`Partial<T>` makes all properties optional. `Required<T>` makes all properties required:

```typescript
interface ArticleConfig {
  title: string;
  content: string;
  category: string;
  tags: string[];
}

// All fields optional — useful for partial updates
function updateArticle(id: number, changes: Partial<ArticleConfig>): void {
  // Only update provided fields
  if (changes.title !== undefined) { /* update */ }
  if (changes.tags !== undefined) { /* update */ }
}

// All fields required — useful for form validation
type StrictForm = Required<ArticleConfig>;
```

## Readonly and ReadonlyArray

Prevent mutation of properties or arrays:

```typescript
type ImmutableArticle = Readonly<ArticleConfig>;
// { readonly title: string; readonly content: string; ... }

const frozenTags: ReadonlyArray<string> = ["typescript", "react"];
// frozenTags.push("new"); // Error: Property 'push' does not exist
```

## Pick and Omit

Select or exclude specific properties:

```typescript
interface Article {
  id: number;
  title: string;
  content: string;
  summary: string;
  createdAt: Date;
  updatedAt: Date;
  viewCount: number;
}

// Pick only the fields needed for a card preview
type ArticleCard = Pick<Article, "id" | "title" | "summary" | "createdAt">;

// Omit internal or large fields
type ArticleListItem = Omit<Article, "content">;

// Nested pick and omit
type ArticleUpdatePayload = Partial<Omit<Article, "id" | "createdAt" | "viewCount">>;
```

## Record

Create an object type with specific keys and value types:

```typescript
type ArticleStatus = "draft" | "published" | "archived";

// Map each status to its display config
const statusConfig: Record<ArticleStatus, { label: string; color: string }> = {
  draft: { label: "Draft", color: "gray" },
  published: { label: "Published", color: "green" },
  archived: { label: "Archived", color: "red" }
};

// Dynamic dictionary pattern
type TagMap = Record<string, { count: number; lastUsed: Date }>;
```

## Exclude and Extract

`Exclude<T, U>` removes types from a union. `Extract<T, U>` keeps only matching types:

```typescript
type AllEvents = "created" | "updated" | "deleted" | "archived" | "restored";

// Remove specific events
type LifecycleEvents = Exclude<AllEvents, "archived" | "restored">;
// "created" | "updated" | "deleted"

// Keep only specific events
type DestructiveEvents = Extract<AllEvents, "deleted">;
// "deleted"
```

## NonNullable

Remove null and undefined from a type:

```typescript
type NullableString = string | null | undefined;
type DefiniteString = NonNullable<NullableString>; // string

function processValue<T>(value: T): NonNullable<T> {
  if (value === null || value === undefined) {
    throw new Error("Value is null or undefined");
  }
  return value as NonNullable<T>;
}
```

## Parameters and ReturnType

Extract function parameter and return types:

```typescript
async function fetchArticles(
  categoryId: number,
  page: number,
  pageSize: number
): Promise<Article[]> {
  const response = await fetch(`/api/articles?category=${categoryId}&page=${page}&limit=${pageSize}`);
  return response.json();
}

type FetchArticlesParams = Parameters<typeof fetchArticles>;
// [number, number, number]

type FetchArticlesReturn = ReturnType<typeof fetchArticles>;
// Promise<Article[]>
```

## ConstructorParameters and InstanceType

Work with constructor signatures:

```typescript
class ArticleService {
  constructor(
    private apiBase: string,
    private timeout: number
  ) {}
}

type ArticleServiceParams = ConstructorParameters<typeof ArticleService>;
// [string, number]

type ArticleServiceInstance = InstanceType<typeof ArticleService>;
// ArticleService
```

## ThisParameterType and OmitThisParameter

Extract or remove `this` parameter from function types:

```typescript
function toString(this: { name: string }): string {
  return this.name;
}

type ThisParam = ThisParameterType<typeof toString>;
// { name: string }

type WithoutThis = OmitThisParameter<typeof toString>;
// () => string
```

## String Manipulation Types

TypeScript 4.1+ includes built-in string manipulation types:

```typescript
type EventName = "articleCreated";

type UppercaseEvent = Uppercase<EventName>;    // "ARTICLECREATED"
type LowercaseEvent = Lowercase<EventName>;     // "articlecreated"
type CapitalizeEvent = Capitalize<EventName>;   // "ArticleCreated"
type UncapitalizeEvent = Uncapitalize<EventName>; // "articleCreated"
```

## Practical Composition

Combine utility types for expressive type definitions:

```typescript
// Deep partial for nested updates
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};

// Non-function properties only
type NonFunctionKeys<T> = {
  [K in keyof T]: T[K] extends Function ? never : K
}[keyof T];

type NonFunctionProps<T> = Pick<T, NonFunctionKeys<T>>;

interface ComplexArticle {
  id: number;
  title: string;
  render(): void;
  serialize(): string;
}

type ArticleData = NonFunctionProps<ComplexArticle>;
// { id: number; title: string; }

// Async return type unwrapper
type AsyncReturnType<T extends (...args: any) => any> =
  T extends (...args: any) => Promise<infer R> ? R : ReturnType<T>;
```

## Utility Type Reference Table

| Utility Type | Description | Example Output |
|---|---|---|
| `Partial<T>` | All properties optional | `{ id?: number }` |
| `Required<T>` | All properties required | `{ id: number }` |
| `Readonly<T>` | All properties readonly | `{ readonly id: number }` |
| `Pick<T, K>` | Select specific keys | `Pick<Article, "id">` |
| `Omit<T, K>` | Exclude specific keys | `Omit<Article, "content">` |
| `Record<K, V>` | Key-value map | `Record<string, Article>` |
| `Exclude<T, U>` | Remove types from union | `Exclude<1 | 2, 1>` => `2` |
| `Extract<T, U>` | Keep matching types | `Extract<1 | 2, 1>` => `1` |
| `NonNullable<T>` | Remove null/undefined | `NonNullable<string \| null>` => `string` |
| `ReturnType<T>` | Function return type | `ReturnType<typeof fn>` |

## References

- [TypeScript Handbook: Utility Types](https://www.typescriptlang.org/docs/handbook/utility-types.html)
- [TypeScript Release Notes: 4.1 String Manipulation](https://devblogs.microsoft.com/typescript/announcing-typescript-4-1/)
- [TypeScript Deep Dive: Utility Types](https://basarat.gitbook.io/typescript/type-system/utility-types)
  $$,
  '11111111-1111-1111-1111-111111111111',
  5, 1, 3890,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000037',
  'Git Branching Strategies',
  'git-branching-strategies',
  'A comparison of popular Git branching strategies — Git Flow, GitHub Flow, GitLab Flow, and trunk-based development — with guidance on choosing the right approach for your team and project.',
  $$
## Introduction

A well-defined branching strategy is essential for team collaboration, release management, and code quality. Different strategies suit different project types, team sizes, and release cadences. This article examines the most popular Git branching models and their trade-offs.

## Git Flow

Git Flow is a comprehensive branching model with dedicated branches for features, releases, and hotfixes:

```
main ────────●──────────────●──────────────
             \            /
develop ──────●──●──●──●──●──●──●─────────
               \  /     \    /
feature/     ●─●──●     ●─●──●
                          \
release/                   ●──●──●
```

### Branches in Git Flow

| Branch | Purpose | Base Branch | Merges Into |
|---|---|---|---|
| `main` | Production-ready code | — | — |
| `develop` | Integration branch | `main` | `main` |
| `feature/*` | New features | `develop` | `develop` |
| `release/*` | Release preparation | `develop` | `main` + `develop` |
| `hotfix/*` | Urgent production fixes | `main` | `main` + `develop` |

### Git Flow Commands

```bash
# Start a new feature
git checkout -b feature/user-auth develop

# Work on the feature
git add .
git commit -m "Add user authentication module"

# Finish the feature
git checkout develop
git merge --no-ff feature/user-auth
git branch -d feature/user-auth

# Start a release
git checkout -b release/1.2.0 develop

# Tag the release
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git checkout develop
git merge --no-ff release/1.2.0
git branch -d release/1.2.0

# Hotfix
git checkout -b hotfix/1.2.1 main
git commit -m "Fix critical security vulnerability"
git checkout main
git merge --no-ff hotfix/1.2.1
git tag -a v1.2.1 -m "Hotfix 1.2.1"
git checkout develop
git merge --no-ff hotfix/1.2.1
```

## GitHub Flow

GitHub Flow is a simpler model with feature branches and pull requests:

```
main ──●──────●──────●──────●──────●────
         \    /      /      /
feature/  ●──●      ●─────/
                    /
fix/              ●──●──/
```

### GitHub Flow Principles

1. Anything in `main` is deployable
2. Create feature branches from `main`
3. Open a pull request early for feedback
4. Merge to `main` after review and CI passes
5. Deploy immediately after merge

```bash
# Create feature branch
git checkout -b add-markdown-preview main

# Make changes and commit
git add .
git commit -m "Add markdown preview component"

# Push and create PR
git push -u origin add-markdown-preview

# After PR approval and CI, merge (via GitHub UI or CLI)
gh pr merge --squash

# Delete remote branch
git push origin --delete add-markdown-preview

# Update local main
git checkout main
git pull --rebase
```

## GitLab Flow

GitLab Flow adds environment branches for staging and production:

```
main ───────●─────────────────●──────────
              \               /
staging        ●──●──●───────●───────────
                             /
production                  ●────────────
```

### Environment Branches

```bash
# Deploy to staging
git checkout staging
git merge main

# Deploy to production
git checkout production
git merge staging

# Create an environment branch for a specific release
git checkout -b release/2.0 staging
```

## Trunk-Based Development

Trunk-based development emphasizes short-lived branches and frequent integration:

```
main ──●──●──●──●──●──●──●──●──●──●──●──
         |     |   |     |
         ●     ●   ●     ●   (short-lived feature branches)
```

### Key Practices

- Branches live less than one day
- Small, frequent commits
- Feature flags for incomplete work
- Continuous integration on every push

```bash
# Start small feature
git checkout -b fix-header-alignment main

# Quick fix
git add .
git commit -m "Fix header alignment on mobile"

# Merge immediately
git checkout main
git merge --squash fix-header-alignment
git branch -d fix-header-alignment
```

## Comparison Table

| Aspect | Git Flow | GitHub Flow | GitLab Flow | Trunk-Based |
|---|---|---|---|---|
| Complexity | High | Low | Medium | Very Low |
| Release cadence | Scheduled | Continuous | Flexible | Continuous |
| Hotfix handling | Dedicated branch | Feature branch | Cherry-pick | Feature toggle |
| Learning curve | Steep | Gentle | Moderate | Minimal |
| Best for | Large releases | Web apps | Complex deployments | Microservices |
| CI/CD integration | Moderate | Excellent | Excellent | Excellent |

## Choosing the Right Strategy

Consider these factors when selecting a branching model:

- **Team size**: Larger teams benefit from Git Flow's structure
- **Release frequency**: Frequent releases favor GitHub Flow or trunk-based
- **Deployment complexity**: Multiple environments suit GitLab Flow
- **Hotfix requirements**: Git Flow provides clean hotfix isolation
- **CI/CD maturity**: Automated pipelines make simpler models safe

## References

- [Git Flow: A Successful Git Branching Model](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow Documentation](https://docs.github.com/en/get-started/quickstart/github-flow)
- [GitLab Flow Documentation](https://docs.gitlab.com/ee/topics/gitlab_flow.html)
- [Trunk-Based Development](https://trunkbaseddevelopment.com/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  9, 1, 7345,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000038',
  'Git Rebase vs Merge',
  'git-rebase-vs-merge',
  'Understand the differences between Git rebase and merge — when to use each, how interactive rebasing works, resolving conflicts, and maintaining a clean commit history in collaborative projects.',
  $$
## Introduction

Git provides two primary ways to integrate changes from one branch into another: merge and rebase. While both achieve the same end result, they produce very different histories. Choosing the right approach depends on your team's workflow and the story you want your commit history to tell.

## How Merge Works

Merge creates a new commit that combines the histories of two branches:

```bash
# Create a feature branch
git checkout -b feature/search main

# Work on the feature
git add .
git commit -m "Add search index"
git add .
git commit -m "Add search UI"

# Switch back to main and merge
git checkout main
git pull origin main
git merge feature/search
```

### Merge Commit Graph

```
main:      A──B──C──────────F
                 \          /
feature:          D──E─────
```

The merge commit F has two parents (C and E), creating a non-linear history. The `--no-ff` flag ensures a merge commit even when a fast-forward is possible:

```bash
git merge --no-ff feature/search
```

## How Rebase Works

Rebase replays commits from one branch onto the tip of another:

```bash
git checkout feature/search
git rebase main
```

### Rebase Commit Graph

```
Before:
main:     A──B──C
                \
feature:         D──E

After rebase:
main:     A──B──C
                \
feature:         D'──E'
```

Rebase creates new commits (D', E') with new hashes, making the history appear linear. The feature branch appears to have been developed from the latest commit on main.

## Interactive Rebase

Interactive rebase lets you edit, reorder, squash, or drop commits:

```bash
git rebase -i HEAD~5
```

This opens an editor with instructions:

```
pick a1b2c3d Add search index
pick e4f5g6h Add search UI
pick i7j8k9l Fix search pagination
pick m0n1o2p Add search tests
pick q3r4s5t Tweak search styling

# Commands:
# p, pick   = use commit
# r, reword = use commit but edit message
# s, squash = combine with previous commit
# f, fixup  = combine but discard message
# d, drop   = remove commit
```

### Squashing Commits

Combine related commits for a cleaner history:

```bash
git rebase -i HEAD~3
```

Change `pick` to `squash` for commits you want to combine:

```
pick a1b2c3d Add search index
squash e4f5g6h Add search UI
squash i7j8k9l Fix search pagination
```

This produces a single commit with a combined message.

## Conflict Resolution

### Merge Conflicts

During merge, conflicts are resolved in the merge commit:

```bash
# Attempt merge
git merge feature/search
# Conflict in src/search.ts

# Resolve conflicts manually, then
git add src/search.ts
git commit -m "Merge feature/search into main"
```

### Rebase Conflicts

During rebase, conflicts occur per-commit:

```bash
git rebase main
# Conflict on first replayed commit

# Resolve conflicts
git add src/search.ts

# Continue rebase
git rebase --continue

# Or skip this commit
git rebase --skip

# Or abort entirely
git rebase --abort
```

## When to Use Merge vs Rebase

| Scenario | Merge | Rebase |
|---|---|---|
| Public/shared branches | ✅ | ❌ |
| Private feature branches | ✅ | ✅ |
| Pull request integration | ✅ | Depends on team |
| Clean linear history | ❌ | ✅ |
| Preserving exact commit context | ✅ | ❌ |
| Onboarding new team members | ✅ | ❌ (harder to trace) |

## Golden Rule of Rebase

**Never rebase commits that have been pushed to a shared branch.**

If you rebase a public branch, other developers' local histories diverge from the remote. The result is confusing duplicate commits and forced pushes that disrupt the team.

```bash
# ❌ Dangerous on shared branches
git checkout main
git rebase origin/main
git push --force-with-lease  # Still risky on shared branches

# ✅ Safe — only for private branches
git checkout feature/my-work
git rebase main
git push --force-with-lease
```

## Practical Workflow

A balanced approach combines both strategies:

```bash
# 1. Start feature from main
git checkout -b feature/new-dashboard main

# 2. Work with regular commits
git add .
git commit -m "Add dashboard layout"
git add .
git commit -m "Add charts component"

# 3. Keep feature up to date with main
git fetch origin
git rebase origin/main

# 4. Before PR, squash into clean commits
git rebase -i origin/main

# 5. Merge feature with merge commit (or squash merge via PR)
git checkout main
git merge --no-ff feature/new-dashboard
```

## Key Takeaways

| Aspect | Merge | Rebase |
|---|---|---|
| History | Non-linear, preserves context | Linear, cleaner |
| Commit hashes | Preserved | Recreated |
| Conflict handling | Once at merge | Once per commit |
| Safety | Safe for all branches | Safe only for private branches |
| Traceability | Easy to see where branches diverged | Harder to trace original branch point |

## References

- [Git Documentation: git-merge](https://git-scm.com/docs/git-merge)
- [Git Documentation: git-rebase](https://git-scm.com/docs/git-rebase)
- [Atlassian: Merging vs. Rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)
- [Pro Git Book: Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)
  $$,
  '11111111-1111-1111-1111-111111111111',
  9, 1, 8921,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000039',
  'Advanced Git Commands',
  'advanced-git-commands',
  'Go beyond basic Git with advanced commands for history rewriting, debugging, bisecting, stashing, worktrees, submodules, and hooks — practical techniques for power users.',
  $$
## Introduction

Beyond the basic add, commit, push, and pull commands, Git offers a wealth of advanced features that can dramatically improve your productivity. This article covers powerful commands every experienced developer should know.

## Git Bisect

Binary search through commit history to find the commit that introduced a bug:

```bash
# Start bisect session
git bisect start

# Mark current commit as bad
git bisect bad

# Mark a known good commit
git bisect good v1.0.0

# Git checks out a midpoint commit
# Test the current state, then mark:
git bisect good  # If bug is not present
git bisect bad   # If bug is present

# Git continues narrowing down until it finds the first bad commit
# Output: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t is the first bad commit

# End bisect session
git bisect reset
```

### Automated Bisect

Run a script automatically during bisect:

```bash
git bisect start HEAD v1.0.0
git bisect run npm test
```

## Git Reflog

The reflog records every change to HEAD, including lost commits:

```bash
# View reflog
git reflog

# Output:
# a1b2c3d HEAD@{0}: commit: Fix critical bug
# e4f5g6h HEAD@{1}: rebase finished: return to refs/heads/main
# i7j8k9l HEAD@{2}: rebase: Add search feature
# m0n1o2p HEAD@{3}: reset: moving to HEAD~2

# Recover a lost commit after a hard reset
git reset --hard HEAD@{2}

# Or recover by hash
git cherry-pick a1b2c3d
```

## Git Stash Advanced Usage

Save and manage work-in-progress changes:

```bash
# Stash with a descriptive message
git stash push -m "WIP: refactoring auth module"

# Stash only specific files
git stash push -- src/auth.ts src/types.ts

# Stash including untracked files
git stash push --include-untracked

# List all stashes
git stash list

# Show stash contents without applying
git stash show -p stash@{1}

# Apply stash without dropping
git stash apply stash@{2}

# Apply and drop
git stash pop stash@{0}

# Create a branch from a stash
git stash branch fix-auth-bug stash@{0}
```

## Git Worktree

Work on multiple branches simultaneously in separate directories:

```bash
# Create a new worktree for a feature branch
git worktree add ../project-feature feature/new-dashboard

# Create a worktree for a specific commit
git worktree add ../project-hotfix a1b2c3d

# List all worktrees
git worktree list

# Remove a worktree
git worktree remove ../project-feature

# Clean up stale worktree references
git worktree prune
```

## Git Submodules

Include external repositories within your project:

```bash
# Add a submodule
git submodule add https://github.com/example/shared-lib.git src/shared

# Initialize submodules after cloning
git clone --recurse-submodules https://github.com/org/main-project.git
# Or after a regular clone
git submodule update --init --recursive

# Update submodules to latest commits
git submodule update --remote

# Commit submodule update in parent repository
git add src/shared
git commit -m "Update shared-lib to latest version"

# Show submodule status
git submodule status
```

## Git Hooks

Automate actions at key points in the Git lifecycle:

```bash
# Create a pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Run linter before committing
npm run lint
if [ $? -ne 0 ]; then
  echo "Linting failed. Commit aborted."
  exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

### Common Hook Types

| Hook | Trigger | Use Case |
|---|---|---|
| `pre-commit` | Before commit | Linting, formatting, secret scanning |
| `prepare-commit-msg` | Before commit message editor | Auto-populate message templates |
| `commit-msg` | After message is entered | Validate commit message format |
| `pre-push` | Before push | Run tests, check branch naming |
| `post-merge` | After merge | Install dependencies, run migrations |
| `post-checkout` | After checkout | Restore environment state |

## Git Grep and Log Search

Search code and history efficiently:

```bash
# Search working directory
git grep "TODO" -- src/

# Search with regex
git grep -n "function.*Handler" -- "*.cs"

# Search commit messages
git log --grep="fix security" --oneline

# Search changes in commits
git log -S "deprecatedMethod" --oneline

# Search by author
git log --author="Jane" --since="2026-01-01"

# Show commit history for a specific function
git log -L '/def handleRequest/,/^}/:src/handler.ts'
```

## Git Clean and Reset

Clean your working directory:

```bash
# Dry run — show what would be removed
git clean -n

# Remove untracked files
git clean -f

# Remove untracked files and directories
git clean -fd

# Interactive cleaning
git clean -i

# Reset with different modes
git reset --soft HEAD~1   # Keep changes staged
git reset --mixed HEAD~1  # Keep changes unstaged (default)
git reset --hard HEAD~1   # Discard changes entirely
```

## Git Cherry-Pick

Apply specific commits from one branch to another:

```bash
# Cherry-pick a single commit
git cherry-pick a1b2c3d

# Cherry-pick a range of commits
git cherry-pick a1b2c3d..e5f6g7h

# Cherry-pick without committing (to make changes)
git cherry-pick -n a1b2c3d
```

## Configuration Tips

```bash
# Set up aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all --decorate"

# Auto-correct mistyped commands
git config --global help.autocorrect 20

# Use rebase as default for pull
git config --global pull.rebase true
```

## References

- [Git Documentation: Reference](https://git-scm.com/docs)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Atlassian: Advanced Git Tutorials](https://www.atlassian.com/git/tutorials/advanced-git)
  $$,
  '11111111-1111-1111-1111-111111111111',
  9, 1, 4231,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000003a',
  'Docker Multi-Stage Builds',
  'docker-multi-stage-builds',
  'Learn how to optimize Docker images using multi-stage builds — separating build and runtime environments, reducing image size, caching strategies, and best practices for .NET applications.',
  $$
## Introduction

Multi-stage builds are a Docker feature that lets you use multiple FROM statements in a single Dockerfile. Each stage can use a different base image, and you selectively copy artifacts from one stage to another. This technique dramatically reduces final image size by separating build dependencies from the runtime environment.

## Why Image Size Matters

Smaller images provide significant benefits:

| Benefit | Impact |
|---|---|
| Faster deployments | Less data to transfer |
| Reduced storage costs | Smaller registry footprint |
| Quicker cold starts | Less data to extract |
| Smaller attack surface | Fewer packages = fewer vulnerabilities |
| Faster CI/CD pipelines | Less time to build and push |

## Basic Multi-Stage Structure

```dockerfile
# === Stage 1: Build ===
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files and restore
COPY ["DevWiki.API/DevWiki.API.csproj", "DevWiki.API/"]
COPY ["DevWiki.Application/DevWiki.Application.csproj", "DevWiki.Application/"]
COPY ["DevWiki.Domain/DevWiki.Domain.csproj", "DevWiki.Domain/"]
COPY ["DevWiki.Infrastructure/DevWiki.Infrastructure.csproj", "DevWiki.Infrastructure/"]
RUN dotnet restore "DevWiki.API/DevWiki.API.csproj"

# Copy all source and publish
COPY . .
RUN dotnet publish "DevWiki.API/DevWiki.API.csproj" \
    -c Release \
    -o /app/publish \
    --no-restore

# === Stage 2: Runtime ===
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copy only published output from build stage
COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "DevWiki.API.dll"]
```

## Layer Caching Optimization

Layer ordering is critical for efficient Docker caching:

```dockerfile
# Optimized for caching — least-changing layers first
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 1. Restore layer — only invalidated when project files change
COPY ["src/API/*.csproj", "src/API/"]
COPY ["src/Application/*.csproj", "src/Application/"]
COPY ["src/Domain/*.csproj", "src/Domain/"]
COPY ["src/Infrastructure/*.csproj", "src/Infrastructure/"]
RUN dotnet restore "src/API/API.csproj"

# 2. Copy and build — invalidated on any source change
COPY src/ .
RUN dotnet publish "src/API/API.csproj" -c Release -o /app/publish --no-restore
```

## Multi-Project Solution Build

For solutions with multiple projects:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy all project files
COPY *.sln .
COPY src/*/*.csproj ./
RUN for file in $(ls *.csproj); do \
      mkdir -p "src/$(basename $file .csproj)" && \
      mv "$file" "src/$(basename $file .csproj)/"; \
    done

RUN dotnet restore

COPY src/ ./src/
RUN dotnet publish "src/API/API.csproj" -c Release -o /app/publish
```

## Frontend and Backend Combined

Build a React frontend and .NET backend in one Dockerfile:

```dockerfile
# === Stage 1: Build Frontend ===
FROM node:20-alpine AS frontend-build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# === Stage 2: Build Backend ===
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS backend-build
WORKDIR /src
COPY ["backend/API/API.csproj", "API/"]
COPY ["backend/Application/Application.csproj", "Application/"]
COPY ["backend/Domain/Domain.csproj", "Domain/"]
COPY ["backend/Infrastructure/Infrastructure.csproj", "Infrastructure/"]
RUN dotnet restore "API/API.csproj"
COPY backend/ .
RUN dotnet publish "API/API.csproj" -c Release -o /app/publish

# === Stage 3: Runtime ===
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copy backend build
COPY --from=backend-build /app/publish .

# Copy frontend static files
COPY --from=frontend-build /app/dist ./wwwroot

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "API.dll"]
```

## Using Build Arguments

Parameterize your builds with ARG:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
ARG VERSION=1.0.0

WORKDIR /src
COPY . .
RUN dotnet publish "src/API/API.csproj" \
    -c $BUILD_CONFIGURATION \
    -o /app/publish \
    -p:Version=$VERSION

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "API.dll"]
```

Build with custom arguments:

```bash
docker build \
  --build-arg BUILD_CONFIGURATION=Debug \
  --build-arg VERSION=2.0.0-beta \
  -t myapp:beta .
```

## Image Size Comparison

| Approach | Base Image | Final Size | Savings |
|---|---|---|---|
| Single stage (SDK) | `dotnet/sdk:9.0` | ~1.8 GB | Baseline |
| Single stage (ASP.NET) | `dotnet/aspnet:9.0` | ~800 MB | 56% |
| Multi-stage (optimized) | `dotnet/aspnet:9.0` | ~210 MB | 88% |
| Multi-stage + Alpine | `dotnet/aspnet:9.0-alpine` | ~110 MB | 94% |

## Security Best Practices

```dockerfile
# Use non-root user
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Create and switch to non-root user
RUN adduser --disabled-password --gecos "" appuser
USER appuser

COPY --chown=appuser --from=build /app/publish .

# Don't run as root
ENTRYPOINT ["dotnet", "API.dll"]
```

## Docker Compose Integration

```yaml
version: "3.8"
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        BUILD_CONFIGURATION: Release
    ports:
      - "8080:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Host=db;Database=devwiki;Username=postgres;Password=${DB_PASSWORD}
```

## References

- [Docker Docs: Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Microsoft: Docker for .NET](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/docker-application-development-process/)
- [Docker Best Practices Guide](https://docs.docker.com/develop/dev-best-practices/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  10, 1, 6543,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000003b',
  'CI/CD with GitHub Actions',
  'cicd-with-github-actions',
  'A complete guide to implementing CI/CD pipelines with GitHub Actions — workflow syntax, build and test jobs, multi-environment deployment, caching strategies, and security best practices.',
  $$
## Introduction

GitHub Actions provides a powerful CI/CD platform integrated directly into GitHub repositories. You can build, test, and deploy your applications using workflows defined in YAML files. This guide covers everything from basic workflow setup to advanced multi-environment deployment pipelines.

## Workflow Basics

Workflows are defined in `.github/workflows/` as YAML files:

```yaml
name: Build and Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "9.0"

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore -c Release

      - name: Test
        run: dotnet test --no-build -c Release --logger trx
```

## Complete .NET CI Pipeline

A comprehensive pipeline for a .NET application:

```yaml
name: .NET CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  DOTNET_VERSION: "9.0"
  NODE_VERSION: "20"

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}
      - name: Run dotnet format
        run: dotnet format --verify-no-changes

  test:
    needs: lint
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: devwiki_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}

      - name: Cache NuGet packages
        uses: actions/cache@v4
        with:
          path: ~/.nuget/packages
          key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
          restore-keys: |
            ${{ runner.os }}-nuget-

      - name: Restore and build
        run: |
          dotnet restore
          dotnet build -c Release --no-restore

      - name: Run tests
        run: dotnet test -c Release --no-build --logger "trx"
        env:
          ConnectionStrings__DefaultConnection: Host=localhost;Database=devwiki_test;Username=postgres;Password=postgres

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: "**/*.trx"
```

## Multi-Environment Deployment

Deploy to staging and production environments:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: myorg/devwiki
          tags: |
            type=semver,pattern={{version}}
            type=sha,prefix=

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}

  deploy-staging:
    needs: build-and-push
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com

    steps:
      - name: Deploy to staging
        run: |
          curl -X POST ${{ secrets.STAGING_DEPLOY_HOOK }} \
            -H "Authorization: Bearer ${{ secrets.STAGING_DEPLOY_TOKEN }}" \
            -d '{"image": "${{ needs.build-and-push.outputs.image-tag }}"}'

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com

    steps:
      - name: Deploy to production
        run: |
          curl -X POST ${{ secrets.PROD_DEPLOY_HOOK }} \
            -H "Authorization: Bearer ${{ secrets.PROD_DEPLOY_TOKEN }}" \
            -d '{"image": "${{ needs.build-and-push.outputs.image-tag }}"}'
```

## Matrix Builds

Test across multiple configurations:

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        dotnet-version: ["8.0", "9.0"]
        include:
          - os: ubuntu-latest
            dotnet-version: "9.0"
            coverage: true

    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET ${{ matrix.dotnet-version }}
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ matrix.dotnet-version }}
      - run: dotnet test -c Release

      - name: Upload coverage
        if: matrix.coverage
        uses: codecov/codecov-action@v4
```

## Caching Dependencies

Speed up workflows with caching:

```yaml
- name: Cache NuGet packages
  uses: actions/cache@v4
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
    restore-keys: |
      ${{ runner.os }}-nuget-

- name: Cache npm packages
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('frontend/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-

- name: Cache Docker layers
  uses: actions/cache@v4
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

## Security Best Practices

| Practice | Implementation |
|---|---|
| Use secrets for sensitive data | `${{ secrets.API_KEY }}` instead of hardcoding |
| Pin action versions | `actions/checkout@v4` not `@main` |
| Least privilege tokens | Use `permissions:` block to restrict GITHUB_TOKEN |
| OIDC for cloud auth | Use `aws-actions/configure-aws-credentials` with OIDC |
| Scan dependencies | Add `anchore/scan-action` or similar |

## Workflow Status Badges

Add badges to your README:

```markdown
![Build](https://github.com/myorg/devwiki/actions/workflows/ci.yml/badge.svg)
![Test Coverage](https://codecov.io/gh/myorg/devwiki/branch/main/graph/badge.svg)
```

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
  $$,
  '11111111-1111-1111-1111-111111111111',
  10, 1, 9876,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000003c',
  'Infrastructure as Code with Terraform',
  'infrastructure-as-code-with-terraform',
  'A practical introduction to Infrastructure as Code with Terraform — HCL syntax, state management, resource provisioning, modules, workspaces, and integrating with CI/CD pipelines for cloud deployments.',
  $$
## Introduction

Infrastructure as Code (IaC) is the practice of managing infrastructure through machine-readable definition files rather than manual processes. Terraform by HashiCorp is the leading IaC tool, enabling you to provision and manage cloud resources across providers with declarative configuration files.

## Core Concepts

| Concept | Description |
|---|---|
| Provider | Plugin for interacting with cloud APIs (AWS, Azure, GCP) |
| Resource | Infrastructure component (VM, database, network) |
| State | Mapping of configuration to real-world resources |
| Module | Reusable collection of resources |
| Workspace | Isolated state for different environments |

## HCL Syntax Basics

Terraform uses HashiCorp Configuration Language (HCL):

```hcl
# Configure the provider
provider "aws" {
  region = "us-west-2"
}

# Define a resource
resource "aws_s3_bucket" "storage" {
  bucket = "devwiki-artifacts-${var.environment}"
  tags = {
    Name        = "DevWiki Artifacts"
    Environment = var.environment
  }
}

# Input variable
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

# Output value
output "bucket_arn" {
  value       = aws_s3_bucket.storage.arn
  description = "ARN of the S3 bucket"
}
```

## Complete Azure Infrastructure

Provision a full application stack on Azure:

```hcl
# providers.tf
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# main.tf
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-devwiki-${var.environment}-${random_string.suffix.result}"
  location = var.location
  tags = {
    Environment = var.environment
    Project     = "DevWiki"
  }
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "psql-devwiki-${var.environment}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "16"
  administrator_login    = "devwiki_admin"
  administrator_password = random_password.db_password.result
  zone                   = "1"

  storage_mb   = 32768
  sku_name     = "B_Standard_B1ms"
  depends_on = [azurerm_resource_group.main]
}

resource "random_password" "db_password" {
  length  = 24
  special = true
  upper   = true
  lower   = true
}

resource "azurerm_container_app_environment" "app" {
  name                = "cae-devwiki-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_container_app" "api" {
  name                         = "ca-devwiki-api-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.app.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "api"
      image  = "myregistry.azurecr.io/devwiki-api:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment == "production" ? "Production" : "Staging"
      }
      env {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Host=${azurerm_postgresql_flexible_server.db.fqdn};Database=devwiki;Username=devwiki_admin;Password=${random_password.db_password.result}"
      }
    }
  }

  ingress {
    target_port = 8080
    external_enabled = true
  }
}

# variables.tf
variable "environment" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "subscription_id" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

# outputs.tf
output "api_url" {
  value = "https://${azurerm_container_app.api.latest_revision_fqdn}"
}

output "database_host" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}
```

## Terraform Workspaces

Manage multiple environments with workspaces:

```bash
# Create workspaces for each environment
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select staging

# Apply with workspace-specific variables
terraform apply -var-file="environments/$(terraform workspace show).tfvars"
```

## Terraform Modules

Create reusable modules for common infrastructure patterns:

```hcl
# modules/postgresql/main.tf
resource "azurerm_postgresql_flexible_server" "server" {
  name                = "${var.name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name   = var.sku
  storage_mb = var.storage_mb
  version    = var.postgres_version
}

variable "name" { type = string }
variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sku" { type = string }
variable "storage_mb" { type = number }
variable "postgres_version" { type = string }

output "fqdn" { value = azurerm_postgresql_flexible_server.server.fqdn }
output "id"   { value = azurerm_postgresql_flexible_server.server.id }
```

```hcl
# environments/production/main.tf — using the module
module "database" {
  source = "../../modules/postgresql"

  name                = "devwiki"
  environment         = "production"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus"
  sku                 = "GP_Standard_D2ds_v4"
  storage_mb          = 131072
  postgres_version    = "16"
}

output "db_fqdn" {
  value = module.database.fqdn
}
```

## State Management

Store state remotely for team collaboration:

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstatedevwiki"
    container_name       = "devwiki-tfstate"
    key                  = "devwiki.terraform.tfstate"
  }
}
```

## CI/CD with Terraform

Automate Terraform in your pipeline:

```yaml
name: Infrastructure Deploy

on:
  push:
    branches: [main]
    paths:
      - "terraform/**"

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.5.0"

      - name: Terraform Init
        working-directory: terraform
        run: terraform init
        env:
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

      - name: Terraform Plan
        working-directory: terraform
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        working-directory: terraform
        run: terraform apply tfplan
```

## Best Practices

| Practice | Rationale |
|---|---|
| Use remote state | Prevents state loss and enables team collaboration |
| Tag all resources | Simplifies cost tracking and resource management |
| Validate with terraform validate | Catches syntax errors early |
| Use variables.tfvars files | Separates config from code |
| Pin provider versions | Avoids unexpected breaking changes |
| Use modules for reuse | Reduces duplication across environments |

## References

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [HashiCorp Learn: Terraform](https://developer.hashicorp.com/terraform/tutorials)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
  $$,
  '11111111-1111-1111-1111-111111111111',
  10, 1, 5432,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs




