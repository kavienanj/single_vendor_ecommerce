"use client"

import { useState } from "react"
import { CreditCard, Truck, Store, Banknote } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Separator } from "@/components/ui/separator"

const cartItems = [
  { id: 1, name: "Product 1", price: 19.99, quantity: 2 },
  { id: 2, name: "Product 2", price: 29.99, quantity: 1 },
]

export function CheckoutPageComponent() {
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    email: "",
    deliveryMethod: "",
    paymentMethod: "",
    cardNumber: "",
    cardExpiry: "",
    cardCVC: "",
  })

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const handleRadioChange = (name: string, value: string) => {
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const calculateTotal = () => {
    return cartItems.reduce((total, item) => total + item.price * item.quantity, 0)
  }

  const renderCheckoutSummary = () => (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Order Summary</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          {cartItems.map((item) => (
            <div key={item.id} className="flex justify-between">
              <span>
                {item.name} x {item.quantity}
              </span>
              <span>${(item.price * item.quantity).toFixed(2)}</span>
            </div>
          ))}
        </div>
        <Separator className="my-4" />
        <div className="flex justify-between font-semibold">
          <span>Total</span>
          <span>${calculateTotal().toFixed(2)}</span>
        </div>
      </CardContent>
    </Card>
  )

  return (
    <div className="container mx-auto p-4 py-8">
      <h1 className="text-2xl font-bold mb-6">Order Checkout</h1>
      <div className="md:flex md:space-x-8">
        <div className="md:w-2/3">
          <Card className="w-full mb-8">
            <CardHeader>
              <CardTitle>Complete your purchase</CardTitle>
              <CardDescription>Enter these details</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-8">
                <div>
                  <h2 className="text-xl font-semibold mb-4">User Details</h2>
                  <div className="space-y-4">
                    <div className="grid gap-2">
                      <Label htmlFor="name">Name</Label>
                      <Input id="name" name="name" value={formData.name} onChange={handleInputChange} />
                    </div>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="grid gap-2">
                        <Label htmlFor="phone">Phone</Label>
                        <Input id="phone" name="phone" value={formData.phone} onChange={handleInputChange} />
                      </div>
                      <div className="grid gap-2">
                        <Label htmlFor="email">Email</Label>
                        <Input id="email" name="email" type="email" value={formData.email} onChange={handleInputChange} />
                      </div>
                    </div>
                  </div>
                </div>

                <Separator />

                <div>
                  <h2 className="text-xl font-semibold mb-4">Delivery Method</h2>
                  <RadioGroup
                    onValueChange={(value) => handleRadioChange("deliveryMethod", value)}
                    value={formData.deliveryMethod}
                  >
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="store" id="store" />
                      <Label htmlFor="store" className="flex items-center">
                        <Store className="mr-2" />
                        Store Pickup
                      </Label>
                    </div>
                    <div className="flex items-center space-x-2 mt-2">
                      <RadioGroupItem value="delivery" id="delivery" />
                      <Label htmlFor="delivery" className="flex items-center">
                        <Truck className="mr-2" />
                        Home Delivery
                      </Label>
                    </div>
                  </RadioGroup>
                </div>

                <Separator />

                <div>
                  <h2 className="text-xl font-semibold mb-4">Payment Method</h2>
                  <RadioGroup
                    onValueChange={(value) => handleRadioChange("paymentMethod", value)}
                    value={formData.paymentMethod}
                  >
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="cash" id="cash" />
                      <Label htmlFor="cash" className="flex items-center">
                        <Banknote className="mr-2" />
                        Cash on Delivery
                      </Label>
                    </div>
                    <div className="flex items-center space-x-2 mt-2">
                      <RadioGroupItem value="card" id="card" />
                      <Label htmlFor="card" className="flex items-center">
                        <CreditCard className="mr-2" />
                        Card
                      </Label>
                    </div>
                  </RadioGroup>

                  {formData.paymentMethod === "card" && (
                    <div className="space-y-4 mt-4">
                      <div className="grid gap-2">
                        <Label htmlFor="cardNumber">Card Number</Label>
                        <Input
                          id="cardNumber"
                          name="cardNumber"
                          value={formData.cardNumber}
                          onChange={handleInputChange}
                        />
                      </div>
                      <div className="grid grid-cols-2 gap-4">
                        <div className="grid gap-2">
                          <Label htmlFor="cardExpiry">Expiry Date</Label>
                          <Input
                            id="cardExpiry"
                            name="cardExpiry"
                            placeholder="MM/YY"
                            value={formData.cardExpiry}
                            onChange={handleInputChange}
                          />
                        </div>
                        <div className="grid gap-2">
                          <Label htmlFor="cardCVC">CVC</Label>
                          <Input id="cardCVC" name="cardCVC" value={formData.cardCVC} onChange={handleInputChange} />
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
        <div className="md:w-1/3 space-y-8">
          {renderCheckoutSummary()}
          <Button onClick={() => alert("Order placed successfully!")} className="w-full">
            Place Order
          </Button>
        </div>
      </div>
    </div>
  )
}