import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Zhigo Admin Dashboard",
  description: "Admin dashboard for managing Zhigo platform",
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
      </body>
    </html>
  );
}
