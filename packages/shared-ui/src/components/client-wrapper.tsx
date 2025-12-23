'use client';

import { useEffect } from 'react';
import { Header } from './header';
import { Footer } from './footer';
import { Button } from './ui/button';
import { MessageSquare } from 'lucide-react';
import { usePathname, useRouter } from 'next/navigation';


// This component handles the layout for the client side.

export default function ClientWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  // Safe check for pathname availability
  const isMapPage = pathname === '/map';

  useEffect(() => {
    // Redirect handling is now managed by the OAuth provider and lib/auth.ts
  }, [router]);

  return (
    <>
      {isMapPage ? (
        <main>{children}</main>
      ) : (
        <div className="flex flex-col min-h-screen">
          <Header />
          <main className="flex-grow">{children}</main>
          <Footer />
        </div>
      )}

      {!isMapPage && (
        <Button
          className="fixed bottom-8 right-8 h-14 w-14 rounded-full shadow-lg"
          size="icon"
        >
          <MessageSquare className="h-6 w-6" />
          <span className="sr-only">Open Chat</span>
        </Button>
      )}
    </>
  );
}
