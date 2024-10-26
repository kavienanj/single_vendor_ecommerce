'use client'

import { useState } from 'react'
import { Input } from "@/components/ui/input"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

const transactionData = [
  { id: 'T001', date: '2023-05-15', customer: 'Alice Johnson', amount: 150.00, status: 'Completed' },
  { id: 'T002', date: '2023-05-14', customer: 'Bob Smith', amount: 75.50, status: 'Pending' },
  { id: 'T003', date: '2023-05-13', customer: 'Charlie Brown', amount: 200.00, status: 'Completed' },
  { id: 'T004', date: '2023-05-12', customer: 'Diana Ross', amount: 50.00, status: 'Failed' },
  { id: 'T005', date: '2023-05-11', customer: 'Edward Norton', amount: 125.75, status: 'Completed' },
]

export function TransactionsTab() {
  const [searchTerm, setSearchTerm] = useState('')

  const filteredTransactions = transactionData.filter(transaction =>
    transaction.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
    transaction.customer.toLowerCase().includes(searchTerm.toLowerCase()) ||
    transaction.status.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
              <TableHead>Amount</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredTransactions.map((transaction) => (
              <TableRow key={transaction.id}>
                <TableCell className="font-medium">{transaction.id}</TableCell>
                <TableCell>{transaction.date}</TableCell>
                <TableCell>{transaction.customer}</TableCell>
                <TableCell>${transaction.amount.toFixed(2)}</TableCell>
                <TableCell>{transaction.status}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}