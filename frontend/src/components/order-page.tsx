'use client'

import { CalendarIcon, Package2Icon, CreditCardIcon } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"
import { Order } from "@/contexts/EcommerceContext"
import { useEffect, useState } from "react"
import Link from "next/link"
import { apiClient } from "@/services/axiosClient"
import { useAuth } from "@/contexts/AuthContext"

export function OrderPageComponent() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [orders, setOrders] = useState<Order[] | null>(null);
  const { user, isGuest, loading: loadingAuth } = useAuth();

  async function fetchOrders() {
    setLoading(true);
    try {
      const response = await apiClient.get(`/my-orders`);
      setOrders(response.data.orders);
      setLoading(false);
      setError(null);
    } catch (error) {
      setError("An error occurred while fetching the order");
      setLoading(false);
    }
  }

  useEffect(() => {
    if (user || isGuest()) {
      fetchOrders();
    }
  }, [user, loadingAuth]);

  if (error) {
    return (
      <div className="container mx-auto py-8 px-4">
        <Card>
          <CardContent className="flex flex-col items-center justify-center h-[50vh]">
            <Package2Icon className="h-16 w-16 text-muted-foreground mb-4" />
            <p className="text-xl font-semibold text-muted-foreground">{error}</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="container mx-auto py-8 px-4">
        <Card>
          <CardContent className="flex flex-col items-center justify-center h-[50vh]">
            <Package2Icon className="h-16 w-16 text-muted-foreground mb-4" />
            <p className="text-xl font-semibold text-muted-foreground">Loading...</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-8 min-h-[50vh] px-4">
      <h1 className="text-3xl font-bold mb-6">Your Orders</h1>
      {((orders?.length ?? 0) > 0) ? (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {orders!.map((order) => (
            <Card key={order.order_id} className="flex flex-col">
              <CardHeader>
                <CardTitle className="flex justify-between items-center">
                  <span>Order #{order.order_id}</span>
                  <Badge
                    variant={
                      order.order_status === "Processing"
                        ? "default"
                        : order.order_status === "Confirmed"
                          ? "secondary"
                          : order.order_status === "Failed"
                            ? "destructive"
                            : "outline"
                    }
                  >
                    {order.order_status}
                  </Badge>
                </CardTitle>
              </CardHeader>
              <CardContent className="flex-grow">
                <div className="flex items-center space-x-2 text-sm text-muted-foreground mb-4">
                  <CalendarIcon className="h-4 w-4" />
                  <span>Purchased On: {new Date(order.purchased_time).toLocaleDateString()} at {new Date(order.purchased_time).toLocaleTimeString()}</span>
                </div>
                {(order.order_status === "Confirmed" && order.delivery_estimate) && (
                  <div className="flex items-center space-x-2 text-sm text-muted-foreground mb-4">
                    <CalendarIcon className="h-4 w-4" />
                    <span>Estimated Arrival: {
                        new Date(
                          new Date(order.purchased_time).setDate(
                            new Date(order.purchased_time).getDate() + order.delivery_estimate
                          )
                        ).toLocaleDateString()
                      }
                    </span>
                  </div>
                )}
                <Separator className="my-4" />
                <div className="space-y-2">
                  {order.items.slice(0, 2).map((item, index) => (
                    <div key={index} className="flex justify-between">
                      <span>{item.product_name} ({item.variant_name})</span>
                      <span>x{item.quantity}</span>
                    </div>
                  ))}
                  {order.items.length > 2 && (
                    <div className="text-sm text-muted-foreground">
                      +{order.items.length - 2} more items
                    </div>
                  )}
                </div>
              </CardContent>
              <CardFooter className="flex justify-between items-center">
                <div className="flex items-center space-x-2">
                  <CreditCardIcon className="h-4 w-4 text-muted-foreground" />
                  <span className="font-semibold">${order.total_amount.toFixed(2)}</span>
                </div>
                {order.order_status === "Processing" ? (
                  <Link href={`/checkout/${order.order_id}`}>
                    <Button variant="destructive" size="sm">
                      Proceed to Payment
                    </Button>
                  </Link>
                ) : (
                  <div className="flex items-center space-x-2">
                    <Badge>
                      {order.delivery_method === "delivery" ? "Delivery" : "Pickup"}
                    </Badge>
                    <Badge>
                      {order.payment_method === "card" ? "Card" : "Cash"}
                    </Badge>
                  </div>
                )}
              </CardFooter>
            </Card>
          ))}
        </div>
      ) : (
        <Card>
          <CardContent className="flex flex-col items-center justify-center min-h-[50vh]">
            <Package2Icon className="h-16 w-16 text-muted-foreground mb-4" />
            <p className="text-xl font-semibold text-muted-foreground">No orders found</p>
            <Link href="/">
              <Button className="mt-4">
                Start Shopping
              </Button>
            </Link>
          </CardContent>
        </Card>
      )}
    </div>
  )
}