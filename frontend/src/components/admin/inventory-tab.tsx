import { Plus, MoreHorizontal } from 'lucide-react'
import { Button } from "@/components/ui/button"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Input } from "@/components/ui/input"
import { useEffect, useState } from 'react';
import { apiClient } from '@/services/axiosClient';

interface Variant {
  product_id: number;
  variant_id: number;
  name: string;
  price: number;
  image_url: string;
  quantity_available: number;
}

export function InventoryTab() {
	const [products, setProducts] = useState<Variant[]>([]);

	const fetchProducts = async () => {
		const fetchedProducts = await apiClient.get('/variant/').then(res => res.data);
		setProducts(fetchedProducts);
	};

  const updateVarientStock = async (variantId: number, quantity: number) => {
    await apiClient.post(`/variant/${variantId}/stock`, {
      quantity
    });
    setProducts(products.map(product => product.variant_id === variantId 
      ? { ...product, quantity_available: quantity }
      : product));
  }

  useEffect(() => {
    fetchProducts();
  }, []);

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">Inventory Management</h2>
        <Button className="flex items-center gap-2">
          <Plus className="h-4 w-4" />
          Add Item
        </Button>
      </div>
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[100px]">Varient ID</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Price</TableHead>
              <TableHead>Stock</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {products.map((item) => (
              <TableRow key={item.variant_id}>
                <TableCell className="font-medium">{item.variant_id}</TableCell>
                <TableCell>{item.name}</TableCell>
                <TableCell>${item.price.toFixed(2)}</TableCell>
                <TableCell>
                  <Input
                    type="number"
                    value={item.quantity_available}
                    onChange={(e) => updateVarientStock(item.variant_id, parseInt(e.target.value))}
                    className="w-16 p-1 text-right"
                  />
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" className="h-8 w-8 p-0">
                        <span className="sr-only">Open menu</span>
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuLabel>Actions</DropdownMenuLabel>
                      <DropdownMenuItem>Edit</DropdownMenuItem>
                      <DropdownMenuItem>View details</DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem>Delete</DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
