//src/components/header.tsx
'use client';

import Link from 'next/link';
import { UtensilsCrossed, Menu, X, ShoppingCart } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Sheet, SheetContent, SheetTrigger, SheetTitle, SheetDescription } from '../components/ui/sheet';
import { useState, useEffect } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { cn } from '../lib/utils';
import { HeaderActions } from './header-actions';
import { getCurrentUser, signOut } from '../lib/auth';

function PromoBanner() {
  const [isVisible, setIsVisible] = useState(true);
  const [hasRestaurant, setHasRestaurant] = useState(false);
  const [isChecking, setIsChecking] = useState(true);
  const pathname = usePathname();
  const isMapPage = pathname === '/map';

  useEffect(() => {
    checkUserRestaurant();
  }, []);

  const checkUserRestaurant = async () => {
    try {
      const user = await getCurrentUser();

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?ownerId=${user.userId}`);
      if (restaurantsRes.ok) {
        const restaurants = await restaurantsRes.json();
        if (restaurants && restaurants.length > 0) {
          setHasRestaurant(true);
        }
      }
    } catch (error) {
      console.log('User not authenticated or error checking restaurant:', error);
    } finally {
      setIsChecking(false);
    }
  };

  const shouldShowBanner = isVisible && !isMapPage && !isChecking && !hasRestaurant;

  if (!shouldShowBanner) {
    return null;
  }

  return (
    <div className="relative bg-primary/10 text-primary-foreground py-2 px-4 text-center text-sm flex items-center justify-center gap-4">
      <Button variant="link" asChild className="text-primary font-semibold underline-offset-4 hover:underline h-auto p-0">
        <Link href="/partner">Become a Zhigo Partner</Link>
      </Button>
      <button
        onClick={() => setIsVisible(false)}
        className="absolute top-1/2 right-4 -translate-y-1/2 text-primary/70 hover:text-primary transition-colors"
        aria-label="Dismiss banner"
      >
        <X className="h-4 w-4" />
      </button>
    </div>
  );
}

function RiderToggle({ rider, isOnline, onToggle }: {
  rider: any;
  isOnline: boolean;
  onToggle: () => void;
}) {
  return (
    <div className="flex items-center gap-3 bg-secondary/50 px-3 py-1.5 rounded-full border border-border">
      <span className="text-sm font-medium text-foreground">
        {isOnline ? 'Online' : 'Offline'}
      </span>
      <button
        onClick={onToggle}
        className={cn(
          "relative inline-flex h-5 w-9 items-center rounded-full transition-colors",
          isOnline ? 'bg-green-600' : 'bg-muted'
        )}
        role="switch"
        aria-checked={isOnline}
        aria-label={`Toggle rider status ${isOnline ? 'offline' : 'online'}`}
      >
        <span
          className={cn(
            "inline-block h-3.5 w-3.5 transform rounded-full bg-background transition-transform shadow-sm",
            isOnline ? 'translate-x-5' : 'translate-x-0.5'
          )}
        />
      </button>
    </div>
  );
}

export function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [user, setUser] = useState<any>(null);
  const [rider, setRider] = useState<any>(null);
  const [isOnline, setIsOnline] = useState(false);
  const [cartCount, setCartCount] = useState(0);
  const pathname = usePathname();
  const router = useRouter();

  const navLinks = [
    { href: '/restaurants', label: 'Restaurants' },
    { href: '/map', label: 'Map' },
  ];

  useEffect(() => {
    checkUser();
    updateCartCount();

    // Listen for cart updates
    const handleCartUpdate = () => updateCartCount();
    window.addEventListener('cartUpdated', handleCartUpdate);

    return () => window.removeEventListener('cartUpdated', handleCartUpdate);
  }, []);

  const checkUser = async () => {
    try {
      const currentUser = await getCurrentUser();
      setUser(currentUser);
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

      // Check if user is a rider
      const response = await fetch(`${apiUrl}/api/riders?userId=${currentUser.userId}`);
      if (response.ok) {
        const riders = await response.json();
        if (riders && riders.length > 0) {
          setRider(riders[0]);
          setIsOnline(riders[0].isOnline || false);
        }
      }
    } catch (error) {
      console.log('User not authenticated:', error);
    }
  };

  const updateCartCount = () => {
    try {
      const cartData = localStorage.getItem('cart');
      if (cartData) {
        const cart = JSON.parse(cartData);
        const count = cart.reduce((sum: number, item: any) => sum + (item.quantity || 1), 0);
        setCartCount(count);
      } else {
        setCartCount(0);
      }
    } catch (error) {
      console.error('Error reading cart:', error);
      setCartCount(0);
    }
  };

  const handleToggleOnline = async () => {
    if (!rider) return;

    try {
      const newStatus = !isOnline;
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

      // Update rider status via Express.js API
      const response = await fetch(`${apiUrl}/api/riders/${rider.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isOnline: newStatus })
      });

      if (!response.ok) throw new Error('Failed to update rider status');

      setIsOnline(newStatus);

      // Dispatch custom event for dashboard to listen
      window.dispatchEvent(new CustomEvent('riderStatusChanged', {
        detail: { isOnline: newStatus }
      }));
    } catch (error) {
      console.error('Error toggling online status:', error);
    }
  };

  const handleSignOut = async () => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      // Set rider offline before signing out
      if (rider) {
        await fetch(`${apiUrl}/api/riders/${rider.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ isOnline: false })
        });
      }

      await signOut();
      router.push('/');
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  return (
    <>
      <header className="sticky top-0 z-50 w-full border-b bg-card/95 backdrop-blur-sm" style={{ '--header-height': '64px' } as React.CSSProperties}>
        <PromoBanner />
        <div className="container flex h-16 items-center justify-between px-4">
          <Link href="/" className="flex items-center gap-2 font-bold text-lg text-primary">
            <UtensilsCrossed className="h-6 w-6" />
            <span className="font-headline">Zhigo</span>
          </Link>

          <nav className="hidden md:flex items-center gap-6 text-sm font-medium">
            {navLinks.map(link => (
              <Link
                key={link.href}
                href={link.href}
                className={cn(
                  "transition-colors hover:text-primary",
                  pathname === link.href ? "text-primary" : "text-muted-foreground"
                )}
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div className="hidden md:flex items-center gap-4">
            {/* Cart Button */}
            {!rider && (
              <Button
                variant="outline"
                size="icon"
                className="relative"
                onClick={() => router.push('/checkout')}
              >
                <ShoppingCart className="h-5 w-5" />
                {cartCount > 0 && (
                  <span className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-primary text-primary-foreground text-xs flex items-center justify-center font-semibold">
                    {cartCount > 9 ? '9+' : cartCount}
                  </span>
                )}
              </Button>
            )}

            {/* Rider Toggle */}
            {rider && (
              <RiderToggle
                rider={rider}
                isOnline={isOnline}
                onToggle={handleToggleOnline}
              />
            )}

            {/* User Actions */}
            {user ? (
              <div className="flex items-center gap-3">
                <span className="text-sm text-muted-foreground truncate max-w-[150px]">
                  {user.signInDetails?.loginId || 'User'}
                </span>
                <Button
                  onClick={handleSignOut}
                  variant="outline"
                  size="sm"
                >
                  Sign Out
                </Button>
              </div>
            ) : (
              <HeaderActions />
            )}
          </div>

          <div className="md:hidden flex items-center gap-2">
            {/* Mobile Cart Button */}
            {!rider && (
              <Button
                variant="outline"
                size="icon"
                className="relative"
                onClick={() => router.push('/checkout')}
              >
                <ShoppingCart className="h-5 w-5" />
                {cartCount > 0 && (
                  <span className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-primary text-primary-foreground text-xs flex items-center justify-center font-semibold">
                    {cartCount > 9 ? '9+' : cartCount}
                  </span>
                )}
              </Button>
            )}

            {!user && <HeaderActions />}

            <Sheet open={isMenuOpen} onOpenChange={setIsMenuOpen}>
              <SheetTrigger asChild>
                <Button variant="outline" size="icon">
                  <Menu className="h-5 w-5" />
                  <span className="sr-only">Open menu</span>
                </Button>
              </SheetTrigger>
              <SheetContent side="right">
                <SheetTitle className="sr-only">Main Menu</SheetTitle>
                <SheetDescription className="sr-only">
                  Navigation links for the application.
                </SheetDescription>
                <div className="flex flex-col gap-6 p-6">
                  <Link href="/map" className="flex items-center gap-2 font-bold text-lg text-primary" onClick={() => setIsMenuOpen(false)}>
                    <UtensilsCrossed className="h-6 w-6" />
                    <span className="font-headline">Zhigo</span>
                  </Link>

                  {/* Rider Toggle in Mobile Menu */}
                  {rider && (
                    <div className="pb-4 border-b">
                      <p className="text-sm text-muted-foreground mb-2">Rider Status</p>
                      <RiderToggle
                        rider={rider}
                        isOnline={isOnline}
                        onToggle={handleToggleOnline}
                      />
                    </div>
                  )}

                  {/* User Info in Mobile Menu */}
                  {user && (
                    <div className="pb-4 border-b">
                      <p className="text-sm text-muted-foreground mb-2">Signed in as</p>
                      <p className="text-sm font-medium truncate">
                        {user.signInDetails?.loginId || 'User'}
                      </p>
                    </div>
                  )}

                  <nav className="flex flex-col gap-4 text-lg">
                    {navLinks.map(link => (
                      <Link
                        key={link.href}
                        href={link.href}
                        className={cn(
                          "transition-colors hover:text-primary",
                          pathname === link.href ? "text-primary" : "text-foreground"
                        )}
                        onClick={() => setIsMenuOpen(false)}
                      >
                        {link.label}
                      </Link>
                    ))}

                    {/* Rider Dashboard Link */}
                    {rider && (
                      <Link
                        href="/rider/dashboard"
                        className={cn(
                          "transition-colors hover:text-primary",
                          pathname === '/rider/dashboard' ? "text-primary" : "text-foreground"
                        )}
                        onClick={() => setIsMenuOpen(false)}
                      >
                        Dashboard
                      </Link>
                    )}
                  </nav>

                  {/* Sign Out Button in Mobile Menu */}
                  {user && (
                    <Button
                      onClick={() => {
                        handleSignOut();
                        setIsMenuOpen(false);
                      }}
                      variant="outline"
                      className="mt-auto"
                    >
                      Sign Out
                    </Button>
                  )}
                </div>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </header>
    </>
  );
}
