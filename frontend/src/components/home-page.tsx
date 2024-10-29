"use client"

import { useState } from "react"
import { ChevronRight, Filter } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardFooter, CardTitle } from "@/components/ui/card"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Category, useEcommerce } from "@/contexts/EcommerceContext"
import { ProductDialogButton } from "./product-dialog-button"
import { CarouselComponent } from "./home/carousel-slider"

export function HomePageComponent() {
  const { products, categories } = useEcommerce()
  const allCategories = { category_name: "All", category_id: 0 } as Category;
  const [selectedCategory, setSelectedCategory] = useState("All")
  const [selectedSubCategory, setSelectedSubCategory] = useState("")
  const [isFilterOpen, setIsFilterOpen] = useState(false)
  const [sortBy, setSortBy] = useState("featured")
  const [showCount, setShowCount] = useState("12")

  const filteredProducts = products.filter(product => 
    (selectedCategory === "All" || product.categories.includes(selectedCategory)) &&
    (selectedSubCategory === "" || product.categories.includes(selectedSubCategory))
  )

  const sortedProducts = [...filteredProducts].sort((a, b) => {
    if (sortBy === "price-asc") return a.price - b.price
    if (sortBy === "price-desc") return b.price - a.price
    return 0 // "featured" or default
  })

  const renderCategoryMenu = () => (
    <Accordion type="single" collapsible className="w-full">
      {[allCategories, ...categories].map((category) => (
        <AccordionItem key={category.category_name} value={category.category_name}>
          <AccordionTrigger
            onClick={() => {
              setSelectedCategory(category.category_name)
              setSelectedSubCategory("")
            }}
          >
            {category.category_name}
          </AccordionTrigger>
          {(category.sub_categories?.length || 0) > 0 && (
            <AccordionContent>
              {category.sub_categories!.map((subCategory) => (
                <Button
                  key={subCategory.category_id}
                  variant="ghost"
                  className="w-full justify-start pl-6 mb-2"
                  onClick={() => {
                    setSelectedSubCategory(subCategory.category_name)
                  }}
                >
                  <ChevronRight className="mr-2 h-4 w-4" />
                  {subCategory.category_name}
                </Button>
              ))}
            </AccordionContent>
          )}
        </AccordionItem>
      ))}
    </Accordion>
  )

  return (
    <main className="container mx-auto px-4 py-8">
      <CarouselComponent />
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
            <div className="flex flex-row gap-2">
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="sm:w-[180px]">
                  <SelectValue placeholder="Sort by" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="featured">Featured</SelectItem>
                  <SelectItem value="price-asc">Price: Low to High</SelectItem>
                  <SelectItem value="price-desc">Price: High to Low</SelectItem>
                </SelectContent>
              </Select>
              <Select value={showCount} onValueChange={setShowCount}>
                <SelectTrigger className="sm:w-[180px]">
                  <SelectValue placeholder="Show" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="12">Show 12</SelectItem>
                  <SelectItem value="24">Show 24</SelectItem>
                  <SelectItem value="-1">Show All</SelectItem>
                </SelectContent>
              </Select>
              <div className="pl-4 flex items-center text-sm text-gray-600">
                Showing {showCount === "-1" ? 'All' : showCount} of {products.length} products
              </div>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {sortedProducts.slice(0, parseInt(showCount)).map((product) => (
              <Card key={product.product_id}>
                <CardContent className="p-4">
                  <img
                    src={product.image_url}
                    alt={product.product_name}
                    className="w-full h-48 object-cover mb-4 rounded-md"
                  />
                  <CardTitle className="mb-2">{product.product_name}</CardTitle>
                  <p className="text-sm text-gray-600">SKU: {product.sku}</p>
                  <p className="text-sm text-gray-600">Weight: {product.weight}</p>
                  <p className="text-sm text-gray-600">{product.categories.join(", ")}</p>
                  <p className="text-lg font-bold mt-2">${product.price}</p>
                </CardContent>
                <CardFooter className="p-4 pt-0">
                  <ProductDialogButton product={product} />
                </CardFooter>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </main>
  )
}
