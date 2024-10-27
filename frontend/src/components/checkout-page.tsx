"use client"

import { useEffect, useState } from "react"
import { CreditCard, Truck, Store, Banknote } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Separator } from "@/components/ui/separator"
import { apiClient } from "@/services/axiosClient"
import { useAuth } from "@/contexts/AuthContext"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import Link from "next/link"

interface Order {
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
  delivery_estimate: string | null;
  created_at: string;
  updated_at: string;
  items: {
    variant_id: number;
    price: number;
    quantity: number;
    total_price: number;
    variant_name: string;
    quantity_available: number;
  }[]
}

interface DeliveryLocation {
  delivery_location_id: number;
  location_name: string;
  location_type: string;
  with_stock_delivery_days: number;
  without_stock_delivery_days: number;
}

export function CheckoutPageComponent({ checkoutId }: { checkoutId: number }) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [order, setOrder] = useState<Order | null>(null);
  const [deliveryLocations, setDeliveryLocations] = useState<DeliveryLocation[]>([]);
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    email: "",
    address: "",
    deliveryMethod: "delivery",
    deliveryLocationId: "",
    paymentMethod: "cash",
    cardNumber: "",
    cardExpiry: "",
    cardCVC: "",
  })

  async function fetchOrder() {
    setLoading(true);
    try {
      const response = await apiClient.get(`/orders/${checkoutId}`);
      console.log(response.data);
      setOrder(response.data.order);
      setFormData({
        ...formData,
        name: response.data.order.customer_name,
        phone: response.data.order.contact_phone,
        email: response.data.order.contact_email,
        address: response.data.order.delivery_address,
        deliveryMethod: response.data.order.delivery_method || "delivery",
        paymentMethod: response.data.order.payment_method || "cash",
      });
      setLoading(false);
    } catch (error) {
      setError("An error occurred while fetching the order");
      setLoading(false);
    }
  }
  
  async function fetchDeliveryLocations() {
    try {
      const response = await apiClient.get("/delivery-locations");
      setDeliveryLocations(response.data.deliveryLocations);
    } catch (error) {
      console.error("An error occurred while fetching delivery locations", error);
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const handleRadioChange = (name: string, value: string) => {
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const submitOrder = async () => {
    setSubmitting(true);
    try {
      const response = await apiClient.post(`/orders/${checkoutId}/process`, {
        ...formData,
        deliveryLocationId: parseInt(formData.deliveryLocationId),
        paymentMethod: formData.paymentMethod === "card" ? "card" : "cash_on_delivery",
      });
      await fetchOrder();
      console.log(response.data);
      alert("Order placed successfully!");
      setSubmitting(false);
    } catch (error) {
      console.error("An error occurred while placing the order", error);
      alert("An error occurred while placing the order");
      setSubmitting(false);
    }
  }

  useEffect(() => {
    if (user) {
      fetchOrder();
      fetchDeliveryLocations();
    }
  }, [user]);

  if (loading) {
    return <div className="flex items-center justify-center h-screen">Loading...</div>;
  }

  if (error) {
    return <div className="flex items-center justify-center h-screen">{error}</div>;
  }

  if (order?.order_status === "Confirmed") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[50vh]">
        <div className="space-y-1">
          <h1 className="text-2xl font-bold mb-4">Order Placed</h1>
          <p>Your order has been placed successfully!</p>
          <p>Order ID: {order.order_id}</p>
          <p>Total Amount: ${order.total_amount.toFixed(2)}</p>
          <p>Delivery Estimate: {order.delivery_estimate}</p>
          <p>Order Status: {order.order_status}</p>
        </div>
        <Link href="/" className="mt-4">
          <Button>
            Continue Shopping
          </Button>
        </Link>
      </div>
    );
  }

  const calculateDeliveryEstimate = () => {
    if (formData.deliveryMethod === "") {
      return "Select a delivery method";
    }
    if (formData.deliveryMethod === "store_pickup") {
      return "Pickup today";
    }
    const location = deliveryLocations.find(
      (location) => location.delivery_location_id === parseInt(formData.deliveryLocationId),
    );
    if (!location) {
      return "(No location selected)";
    }
    let allItemsAvailable = true;
    for (const item of order!.items) {
      if (item.quantity > item.quantity_available) {
        allItemsAvailable = false;
        break;
      }
    }
    if (allItemsAvailable) {
      return `Deliver in ${location!.with_stock_delivery_days} days`;
    }
    return `Deliver in ${location!.without_stock_delivery_days} days`;
  }

  function canPlaceOrder() {
    if (!(formData.name && formData.phone && formData.email && formData.address)) {
      return false;
    }
    if (formData.deliveryLocationId === "") {
      return false;
    }
    console.log(formData.paymentMethod);
    if (formData.paymentMethod === "card") {
      return formData.cardNumber !== "" && formData.cardExpiry !== "" && formData.cardCVC !== "";
    }
    return true;
  }

  const renderCheckoutSummary = () => (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Order Summary</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          {order!.items.map((item) => (
            <div key={item.variant_id} className="flex justify-between">
              <span>
                {item.variant_name} x {item.quantity}
              </span>
              <span>${(item.total_price).toFixed(2)}</span>
            </div>
          ))}
        </div>
        <Separator className="my-4" />
        <div className="flex justify-between font-semibold">
          <span>Total</span>
          <span>${order!.total_amount.toFixed(2)}</span>
        </div>
        <div className="flex justify-between">
          <span>Delivery Estimate</span>
          <span>{calculateDeliveryEstimate()}</span>
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
                    <div className="grid gap-2">
                      <Label htmlFor="address">Address</Label>
                      <Input id="address" name="address" value={formData.address} onChange={handleInputChange} />
                    </div>
                  </div>
                </div>

                <Separator />

                <div>
                  <h2 className="text-xl font-semibold mb-4">Delivery Method</h2>
                  <RadioGroup
                    onValueChange={(value) => {
                      handleRadioChange("deliveryMethod", value)
                      handleRadioChange("deliveryLocationId", "")
                    }}
                    value={formData.deliveryMethod}
                  >
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="store_pickup" id="store_pickup" />
                      <Label htmlFor="store_pickup" className="flex items-center">
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
                  <div className="mt-4">
                    {formData.deliveryMethod === "delivery" && (
                      <Select
                        defaultValue={formData.deliveryLocationId.toString()}
                        onValueChange={(value) => handleRadioChange("deliveryLocationId", value)}
                      >
                        <SelectTrigger id="delivery-location">
                          <SelectValue placeholder="Select Delivery Location" />
                        </SelectTrigger>
                        <SelectContent>
                          {deliveryLocations.filter((location) => location.location_type === "city").map((location) => (
                            <SelectItem key={location.delivery_location_id} value={location.delivery_location_id.toString()}>
                              {location.location_name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    )}
                    {formData.deliveryMethod === "store_pickup" && (
                      <Select
                        defaultValue={formData.deliveryLocationId.toString()}
                        onValueChange={(value) => handleRadioChange("deliveryLocationId", value)}
                      >
                        <SelectTrigger id="store-location">
                          <SelectValue placeholder="Select Store Location" />
                        </SelectTrigger>
                        <SelectContent>
                          {deliveryLocations.filter((location) => location.location_type === "store").map((location) => (
                            <SelectItem key={location.delivery_location_id} value={location.delivery_location_id.toString()}>
                              {location.location_name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    )}
                  </div>
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
          <Button 
            onClick={submitOrder}
            className="w-full"
            disabled={!canPlaceOrder() || submitting}
          >
            {submitting ? "Placing Order..." : "Place Order"}
          </Button>
          {!canPlaceOrder() && (
            <p className="text-sm text-red-500">Please fill in all required fields</p>
          )}
        </div>
      </div>
    </div>
  )
}
