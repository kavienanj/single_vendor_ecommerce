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
import { apiClient } from '@/services/axiosClient';

interface Delivery {
  delivery_location_id: number;
  location_name: string;
  location_type: string;
  with_stock_delivery_days: number;
  without_stock_delivery_days: number;
}

export function DeliveriesTab() {
  const [searchTerm, setSearchTerm] = useState('');
  const [deliveryData, setDeliveryData] = useState<Delivery[]>([]);

  const filteredDeliveries = deliveryData.filter(delivery =>
    delivery.location_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    delivery.location_type.toLowerCase().includes(searchTerm.toLowerCase())
  )

  async function fetchDeliveries() {
    const deliveries = await apiClient.get('/delivery-locations');
    setDeliveryData(deliveries.data);
  }

  async function updateStockETA({
    delivery_location_id,
    with_stock_delivery_days,
  }: { delivery_location_id: number, with_stock_delivery_days: number; }) {
    await apiClient.put(`/delivery-locations/${delivery_location_id}`, {
      with_stock_delivery_days,
    });
    setDeliveryData(deliveryData.map(delivery => delivery.delivery_location_id === delivery_location_id
      ? { ...delivery, with_stock_delivery_days }
      : delivery));
  }

  async function updateNoStockETA({
    delivery_location_id,
    without_stock_delivery_days,
  }: { delivery_location_id: number, without_stock_delivery_days: number; }) {
    await apiClient.put(`/delivery-locations/${delivery_location_id}`, {
      without_stock_delivery_days,
    });
    setDeliveryData(deliveryData.map(delivery => delivery.delivery_location_id === delivery_location_id
      ? { ...delivery, without_stock_delivery_days }
      : delivery));
  }

  useEffect(() => {
    fetchDeliveries();
  }, []);

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
              <TableHead>Location</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Stock ETA</TableHead>
              <TableHead>No Stock ETA</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredDeliveries.map((delivery) => (
              <TableRow key={delivery.delivery_location_id}>
                <TableCell className="font-medium">{delivery.delivery_location_id}</TableCell>
                <TableCell>{delivery.location_name}</TableCell>
                <TableCell>{delivery.location_type}</TableCell>
                <TableCell>
                  <Input
                    type="number"
                    value={delivery.with_stock_delivery_days}
                    onChange={(e) => updateStockETA({
                      delivery_location_id: delivery.delivery_location_id,
                      with_stock_delivery_days: parseInt(e.target.value),
                    })}
                  />
                </TableCell>
                <TableCell>
                  <Input
                    type="number"
                    value={delivery.without_stock_delivery_days}
                    onChange={(e) => updateNoStockETA({
                      delivery_location_id: delivery.delivery_location_id,
                      without_stock_delivery_days: parseInt(e.target.value),
                    })}
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}