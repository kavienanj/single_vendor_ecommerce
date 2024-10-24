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

const deliveryData = [
  { id: 'D001', date: '2023-05-15', customer: 'Alice Johnson', status: 'In Transit', eta: '2023-05-17' },
  { id: 'D002', date: '2023-05-14', customer: 'Bob Smith', status: 'Delivered', eta: '2023-05-16' },
  { id: 'D003', date: '2023-05-13', customer: 'Charlie Brown', status: 'Processing', eta: '2023-05-18' },
  { id: 'D004', date: '2023-05-12', customer: 'Diana Ross', status: 'In Transit', eta: '2023-05-15' },
  { id: 'D005', date: '2023-05-11', customer: 'Edward Norton', status: 'Delivered', eta: '2023-05-14' },
]

export function DeliveriesTab() {
  const [searchTerm, setSearchTerm] = useState('')

  const filteredDeliveries = deliveryData.filter(delivery =>
    delivery.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
    delivery.customer.toLowerCase().includes(searchTerm.toLowerCase()) ||
    delivery.status.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold mb-4">Delivery Tracking</h2>
      <Input
        placeholder="Search deliveries..."
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
              <TableHead>Status</TableHead>
              <TableHead>ETA</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredDeliveries.map((delivery) => (
              <TableRow key={delivery.id}>
                <TableCell className="font-medium">{delivery.id}</TableCell>
                <TableCell>{delivery.date}</TableCell>
                <TableCell>{delivery.customer}</TableCell>
                <TableCell>{delivery.status}</TableCell>
                <TableCell>{delivery.eta}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}