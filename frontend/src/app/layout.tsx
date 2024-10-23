import type { Metadata } from "next";
import { Poppins } from "next/font/google";
import "./globals.css";
import Footer from "@/components/footer";
import Header from "@/components/header";
import { EcommerceProvider } from "@/contexts/EcommerceContext";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700", "800"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "My Ecommerce",
  description: "A simple ecommerce website",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={poppins.className}>
        <EcommerceProvider> 
          <div className="min-h-screen bg-gray-100 flex flex-col">
            <Header />
            {children}
            <Footer />
          </div>
        </EcommerceProvider>
      </body>
    </html>
  );
}
