import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "shared-ui/components/ui/toaster";

export const metadata: Metadata = {
    title: "Zhigo Restaurant Dashboard",
    description: "Restaurant owner dashboard for managing your Zhigo restaurant",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en">
            <body className="antialiased">
                {children}
                <Toaster />
            </body>
        </html>
    );
}
