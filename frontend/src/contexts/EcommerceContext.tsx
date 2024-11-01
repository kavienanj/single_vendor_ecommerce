"use client";

import React, { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { apiClient } from '@/services/axiosClient';
import { useAuth } from './AuthContext';

export interface Product {
	product_id: number;
	product_name: string;
	product_description: string;
	price: number;
	image_url: string;
	sku: string;
	weight: number;
	categories: string[];
}

export interface VariantAttribute {
	attribute_name: string;
	attribute_value: string | number;
}

export interface Variant {
	variant_id: number;
	variant_name: string;
	product_id: number;
	product_name: string;
	image_url: string;
	price: number;
	quantity_available: number;
	attributes: VariantAttribute[];
}

export interface ProductWithVarients extends Product {
	variants: Variant[];
}

export interface CartItem extends Variant {
	quantity: number;
}

export interface Category {
	category_id: number;
	category_name: string;
	category_description: string;
	sub_categories?: Category[];
}

export interface Order {
  order_id: number;
  customer_id: number;
  customer_name: string;
  contact_email: string | null;
  contact_phone: string | null;
  delivery_address: string | null;
  delivery_method: string;
  delivery_location_id: number | null;
  payment_method: string | null;
  total_amount: number;
  order_status: string;
  purchased_time: string;
  delivery_estimate: number | null;
  created_at: string;
  updated_at: string;
  items: {
    variant_id: number;
	product_id: number;
	product_name: string;
    price: number;
    quantity: number;
    total_price: number;
    variant_name: string;
    quantity_available: number;
  }[]
}

interface FetchFilteredProductsParams {
	categoryId?: number;
	sort?: 'price' | 'name';
	order?: 'asc' | 'desc';
	search?: string;
	limit?: number;
}

// Define the shape of the context state
interface EcommerceContextState {
	cart: CartItem[];
	categories: Category[];
	addToCart: (variant: Variant, quantity: number) => void;
	removeFromCart: (variantId: number) => void;
	fetchProductWithVariants: (productId: number) => Promise<ProductWithVarients>;
	fetchFilteredProducts: (params: FetchFilteredProductsParams) => Promise<Product[]>;
	callPostCheckout: () => void;
}

// Create the context with default values
const EcommerceContext = createContext<EcommerceContextState | undefined>(undefined);

// Create the provider component
export const EcommerceProvider = ({ children }: { children: ReactNode }) => {
	const [cart, setCart] = useState<CartItem[]>([]);
	const [categories, setCategories] = useState<Category[]>([]);
	const { user } = useAuth();

	const fetchCategories = async () => {
		const fetchedCategories = await apiClient.get('/category').then(res => res.data);
		setCategories(fetchedCategories);
	};

	const fetchFilteredProducts = async (params: FetchFilteredProductsParams) => {
		const filteredProducts = await apiClient.get('/products', { params }).then(res => res.data);
		return filteredProducts;
	}

	const fetchUserCart = async () => {
		const cart = await apiClient.get(`/cart`).then(res => res.data);
		return cart;
	}

	const fetchAddtoCart = async (variant_id: number, quantity: number) => {
		const variant = await apiClient.post(`/cart`, { variant_id, quantity }).then(res => res.data);
		return variant;
	}

	const fetchRemoveFromCart = async (variant_id: number) => {
		const variant = await apiClient.post(`/cart/remove`, { variant_id }).then(res => res.data);
		return variant;
	}

	const fetchProductWithVariants = async (productId: number) => {
		const product = await apiClient.get(`/products/${productId}`).then(res => res.data);
		return product;
	}

	const callPostCheckout = async () => {
		setCart([]);
		fetchUserCart().then(cart => {
			setCart(cart);
		});
	}

	const addToCart = (variant: Variant, quantity: number) => {
		if (cart.some((item) => item.variant_id === variant.variant_id)) {
			if (quantity <= 0) {
				removeFromCart(variant.variant_id);
				fetchRemoveFromCart(variant.variant_id);
			} else {
				setCart((prevCart) => prevCart.map(
					(item) => item.variant_id === variant.variant_id
						? { ...item, quantity } 
						: item
				));
				fetchAddtoCart(variant.variant_id, quantity);
			} 
		} else {
			setCart((prevCart) => [...prevCart, { ...variant, quantity }]);
			fetchAddtoCart(variant.variant_id, quantity);
		}
	};

	const removeFromCart = (variantId: number) => {
		setCart((prevCart) => prevCart.filter((item) => item.variant_id !== variantId));
		fetchRemoveFromCart(variantId);
	};

	useEffect(() => {
		fetchCategories();
		if (user) {
			fetchUserCart().then(cart => {
				setCart(cart);
			});
		}
	}, [user]);

	return (
		<EcommerceContext.Provider value={{ 
			cart,
			categories,
			addToCart,
			removeFromCart,
			fetchProductWithVariants,
			fetchFilteredProducts,
			callPostCheckout,
		}}>
			{children}
		</EcommerceContext.Provider>
	);
};

// Custom hook to use the EcommerceContext
export const useEcommerce = () => {
	const context = useContext(EcommerceContext);
	if (context === undefined) {
		throw new Error('useEcommerce must be used within an EcommerceProvider');
	}
	return context;
};
