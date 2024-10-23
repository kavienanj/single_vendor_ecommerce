"use client"

import { useState } from "react"
import { ChevronRight, Filter,  Plus, Minus } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardFooter, CardTitle } from "@/components/ui/card"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"

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

interface CartItem extends Product {
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

const categories = [
  { name: "All", subcategories: [] },
  { name: "Mobile", subcategories: ["Smartphones", "Tablets"] },
  { name: "Audio", subcategories: ["Earphones", "Speakers"] },
  { name: "Wearable", subcategories: ["Smartwatches", "Fitness Bands"] },
]

export function HomePageComponent() {
  const [selectedCategory, setSelectedCategory] = useState("All")
  const [selectedSubCategory, setSelectedSubCategory] = useState("")
  const [cart, setCart] = useState<CartItem[]>([]) // Update: Ensure cart state is properly initialized
  const [isFilterOpen, setIsFilterOpen] = useState(false)
  const [sortBy, setSortBy] = useState("featured")
  const [showCount, setShowCount] = useState("12")

  const filteredProducts = products.filter(product => 
    (selectedCategory === "All" || product.category === selectedCategory) &&
    (selectedSubCategory === "" || product.subCategory === selectedSubCategory)
  )

  const sortedProducts = [...filteredProducts].sort((a, b) => {
    if (sortBy === "price-asc") return a.price - b.price
    if (sortBy === "price-desc") return b.price - a.price
    return 0 // "featured" or default
  })

  const addToCart = (product: Product) => {
    const existingItem = cart.find(item => item.id === product.id)
    if (existingItem) {
      setCart(cart.map(item =>
        item.id === product.id
          ? { ...item, quantity, selectedColor, selectedStorage }
          : item
      ))
    } else {
      setCart([...cart, { ...product, quantity, selectedColor, selectedStorage }])
    }
    setSelectedProduct(null)
    setQuantity(1)
    setSelectedColor("")
    setSelectedStorage("")
  }

  const removeFromCart = (productId: number) => {
    setCart(cart.filter(item => item.id !== productId))
  }

  const isInCart = (productId: number) => {
    return cart.some(item => item.id === productId)
  }

  const renderCategoryMenu = () => (
    <Accordion type="single" collapsible className="w-full">
      {categories.map((category) => (
        <AccordionItem key={category.name} value={category.name}>
          <AccordionTrigger
            onClick={() => {
              setSelectedCategory(category.name)
              setSelectedSubCategory("")
            }}
          >
            {category.name}
          </AccordionTrigger>
          {category.subcategories.length > 0 && (
            <AccordionContent>
              {category.subcategories.map((subCategory) => (
                <Button
                  key={subCategory}
                  variant="ghost"
                  className="w-full justify-start pl-6 mb-2"
                  onClick={() => {
                    setSelectedSubCategory(subCategory)
                  }}
                >
                  <ChevronRight className="mr-2 h-4 w-4" />
                  {subCategory}
                </Button>
              ))}
            </AccordionContent>
          )}
        </AccordionItem>
      ))}
    </Accordion>
  )

  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null)
  const [quantity, setQuantity] = useState(1)
  const [selectedColor, setSelectedColor] = useState("")
  const [selectedStorage, setSelectedStorage] = useState("")

  return (
    <main className="container mx-auto px-4 py-8">
      <div className="mb-6 text-lg font-semibold">
        {selectedCategory === "All" ? "Showing all products" : `Showing ${selectedSubCategory || selectedCategory}`}
      </div>
      <div className="flex flex-col md:flex-row gap-6">
        <aside className="w-full md:w-64">
          <Card className="hidden md:block">
            <CardContent className="p-4">
              <h2 className="text-lg font-semibold mb-4">Categories</h2>
              {renderCategoryMenu()}
            </CardContent>
          </Card>
          <Sheet open={isFilterOpen} onOpenChange={setIsFilterOpen}>
            <SheetTrigger asChild>
              <Button variant="outline" className="w-full md:hidden">
                <Filter className="mr-2 h-4 w-4" />
                Filters
              </Button>
            </SheetTrigger>
            <SheetContent side="left">
              <div className="py-4">
                <h2 className="text-lg font-semibold mb-4">Categories</h2>
                {renderCategoryMenu()}
              </div>
            </SheetContent>
          </Sheet>
        </aside>
        <div className="flex-1">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
            <div className="flex flex-col sm:flex-row gap-4">
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Sort by" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="featured">Featured</SelectItem>
                  <SelectItem value="price-asc">Price: Low to High</SelectItem>
                  <SelectItem value="price-desc">Price: High to Low</SelectItem>
                </SelectContent>
              </Select>
              <Select value={showCount} onValueChange={setShowCount}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Show" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="12">Show 12</SelectItem>
                  <SelectItem value="24">Show 24</SelectItem>
                  <SelectItem value="36">Show 36</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {sortedProducts.slice(0, parseInt(showCount)).map((product) => (
              <Card key={product.id}>
                <CardContent className="p-4">
                  <img
                    src={product.image}
                    alt={product.title}
                    className="w-full h-48 object-cover mb-4 rounded-md"
                  />
                  <CardTitle className="mb-2">{product.title}</CardTitle>
                  <p className="text-sm text-gray-600">SKU: {product.sku}</p>
                  <p className="text-sm text-gray-600">Weight: {product.weight}</p>
                  <p className="text-sm text-gray-600">{product.category} - {product.subCategory}</p>
                  <p className="text-lg font-bold mt-2">${product.price}</p>
                </CardContent>
                <CardFooter className="p-4 pt-0">
                  <Dialog>
                    <DialogTrigger asChild>
                      <Button 
                        className="w-full" 
                        onClick={() => {
                          setSelectedProduct(product)
                          const cartItem = cart.find(item => item.id === product.id)
                          if (cartItem) {
                            setQuantity(cartItem.quantity)
                            setSelectedColor(cartItem.selectedColor || "")
                            setSelectedStorage(cartItem.selectedStorage || "")
                          } else {
                            setQuantity(1)
                            setSelectedColor(product.colors ? product.colors[0] : "")
                            setSelectedStorage(product.storage ? product.storage[0] : "")
                          }
                        }}
                      >
                        {isInCart(product.id) ? "Edit Cart" : "Add to Cart"}
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[425px]">
                      <DialogHeader>
                        <DialogTitle>{product.title}</DialogTitle>
                        <DialogDescription>
                          Customize your product and add it to your cart.
                        </DialogDescription>
                      </DialogHeader>
                      <div className="grid gap-4 py-4">
                        <div className="grid grid-cols-2 items-center gap-4">
                          
                          <img
                            src={product.image}
                            alt={product.title}
                            className="w-full h-48 object-cover rounded-md"
                          />
                          <div>
                            <p className="text-sm text-gray-600">SKU: {product.sku}</p>
                            <p className="text-sm text-gray-600">Weight: {product.weight}</p>
                            <p className="text-sm text-gray-600">{product.category} - {product.subCategory}</p>
                            <p className="text-lg font-bold mt-2">${product.price}</p>
                          </div>
                        </div>
                        {product.colors && (
                          <>
                            <h4 className="text-sm font-medium mb-1">Color</h4>
                            <div className="grid grid-cols-4 gap-2">
                              {product.colors.map((color) => (
                                <Button
                                  key={color}
                                  variant={selectedColor === color ? "default" : "outline"}
                                  onClick={() => setSelectedColor(color)}
                                >
                                  {color}
                                </Button>
                              ))}
                            </div>
                          </>
                        )}
                        {product.storage && (
                          <>
                            <h4 className="text-sm font-medium mb-1">Storage</h4>
                            <div className="grid grid-cols-3 gap-2">
                              {product.storage.map((storage) => (
                                <Button
                                  key={storage}
                                  variant={selectedStorage === storage ? "default" : "outline"}
                                  onClick={() => setSelectedStorage(storage)}
                                >
                                  {storage}
                                </Button>
                              ))}
                            </div>
                          </>
                        )}
                        <div className="flex items-center justify-between">
                          <span>Quantity:</span>
                          <div className="flex items-center gap-2">
                            <Button
                              variant="outline"
                              size="icon"
                              onClick={() => setQuantity(Math.max(1, quantity - 1))}
                            >
                              <Minus className="h-4 w-4" />
                            </Button>
                            <span>{quantity}</span>
                            <Button
                              variant="outline"
                              size="icon"
                              onClick={() => setQuantity(quantity + 1)}
                            >
                              <Plus className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      </div>
                      <div className="flex flex-col gap-2 w-full">
                        {isInCart(product.id) ? (
                          <Button onClick={() => addToCart(product)} className="w-full">
                            Update Cart
                          </Button>
                        ) : (
                          <Button onClick={() => addToCart(product)} className="w-full">
                            Add to Cart
                          </Button>
                        )}
                        <Button variant="outline" className="w-full">
                          Buy Now
                        </Button>
                      </div>
                    </DialogContent>
                  </Dialog>
                </CardFooter>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </main>
  )
}
