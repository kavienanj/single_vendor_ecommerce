'use client';

import React, { createContext, ReactNode, useContext, useEffect, useState } from 'react';
import { jwtDecode } from 'jwt-decode';
import { apiClient, setTokenToApiClientHeader } from '@/services/axiosClient';
import { AxiosError } from 'axios';

interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  role_id: number;
}

interface RegisterUserPayload {
  first_name: string;
  last_name: string;
  email: string;
  password: string;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  isAdmin (): boolean;
  isGuest (): boolean;
  isCustomer (): boolean;
  registerUser: (payload: RegisterUserPayload) => Promise<{ success: boolean, message: string }>;
  signin: (email: string, password: string) => Promise<{ success: boolean, message: string }>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const signin = async (email: string, password: string) => {
    try {
      setLoading(true);
      const response = await apiClient.post(
        '/login',
        { email, password },
      );
      if (response.status === 200) {
        const { token } = await response.data;
        localStorage.setItem('token', token);
        const decodedUser: User = jwtDecode(token);
        setUser(decodedUser);
        setTokenToApiClientHeader(token);
        setLoading(false);
        return { success: true, message: 'Signin successful' };
      } else {
        setLoading(false);
        return { success: false, message: response?.data?.message || 'Signin failed' };
      }
    } catch (error) {
      const errorMessages = (error as AxiosError).response?.data as { message: string };
      setLoading(false);
      return { success: false, message: `Signin failed: ${errorMessages.message}` };
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    registerGuestUser().then(loadUserFromToken);
  };

  const registerUser = async (payload: RegisterUserPayload) => {
    try {
      setLoading(true);
      const response = await apiClient.post(
        '/register',
        payload,
      );
      if (response.status === 201) {
        const { token } = await response.data;
        localStorage.setItem('token', token);
        const decodedUser: User = jwtDecode(token);
        setUser(decodedUser);
        setTokenToApiClientHeader(token);
        setLoading(false);
        return { success: true, message: 'User registered successfully' };
      } else {
        setLoading(false);
        return { success: false, message: response?.data?.message || 'User registration failed' };
      }
    } catch (error) {
      const errorMessages = (error as AxiosError).response?.data as { message: string };
      setLoading(false);
      return { success: false, message: `User registration failed: ${errorMessages.message}` };
    }
  }

  const registerGuestUser = async () => {
		const token = await apiClient.post('/register', { is_guest: true }).then(res => res.data.token);
		return token;
	}

  const authenticateUser = async () => {
    try {
      await apiClient.post('/authenticate');
      return true;
    } catch (error) {
      return false;
    }
  }

  const loadUserFromToken = async (token: string) => {
    localStorage.setItem('token', token);
    setTokenToApiClientHeader(token);
    const decodedUser: User = jwtDecode(token);
    setUser(decodedUser);
    setLoading(false);
  }

  function isAdmin (): boolean {
    return user?.role_id === 1;
  }

  function isGuest (): boolean {
    return user === null || user?.role_id === 3;
  }

  function isCustomer (): boolean {
    return user?.role_id === 2;
  }

  useEffect(() => {
    setLoading(true);
    const token = localStorage.getItem('token');
    if (token) {
      console.log('Found User token');
      setTokenToApiClientHeader(token);
      authenticateUser().then((isAuthenticated) => {
        if (isAuthenticated) {
          console.log('User is authenticated');
          loadUserFromToken(token);
        } else {
          console.log('User is not authenticated');
          localStorage.removeItem('token');
          console.log('Registering guest user');
          registerGuestUser().then(loadUserFromToken);
        }
      });
    } else {
      console.log('Registering guest user');
      registerGuestUser().then(loadUserFromToken);
    }
  }, []);

  return (
    <AuthContext.Provider value={{ 
      user, 
      loading,
      isAdmin,
      isGuest,
      isCustomer,
      signin, 
      logout, 
      registerUser, 
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
