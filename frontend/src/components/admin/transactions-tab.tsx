'use client'

import { useEffect, useState } from 'react'
import { Input } from "@/components/ui/input"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { apiClient } from '@/services/axiosClient'

interface Transaction {
  user_id: number
  customer_name: string
  email: string
  order_id: number
  purchased_time: string
  order_status: string
  total_amount: number
  number_of_items: number
  variant_names: string
  total_quantity: number
  total_price: number
}

export function TransactionsTab() {
  const [searchTerm, setSearchTerm] = useState('')
  const [transactionData, setTransactionData] = useState<Transaction[]>([]);

  const filteredTransactions = transactionData.filter(transaction =>
    transaction.customer_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    transaction.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const fetchOrders = async () => {
    const orders = await apiClient.get('/customer-report').then(res => res.data);
    setTransactionData(orders.data);
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold mb-4">Transaction History</h2>
      <Input
        placeholder="Search transactions..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
      />
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[100px]">ID</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Customer</TableHead>
              <TableHead>Items</TableHead>
              <TableHead>Amount</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {transactionData.map((transaction) => (
              <TableRow key={transaction.order_id}>
                <TableCell className="font-medium">{transaction.order_id}</TableCell>
                <TableCell>{transaction.purchased_time}</TableCell>
                <TableCell>{transaction.customer_name}</TableCell>
                <TableCell>{transaction.number_of_items}</TableCell>
                <TableCell>${transaction.total_price.toFixed(2)}</TableCell>
                <TableCell>{transaction.order_status}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}