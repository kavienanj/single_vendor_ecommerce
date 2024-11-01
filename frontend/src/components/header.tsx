"use client"

import { useState, useRef, useEffect } from "react"
import { ShoppingCart, User, Search } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import Link from "next/link"
import { Product, useEcommerce } from "@/contexts/EcommerceContext"
import { useAuth } from "@/contexts/AuthContext"
import { ProductDialogButton } from "./product-dialog-button"

export default function Header() {
  const [searchQuery, setSearchQuery] = useState("")
  const [searchSelectedProduct, setSearchSelectedProduct] = useState<Product | null>(null);
  const [showSuggestions, setShowSuggestions] = useState(false)
  const searchRef = useRef<HTMLDivElement>(null)
  const { cart, fetchFilteredProducts } = useEcommerce();
  const [products, setProducts] = useState<Product[]>([])
  const { user, logout, isAdmin, isGuest, isCustomer } = useAuth();

  const loadFilteredProducts = async () => {
    const response = await fetchFilteredProducts({
      search: searchQuery,
    });
    setProducts(response);
  }

  useEffect(() => {
    const handler = setTimeout(() => {
      loadFilteredProducts();
    }, 500); // Wait 500ms after the last keystroke

    return () => {
      clearTimeout(handler); // Cleanup the timeout if searchQuery changes
    };
  }, [searchQuery])

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setShowSuggestions(false)
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
    }
  }, [])

  return (
    <header className="bg-white shadow-sm">
      <div className="container mx-auto px-4 py-4 flex flex-col sm:flex-row justify-between items-center gap-4">
        <Link href="/">
          <h1 className="text-2xl font-bold">C Ecommerce</h1>
        </Link>
        <div className="flex-1 max-w-md w-full" ref={searchRef}>
          <div className="relative">
            <Input
              type="text"
              placeholder="Search products..."
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value)
                setShowSuggestions(true)
              }}
              onFocus={() => setShowSuggestions(true)}
              className="w-full pl-10"
            />
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            {showSuggestions && searchQuery && (
              <div className="absolute z-10 w-full bg-white mt-1 rounded-md shadow-lg max-h-60 overflow-auto">
                {products.map((product) => (
                  <div
                    key={product.product_id}
                    className="p-2 hover:bg-gray-100 cursor-pointer"
                    onClick={() => {
                      setSearchQuery(product.product_name)
                      setShowSuggestions(false)
                      setSearchSelectedProduct(product)
                    }}
                  >
                    {product.product_name}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
        <div className="flex items-center gap-4">
          <Link href="/my-cart">
            <Button variant="outline" size="icon" className="relative">
              <ShoppingCart className="h-5 w-5" />
              {cart && cart.length > 0 && (
                <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                  {cart.length}
                </span>
              )}
            </Button>
          </Link>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="icon">
                <User className="h-5 w-5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuLabel>
                {isGuest() && (
                  `Guest User`
                )}
                {isCustomer() && (
                  `Welcome, ${user?.first_name}`
                )}
                {isAdmin() && (
                  `Welcome, Admin`
                )}
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              {/* {isCustomer() && (
                <DropdownMenuItem>Profile</DropdownMenuItem>
              )} */}
              {isGuest() && (
                <Link href="/sign-in">
                  <DropdownMenuItem>
                    Sign In
                  </DropdownMenuItem>
                </Link>
              )}
              {isAdmin() && (
                <Link href="/admin">
                  <DropdownMenuItem>
                    Admin Panel
                  </DropdownMenuItem>
                </Link>
              )}
              <Link href="/my-orders">
                <DropdownMenuItem>My Orders</DropdownMenuItem>
              </Link>
              {isCustomer() && (
                <DropdownMenuItem onClick={logout}>
                  Logout
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
      {searchSelectedProduct && (
        <ProductDialogButton 
          product={searchSelectedProduct}
          isOpen={searchSelectedProduct !== null}
          onClose={() => setSearchSelectedProduct(null)}
        >
          <div className="sr-only">
            Product Dialog
          </div>
        </ProductDialogButton>
      )}
    </header>
  )
}
