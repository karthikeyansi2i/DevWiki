export interface User {
  userId: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: User;
}

export interface RegisterResponse {
  userId: string;
  email: string;
  firstName: string;
  lastName: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  errors?: ErrorDetail[];
  timestamp: string;
}

export interface ErrorDetail {
  code: string;
  message: string;
  field?: string;
}

export interface CodeSnippet {
  snippetId: string;
  articleId: string;
  title: string;
  description?: string;
  language: string;
  code: string;
  createdBy: string;
  createdByName: string;
  createdAt: string;
  updatedAt: string;
}

export interface CodeSnippetSearchResult {
  snippetId: string;
  title: string;
  description?: string;
  language: string;
  codePreview: string;
  articleId: string;
  articleTitle: string;
  articleSlug: string;
}

export interface CombinedSearchResult {
  articles: ArticleListItem[];
  codeSnippets: CodeSnippetSearchResult[];
  totalArticles: number;
  totalSnippets: number;
  query: string;
}

export interface ArticleListItem {
  articleId: string;
  title: string;
  slug: string;
  summary: string;
  authorName: string;
  categoryName: string;
  tags: Array<{ tagId: number; name: string }>;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface PaginatedResult<T> {
  items: T[];
  page: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

export interface Category {
  categoryId: number;
  name: string;
  slug: string;
  description?: string;
  articleCount: number;
}

export interface Tag {
  tagId: number;
  name: string;
  slug: string;
}

export interface ArticleDto {
  articleId: string;
  title: string;
  slug: string;
  summary: string;
  content: string;
  authorId: string;
  authorName: string;
  categoryId: number;
  categoryName: string;
  tags: Tag[];
  status: string;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}
