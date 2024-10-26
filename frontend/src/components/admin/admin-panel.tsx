'use client'

import { useEffect, useState } from 'react'
import { Package, Users, CreditCard, Truck, BarChart } from 'lucide-react'
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { InventoryTab } from './inventory-tab'
import { UsersTab } from './users-tab'
import { TransactionsTab } from './transactions-tab'
import { DeliveriesTab } from './deliveries-tab'
import { ReportsTab } from './reports-tab'
import { useAuth } from '@/contexts/AuthContext'
import { redirect } from 'next/navigation'

export default function AdminPanel() {
  const { user, loading, logout, isAdmin } = useAuth();
  const [activeTab, setActiveTab] = useState('inventory')
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    if (!loading && !isAdmin()) {
      redirect('/')
    }
    if (isAdmin()) {
      setIsLoading(false)
    }
    console.log('user', user)
  }, [loading, user]);

  if (isLoading) {
    return <div className="container mx-auto py-8 px-4">Loading...</div>
  }

  const handleLogout = () => {
    logout();
    redirect('/sign-in');
  }

  return (
    <div className="container mx-auto py-8 px-4">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-bold">Admin Panel</h1>
        <Button onClick={handleLogout}>Logout</Button>
      </div>
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="inventory" className="flex items-center gap-2">
            <Package className="h-4 w-4" />
            <span className="hidden sm:inline">Inventory</span>
          </TabsTrigger>
          <TabsTrigger value="users" className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span className="hidden sm:inline">Users</span>
          </TabsTrigger>
          <TabsTrigger value="transactions" className="flex items-center gap-2">
            <CreditCard className="h-4 w-4" />
            <span className="hidden sm:inline">Transactions</span>
          </TabsTrigger>
          <TabsTrigger value="deliveries" className="flex items-center gap-2">
            <Truck className="h-4 w-4" />
            <span className="hidden sm:inline">Deliveries</span>
          </TabsTrigger>
          <TabsTrigger value="reports" className="flex items-center gap-2">
            <BarChart className="h-4 w-4" />
            <span className="hidden sm:inline">Reports</span>
          </TabsTrigger>
        </TabsList>
        <TabsContent value="inventory">
          <Card className="px-6 py-6 pb-8">
            <InventoryTab />
          </Card>
        </TabsContent>
        <TabsContent value="users">
          <Card className="px-6 py-6 pb-8">
            <UsersTab />
          </Card>
        </TabsContent>
        <TabsContent value="transactions">
          <Card className="px-6 py-6 pb-8">
            <TransactionsTab />
          </Card>
        </TabsContent>
        <TabsContent value="deliveries">
          <Card className="px-6 py-6 pb-8">
            <DeliveriesTab />
          </Card>
        </TabsContent>
        <TabsContent value="reports">
          <Card className="px-6 py-6 pb-8">
            <ReportsTab />
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
