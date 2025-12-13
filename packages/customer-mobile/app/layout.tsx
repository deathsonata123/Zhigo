import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Providers from "./providers";
// import { Header, Footer } from '@food-delivery/shared-ui'; // Temporarily disabled - contains Amplify

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Zhigo",
  description: "Order your favorite food",
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  // Also fixes the "notch" white bar on iPhones
  viewportFit: 'cover',
}


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
            {/* Header temporarily disabled - contains Amplify */}
            {/* <Header /> */}

            {/* Main content area */}
            <div className="flex-1">
              {children}
            </div>

            {/* Footer temporarily disabled */}
            {/* <Footer /> */}
          </div>
        </Providers>
      </body>
    </html>
  );
}