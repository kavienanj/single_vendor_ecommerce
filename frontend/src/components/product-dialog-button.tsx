"use client";

import { Plus, Minus } from "lucide-react";
import { Product, useEcommerce, Variant } from "@/contexts/EcommerceContext";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { useEffect, useState } from "react";
import Link from "next/link";

type ProductAttributeValues = { [key: string]: string[] }

export function ProductDialogButton({ product }: { product: Product }) {
  const [loading, setLoading] = useState(true);
  const [variants, setVariants] = useState<Variant[]>([]);
  const [selectedVariant, setSelectedVariant] = useState<Variant | null>(null);
  const [selectedAttributes, setSelectedAttributes] = useState<{ [key: string]: string }>({});
  const { fetchProductWithVariants, addToCart, cart } = useEcommerce();
  const [quantity, setQuantity] = useState(1)

  const getProductAttributeValues = () => {
    const attributeValues: ProductAttributeValues = {}
    variants.forEach(variant => {
      variant.attributes.forEach(attribute => {
        if (!attributeValues[attribute.attribute_name]) {
          attributeValues[attribute.attribute_name] = []
        }
        const values = attributeValues[attribute.attribute_name];
        if (!values.includes(attribute.attribute_value.toString())) {
          values.push(attribute.attribute_value.toString())
        }
      })
    })
    return attributeValues;
  }

  const loadVariants = async () => {
    setLoading(true)
    const productVarients = await fetchProductWithVariants(product.product_id)
    setVariants(productVarients.variants)
    const selectedAttributes: { [key: string]: string } = {}
    productVarients.variants[0].attributes.forEach(attribute => {
      selectedAttributes[attribute.attribute_name] = attribute.attribute_value.toString()
    })
    for (const variant of productVarients.variants) {
      if (isInCart(variant.variant_id)) {
        variant.attributes.forEach(attribute => {
          selectedAttributes[attribute.attribute_name] = attribute.attribute_value.toString()
        });
        setSelectedVariant(variant)
        setQuantity(cart.find(item => item.variant_id === variant.variant_id)!.quantity)
        break
      }
    }
    setSelectedAttributes(selectedAttributes)
    setLoading(false)
  }

  const isInCart = (varientId: number) => {
    return cart.some(item => item.variant_id === varientId)
  }

  useEffect(() => {
    if (variants.length > 0) {
      const selectedVariant = variants.find(variant => {
        return variant.attributes.every(attribute => {
          return selectedAttributes[attribute.attribute_name] === attribute.attribute_value.toString()
        })
      })
      setSelectedVariant(selectedVariant || null)
      if (selectedVariant && isInCart(selectedVariant.variant_id)) {
        setQuantity(cart.find(item => item.variant_id === selectedVariant.variant_id)!.quantity)
      } else {
        setQuantity(1)
      }
    }
  }, [selectedAttributes])

  useEffect(() => {
    setLoading(true)
  }, [product])

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button
          className="w-full"
          onClick={async () => {
            await loadVariants();
          }}
        >
          Add to Cart
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{product.product_name}</DialogTitle>
          <DialogDescription>
            Customize your product and add it to your cart.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-2 items-center gap-4">

            <img
              src={product.image_url}
              alt={product.product_name}
              className="w-full h-48 object-cover rounded-md"
            />
            <div>
              <p className="text-sm text-gray-600">SKU: {product.sku}</p>
              <p className="text-sm text-gray-600">Weight: {product.weight}</p>
              <p className="text-sm text-gray-600">{product.categories.join(", ")}</p>
              <p className="text-lg font-bold mt-2">${product.price}</p>
            </div>
          </div>
          {getProductAttributeValues() && (
            <>
              {Object.entries(getProductAttributeValues()).map(([attribute, values]) => (
                <div key={attribute}>
                  <h4 className="text-sm font-medium mb-1">{attribute}</h4>
                  <div className="grid grid-cols-3 gap-2">
                    {values.map((value) => (
                      <Button
                        key={value}
                        variant={ selectedAttributes[attribute] === value
                          ? "default"
                          : "outline"
                        }
                        onClick={() => setSelectedAttributes(attributes => ({ ...attributes, [attribute]: value }))}
                      >
                        {value}
                      </Button>
                    ))}
                  </div>
                </div>
              ))}
            </>
          )}
          <div className="flex items-center justify-between">
            <span>Quantity:</span>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="icon"
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
              >
                <Minus className="h-4 w-4" />
              </Button>
              <span>{quantity}</span>
              <Button
                variant="outline"
                size="icon"
                onClick={() => setQuantity(quantity + 1)}
              >
                <Plus className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>
        <div className="flex flex-col gap-2 w-full">
          {selectedVariant ? (
            <Button 
              onClick={() => addToCart(selectedVariant, quantity)} 
              className="w-full"
              disabled={
                isInCart(selectedVariant.variant_id) && 
                quantity === cart.find(item => item.variant_id === selectedVariant.variant_id)!.quantity
              }
            >
              {isInCart(selectedVariant.variant_id) ? "Update Cart" : "Add to Cart"}
            </Button>
          ) : (
            <Button disabled className="w-full">
              Not Available
            </Button>
          )}
          {selectedVariant && isInCart(selectedVariant.variant_id) ? (
            <Link href="/my-cart">
              <Button variant="link" className="w-full" disabled={loading || !selectedVariant}>
                View in Cart
              </Button>
            </Link>
          ) : (
            <Button variant="outline" className="w-full" disabled={loading || !selectedVariant}>
              Buy Now
            </Button>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}
