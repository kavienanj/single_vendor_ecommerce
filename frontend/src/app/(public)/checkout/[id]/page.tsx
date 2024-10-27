import { CheckoutPageComponent } from "@/components/checkout-page";

export default function Checkout({ params }: { params: { id: string } }) {
  return (
    <CheckoutPageComponent checkoutId={parseInt(params.id)} />
  );
}
