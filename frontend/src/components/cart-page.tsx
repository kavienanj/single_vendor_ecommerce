"use client"

import { Minus, Plus, Trash2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { useEcommerce } from "@/contexts/EcommerceContext"
import { useState } from "react"
import { apiClient } from "@/services/axiosClient"
import { useRouter } from "next/navigation"
import Link from "next/link"

export function CartPageComponent() {
  const router = useRouter();
  const { addToCart, removeFromCart, callPostCheckout, cart } = useEcommerce();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const calculateTotal = () => {
    return cart.reduce((total, item) => total + item.price * item.quantity, 0)
  }

  const handleCheckout = async () => {
    setLoading(true);
    const response = await apiClient.post("/cart/checkout").then((res) => res.data);
    if (response) {
      callPostCheckout();
      router.push(`/checkout/${response.order_id}`);
    } else {
      setError("An error occurred while processing your order.");
    }
    setLoading(false);
  }

  return (
    <main className="min-h-[50vh] container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-6">Your Cart</h1>
      {cart.length === 0 ? (
        <div className="flex flex-col items-center space-y-4 mt-8">
          <p className="text-center text-gray-500">Your cart is empty.</p>
          <Link className="mt-4" href="/">
            <Button>Continue Shopping</Button>
          </Link>
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-3">
          <div className="md:col-span-2 space-y-4">
            {cart.map((item) => (
              <Card key={item.variant_id}>
                <CardContent className="flex items-center p-4">
                  <img src={item.image_url} alt={item.variant_name} className="w-20 h-20 object-cover rounded-md mr-4" />
                  <div className="flex-grow">
                    <h2 className="font-semibold">{item.variant_name}</h2>
                    <p className="text-sm text-gray-600">
                      {item.attributes.map(
                        (attr) => `${attr.attribute_name}: ${attr.attribute_value}`).join(", ")
                      }
                    </p>
                    <p className="font-bold mt-1">${item.price.toFixed(2)}</p>
                    {/* Stock available */}
                    {(item.quantity_available - item.quantity) > 0 ? (
                      <p className="text-green-500">In stock: {item.quantity_available - item.quantity}</p>
                    ) : (
                      <p className="text-red-500">Out of stock</p>
                    )}
                  </div>
                  <div className="flex items-center space-x-2">
                    <Button
                      variant="outline"
                      size="icon"
                      onClick={() => addToCart(item, item.quantity - 1)}
                    >
                      <Minus className="h-4 w-4" />
                    </Button>
                    <span>{item.quantity}</span>
                    <Button
                      variant="outline"
                      size="icon"
                      onClick={() => addToCart(item, item.quantity + 1)}
                    >
                      <Plus className="h-4 w-4" />
                    </Button>
                  </div>
                  <Button
                    variant="destructive"
                    size="icon"
                    className="ml-4"
                    onClick={() => removeFromCart(item.variant_id)}
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
          <div>
            <Card>
              <CardContent className="p-4">
                <h2 className="font-semibold text-lg mb-4">Order Summary</h2>
                <div className="space-y-2">
                  {cart.map((item) => (
                    <div key={item.variant_id} className="flex justify-between text-sm">
                      <span>{item.variant_name} (x{item.quantity})</span>
                      <span>${(item.price * item.quantity).toFixed(2)}</span>
                    </div>
                  ))}
                </div>
                <div className="border-t mt-4 pt-4">
                  <div className="flex justify-between font-semibold">
                    <span>Total</span>
                    <span>${calculateTotal().toFixed(2)}</span>
                  </div>
                </div>
                <Button
                  className="w-full mt-6"
                  onClick={handleCheckout}
                  disabled={loading}
                >
                  {loading ? "Processing..." : "Proceed to Checkout"}
                </Button>
                {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
              </CardContent>
            </Card>
          </div>
        </div>
      )}
    </main>
  );
}
