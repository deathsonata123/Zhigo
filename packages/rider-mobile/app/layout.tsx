import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Providers from "./providers";
import { Header, Footer } from '@food-delivery/shared-ui'; 

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Zhigo Food Delivery",
  description: "Order your favorite food",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>
          <div className="flex min-h-screen flex-col">
            {/* Header stays at the top */}
            <Header /> 
            
            {/* Main content area with padding-top to account for fixed header */}
            <div className="flex-1 pt-16"> 
              {children}
            </div>

            {/* Footer stays at the bottom */}
            <Footer />
          </div>
        </Providers>
      </body>
    </html>
  );
}