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
