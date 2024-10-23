"use client"

import { useState, useRef, useEffect } from "react"
import { ShoppingCart, User, Search } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import Link from "next/link"

interface Product {
  id: number
  title: string
  sku: string
  weight: string
  category: string
  subCategory: string
  price: number
  image: string
  colors?: string[]
  storage?: string[]
}

interface CartItem {
  id: number
  title: string
  price: number
  image: string
  quantity: number
  selectedColor?: string
  selectedStorage?: string
}

const products: Product[] = [
  { id: 1, title: "Smartphone X", sku: "SP-001", weight: "180g", category: "Mobile", subCategory: "Smartphones", price: 699, image: "/placeholder.svg", colors: ["Black", "White", "Blue"], storage: ["64GB", "128GB", "256GB"] },
  { id: 2, title: "Tablet Pro", sku: "TB-001", weight: "450g", category: "Mobile", subCategory: "Tablets", price: 499, image: "/placeholder.svg", colors: ["Silver", "Space Gray"], storage: ["128GB", "256GB", "512GB"] },
  { id: 3, title: "Wireless Earbuds", sku: "AU-001", weight: "50g", category: "Audio", subCategory: "Earphones", price: 129, image: "/placeholder.svg", colors: ["White", "Black", "Pink"] },
  { id: 4, title: "Bluetooth Speaker", sku: "AU-002", weight: "300g", category: "Audio", subCategory: "Speakers", price: 79, image: "/placeholder.svg", colors: ["Black", "Blue", "Red"] },
  { id: 5, title: "Smart Watch", sku: "WR-001", weight: "40g", category: "Wearable", subCategory: "Smartwatches", price: 199, image: "/placeholder.svg", colors: ["Black", "Silver", "Gold"] },
  { id: 6, title: "Fitness Tracker", sku: "WR-002", weight: "25g", category: "Wearable", subCategory: "Fitness Bands", price: 89, image: "/placeholder.svg", colors: ["Black", "Blue", "Pink"] },
]

export default function Header() {
  const [searchQuery, setSearchQuery] = useState("")
  const [showSuggestions, setShowSuggestions] = useState(false)
  const searchRef = useRef<HTMLDivElement>(null)

  const cart = [
    { id: 1, title: "Smartphone X", price: 699, image: "/placeholder.svg", quantity: 2, selectedColor: "Black", selectedStorage: "128GB" },
    { id: 2, title: "Wireless Earbuds", price: 129, image: "/placeholder.svg", quantity: 1, selectedColor: "White" },
  ];

  const searchSuggestions = products.filter(product =>
    product.title.toLowerCase().includes(searchQuery.toLowerCase())
  )

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
          <h1 className="text-2xl font-bold">My Ecommerce</h1>
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
                {searchSuggestions.map((product) => (
                  <div
                    key={product.id}
                    className="p-2 hover:bg-gray-100 cursor-pointer"
                    onClick={() => {
                      setSearchQuery(product.title)
                      setShowSuggestions(false)
                    }}
                  >
                    {product.title}
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
              <DropdownMenuItem>Profile</DropdownMenuItem>
              <DropdownMenuItem>My Orders</DropdownMenuItem>
              <DropdownMenuItem>Logout</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  )
}
