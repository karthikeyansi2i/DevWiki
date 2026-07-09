import axios, { type AxiosInstance } from 'axios';
import type { ApiResponse, LoginResponse, RegisterResponse, CodeSnippet, CodeSnippetSearchResult, CombinedSearchResult, PaginatedResult, Category, Tag, ArticleDto } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:7000/api';

const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  register: async (
    email: string,
    password: string,
    firstName: string,
    lastName: string
  ): Promise<ApiResponse<RegisterResponse>> => {
    const response = await api.post('/auth/register', {
      email,
      password,
      firstName,
      lastName,
    });
    return response.data;
  },

  login: async (email: string, password: string): Promise<ApiResponse<LoginResponse>> => {
    const response = await api.post('/auth/login', { email, password });
    return response.data;
  },

  refresh: async (refreshToken: string): Promise<ApiResponse<{ accessToken: string; expiresIn: number }>> => {
    const response = await api.post('/auth/refresh', { refreshToken });
    return response.data;
  },
};

export const snippetsAPI = {
  getArticleSnippets: async (articleId: string): Promise<ApiResponse<CodeSnippet[]>> => {
    const response = await api.get(`/articles/${articleId}/snippets`);
    return response.data;
  },

  getById: async (id: string): Promise<ApiResponse<CodeSnippet>> => {
    const response = await api.get(`/snippets/${id}`);
    return response.data;
  },

  create: async (articleId: string, data: { title: string; description?: string; language: string; code: string }): Promise<ApiResponse<CodeSnippet>> => {
    const response = await api.post(`/articles/${articleId}/snippets`, data);
    return response.data;
  },

  update: async (id: string, data: { title: string; description?: string; language: string; code: string }): Promise<ApiResponse<CodeSnippet>> => {
    const response = await api.put(`/snippets/${id}`, data);
    return response.data;
  },

  delete: async (id: string): Promise<ApiResponse<object>> => {
    const response = await api.delete(`/snippets/${id}`);
    return response.data;
  },

  search: async (q: string, page = 1, pageSize = 20): Promise<ApiResponse<PaginatedResult<CodeSnippetSearchResult>>> => {
    const response = await api.get('/snippets/search', { params: { q, page, pageSize } });
    return response.data;
  },

  getByLanguage: async (language: string, page = 1, pageSize = 20): Promise<ApiResponse<PaginatedResult<CodeSnippetSearchResult>>> => {
    const response = await api.get('/snippets', { params: { language, page, pageSize } });
    return response.data;
  },

  searchAll: async (q: string, page = 1, pageSize = 20): Promise<ApiResponse<CombinedSearchResult>> => {
    const response = await api.get('/search', { params: { q, page, pageSize } });
    return response.data;
  },
};

export const articlesAPI = {
  create: async (data: { title: string; summary: string; content: string; categoryId: number; tagIds: number[] }): Promise<ApiResponse<ArticleDto>> => {
    const response = await api.post('/articles', data);
    return response.data;
  },

  getCategories: async (): Promise<ApiResponse<Category[]>> => {
    const response = await api.get('/categories');
    return response.data;
  },

  getTags: async (): Promise<ApiResponse<Tag[]>> => {
    const response = await api.get('/tags');
    return response.data;
  },
};

export default api;
