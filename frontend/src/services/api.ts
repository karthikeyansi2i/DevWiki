import axios, { AxiosInstance } from 'axios';
import { ApiResponse, LoginResponse, RegisterResponse } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://localhost:7000/api';

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

export default api;
