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
import { AlertDialog, AlertDialogContent, AlertDialogHeader, AlertDialogTitle, AlertDialogDescription, AlertDialogFooter, AlertDialogCancel, AlertDialogAction } from "@/components/ui/alert-dialog"
import { Input } from "@/components/ui/input"
import { useEffect, useState } from 'react';
import { apiClient } from '@/services/axiosClient';

interface Variant {
  product_id: number;
  product_name: string;
  variant_id: number;
  name: string;
  price: number;
  image_url: string;
  quantity_available: number;
}

export function InventoryTab() {
	const [products, setProducts] = useState<Variant[]>([]);
  const [selectedVariant, setSelectedVariant] = useState<Variant | null>(null);
  const [selectedQuantity, setSelectedQuantity] = useState<number>(0);

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
              <TableRow key={item.variant_id} className={`${
                  item.quantity_available < 10 ? 
                    item.quantity_available < 1 ? 
                      'bg-red-200 hover:bg-red-200' 
                      : 'bg-yellow-200 hover:bg-yellow-200'
                    : ''
                  }`}>
                <TableCell className="font-medium">{item.variant_id}</TableCell>
                <TableCell>
                  {item.product_name} ({item.name})
                </TableCell>
                <TableCell>${item.price.toFixed(2)}</TableCell>
                <TableCell>
                  {item.quantity_available}
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
                      <DropdownMenuItem onClick={() => setSelectedVariant(item)}>
                        Add/Remove Stock
                      </DropdownMenuItem>
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
      <AlertDialog open={selectedVariant !== null} onOpenChange={() => {
        setSelectedVariant(null)
        setSelectedQuantity(0)
      }}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Add Stock</AlertDialogTitle>
            <AlertDialogDescription>
              <span className="font-semibold">Product:</span> {selectedVariant?.product_name}
              <br />
              <span className="font-semibold">Variant:</span> {selectedVariant?.name}
              <br />
              <span className="font-semibold">Current Stock:</span> {selectedVariant?.quantity_available}
              <br />
              <div className="flex items-center gap-2">
                <span className="font-semibold">Stock Quantity:</span>
                <Input
                  type="number"
                  value={selectedQuantity}
                  onChange={(e) => setSelectedQuantity(parseInt(e.target.value))}
                  className="w-16 p-1 text-right"
                />
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction className='bg-red-500' onClick={() => {
              updateVarientStock(
                selectedVariant!.variant_id, 
                // Ensure stock does not go below 0
                selectedVariant!.quantity_available - selectedQuantity < 0
                  ? 0
                  : selectedVariant!.quantity_available - selectedQuantity
              )
              setSelectedVariant(null)
              setSelectedQuantity(0)
            }}>
              Remove Stock
            </AlertDialogAction>
            <AlertDialogAction onClick={() => {
              updateVarientStock(selectedVariant!.variant_id, selectedVariant!.quantity_available + selectedQuantity)
              setSelectedVariant(null)
              setSelectedQuantity(0)
            }}>
              Add Stock
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
