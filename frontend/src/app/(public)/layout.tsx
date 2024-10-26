import Footer from "@/components/footer";
import Header from "@/components/header";
import { EcommerceProvider } from "@/contexts/EcommerceContext";

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <div className="min-h-screen bg-gray-100 flex flex-col">
            <EcommerceProvider>
                <Header />
                {children}
                <Footer />
            </EcommerceProvider>
        </div>
    );
}
