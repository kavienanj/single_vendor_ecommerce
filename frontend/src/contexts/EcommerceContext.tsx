"use client";

import React, { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { apiClient, setTokenToApiClientHeader } from '@/services/axiosClient';

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

// Define the shape of the context state
interface EcommerceContextState {
	cart: CartItem[];
	products: Product[];
	categories: Category[];
	addToCart: (variant: Variant, quantity: number) => void;
	removeFromCart: (variantId: number) => void;
	fetchProductWithVariants: (productId: number) => Promise<ProductWithVarients>;
	callPostCheckout: () => void;
}

// Create the context with default values
const EcommerceContext = createContext<EcommerceContextState | undefined>(undefined);

// Create the provider component
export const EcommerceProvider = ({ children }: { children: ReactNode }) => {
	const [cart, setCart] = useState<CartItem[]>([]);
	const [products, setProducts] = useState<Product[]>([]);
	const [categories, setCategories] = useState<Category[]>([]);

	// Fetch products and categories from an API or other source
	const fetchProductsAndCategories = async () => {
		// Replace with your actual data fetching logic
		const fetchedProducts = await apiClient.get('/products').then(res => res.data);
		const fetchedCategories = await apiClient.get('/category').then(res => res.data);

		setProducts(fetchedProducts);
		setCategories(fetchedCategories);
	};

	const fetchUserCredentials = async () => {
		if (localStorage.getItem('token')) {
			return localStorage.getItem('token');
		}
		const token = await apiClient.post('/register', { is_guest: true }).then(res => res.data.token);
		localStorage.setItem('token', token);
		return token;
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
		fetchProductsAndCategories();
		fetchUserCart().then(cart => {
			setCart(cart);
		});
	}

	useEffect(() => {
		fetchProductsAndCategories();
		fetchUserCredentials().then(token => {
			setTokenToApiClientHeader(token);
			fetchUserCart().then(cart => {
				setCart(cart);
			});
		});
	}, []);

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

	return (
		<EcommerceContext.Provider value={{ 
			cart,
			products,
			categories,
			addToCart,
			removeFromCart,
			fetchProductWithVariants,
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
