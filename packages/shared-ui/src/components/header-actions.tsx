'use client';

import Link from 'next/link';
import { ShoppingCart, User, LayoutDashboard, ShieldCheck, Bike, Code2 } from 'lucide-react';
import { Button } from './ui/button';
import { useEffect, useState, useRef } from 'react';
import { usePathname } from 'next/navigation';
import { LoginDialog } from './login-dialog';
import { SignupDialog } from './signup-dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu"
import { useToast } from '../hooks/use-toast';
import { Switch } from './ui/switch';
import { Label } from './ui/label';
import { cn } from '../lib/utils';
import { getCurrentUser, signOut, fetchAuthSession } from '../lib/auth';

import { OAuthHandler } from './oauth-handler';

// Rider status toggle component - only visible for riders
function RiderStatusToggle({ isRider, riderId }: { isRider: boolean; riderId: string | null }) {
  const { toast } = useToast();
  const [isOnline, setIsOnline] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);

  // Load initial online status when component mounts
  useEffect(() => {
    const loadRiderStatus = async () => {
      if (riderId) {
        try {
          const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
          const response = await fetch(`${apiUrl}/api/riders/${riderId}`);
          if (response.ok) {
            const rider = await response.json();
            setIsOnline(rider.isOnline || false);
          }
        } catch (error) {
          console.error('Error loading rider status:', error);
        }
      }
    };

    loadRiderStatus();
  }, [riderId]);

  const handleStatusChange = async (newStatus: boolean) => {
    if (!riderId) return;

    setIsUpdating(true);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      // Update rider's online status via Express.js API
      const response = await fetch(`${apiUrl}/api/riders/${riderId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isOnline: newStatus })
      });

      if (!response.ok) throw new Error('Failed to update status');

      setIsOnline(newStatus);
      toast({
        title: `You are now ${newStatus ? 'Online' : 'Offline'}`,
        description: newStatus
          ? 'You will start receiving job requests.'
          : 'You will not receive new job requests.',
      });
    } catch (error) {
      console.error('Error updating rider status:', error);
      toast({
        variant: 'destructive',
        title: 'Failed to update status',
        description: 'Please try again.',
      });
    } finally {
      setIsUpdating(false);
    }
  };

  if (!isRider) return null;

  return (
    <div className="flex items-center space-x-2">
      <Switch
        id="rider-status"
        checked={isOnline}
        onCheckedChange={handleStatusChange}
        disabled={isUpdating}
        aria-label="Rider online status"
      />
      <Label
        htmlFor="rider-status"
        className={cn(
          'font-medium',
          isOnline ? 'text-green-600' : 'text-muted-foreground'
        )}
      >
        {isOnline ? 'Online' : 'Offline'}
      </Label>
    </div>
  );
}

export function HeaderActions() {
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isSignupOpen, setIsSignupOpen] = useState(false);
  const [user, setUser] = useState<{ email: string; userId: string } | null>(null);
  const pathname = usePathname();
  const { toast } = useToast();

  // Track user roles dynamically
  const [isZhigoPartner, setIsZhigoPartner] = useState(false);
  const [isRider, setIsRider] = useState(false);
  const [riderId, setRiderId] = useState<string | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [isDeveloper, setIsDeveloper] = useState(false);
  const [developerId, setDeveloperId] = useState<string | null>(null);

  // Use ref to track polling interval
  const pollingIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Fetch user and check their roles on mount AND on route change
  useEffect(() => {
    // Check auth state immediately on mount
    fetchUserAndRoles();

    // Listen for auth events (including OAuth callbacks)
    const hubListener = Hub.listen('auth', async ({ payload }) => {
      // CRITICAL: Ignore tokenRefresh events to prevent spam
      if (payload.event === 'tokenRefresh') {
        return;
      }

      console.log('Auth Hub event received:', payload.event);

      switch (payload.event) {
        case 'signedIn':
          console.log('signedIn event - User signed in, fetching roles...');
          setTimeout(async () => {
            await fetchUserAndRoles();
            toast({
              title: 'Login successful',
              description: 'Welcome back!',
            });
          }, 500);
          break;

        case 'signInWithRedirect':
          console.log('signInWithRedirect event - OAuth callback detected');
          setTimeout(async () => {
            await fetchUserAndRoles();
            toast({
              title: 'Login successful',
              description: 'Welcome!',
            });

            const preAuthPath = sessionStorage.getItem('preAuthPath');
            if (preAuthPath && preAuthPath !== pathname) {
              sessionStorage.removeItem('preAuthPath');
              window.location.href = preAuthPath;
            }
          }, 1000);
          break;

        case 'signedOut':
          console.log('User signed out');
          setUser(null);
          setIsZhigoPartner(false);
          setIsRider(false);
          setRiderId(null);
          setIsAdmin(false);
          setIsDeveloper(false);
          setDeveloperId(null);
          break;

        case 'signInWithRedirect_failure':
          console.error('OAuth sign in failed:', payload.data);
          toast({
            title: 'Login failed',
            description: 'There was an error signing in with Google.',
            variant: 'destructive',
          });
          break;
      }
    });

    const checkOAuthRedirect = async () => {
      try {
        const session = await fetchAuthSession();
        if (session.tokens) {
          console.log('OAuth session detected on page load');
          await fetchUserAndRoles();
        }
      } catch (error) {
        console.log('No OAuth session on page load');
      }
    };

    const timeoutId = setTimeout(checkOAuthRedirect, 100);

    return () => {
      if (pollingIntervalRef.current) {
        clearInterval(pollingIntervalRef.current);
      }
      clearTimeout(timeoutId);
      hubListener();
    };
  }, [pathname]);

  const fetchUserAndRoles = async () => {
    console.log('[HeaderActions] Starting fetchUserAndRoles...');
    try {
      const session = await fetchAuthSession({ forceRefresh: true });
      console.log('[HeaderActions] Session check:', { hasTokens: !!session.tokens });

      if (!session.tokens) {
        throw new Error('No valid session');
      }

      console.log('[HeaderActions] Getting current user...');
      const currentUser = await getCurrentUser();
      console.log('[HeaderActions] Current user:', currentUser);

      // CRITICAL FIX: Google OAuth users don't have signInDetails.loginId
      // Get email from ID token instead
      const userEmail = currentUser?.signInDetails?.loginId ||
        session.tokens?.idToken?.payload?.email as string ||
        currentUser?.username;

      if (userEmail && currentUser?.userId) {
        console.log('[HeaderActions] ✅ User authenticated:', userEmail);

        setUser({
          email: userEmail,
          userId: currentUser.userId
        });

        console.log('[HeaderActions] User state set, checking roles...');

        await checkRestaurantOwner(currentUser.userId);
        await checkRider(currentUser.userId);
        await checkDeveloper(currentUser.userId);

        // Check admin from Cognito groups
        checkAdminFromGroups(session.tokens.idToken?.payload);

        console.log('[HeaderActions] ✅ All roles checked');
      } else {
        console.log('[HeaderActions] ⚠️ Could not extract email from user object');
      }
    } catch (error) {
      console.log('[HeaderActions] ❌ User not authenticated or session invalid:', error);
      setUser(null);
      setIsZhigoPartner(false);
      setIsRider(false);
      setRiderId(null);
      setIsAdmin(false);
      setIsDeveloper(false);
      setDeveloperId(null);

      if (pollingIntervalRef.current) {
        clearInterval(pollingIntervalRef.current);
        pollingIntervalRef.current = null;
      }
    }
  };

  const checkRestaurantOwner = async (userId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/restaurants?ownerId=${userId}`);

      if (!response.ok) throw new Error('Failed to fetch restaurants');

      const restaurants = await response.json();

      const hasApprovedRestaurant = restaurants?.some((r: any) => r.status === 'approved') || false;
      setIsZhigoPartner(hasApprovedRestaurant);

      const hasPendingRestaurant = restaurants?.some((r: any) => r.status === 'pending') || false;

      console.log('Restaurant check:', userId, 'Approved?', hasApprovedRestaurant, 'Pending?', hasPendingRestaurant);

      if (hasPendingRestaurant && !hasApprovedRestaurant) {
        if (pollingIntervalRef.current) {
          clearInterval(pollingIntervalRef.current);
        }

        pollingIntervalRef.current = setInterval(() => {
          console.log('Polling for restaurant approval...');
          checkRestaurantOwner(userId);
        }, 10000);
      } else if (hasApprovedRestaurant && pollingIntervalRef.current) {
        clearInterval(pollingIntervalRef.current);
        pollingIntervalRef.current = null;
        console.log('Restaurant approved! Stopping polling.');
      }
    } catch (error) {
      console.log('Error checking restaurant ownership:', error);
      setIsZhigoPartner(false);
    }
  };

  // Check if user is an approved rider
  const checkRider = async (userId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/riders?userId=${userId}`);

      if (!response.ok) throw new Error('Failed to fetch riders');

      const riders = await response.json();

      // User is a rider only if they have an approved rider account
      const approvedRider = riders?.find((r: any) => r.status === 'approved');
      const hasApprovedRider = !!approvedRider;
      setIsRider(hasApprovedRider);
      setRiderId(approvedRider?.id || null);

      console.log('Rider check:', userId, 'Has approved rider?', hasApprovedRider);
    } catch (error) {
      console.log('Error checking rider status:', error);
      setIsRider(false);
      setRiderId(null);
    }
  };

  // Check if user is an approved developer
  const checkDeveloper = async (userId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/developers?userId=${userId}`);

      if (!response.ok) throw new Error('Failed to fetch developers');

      const developers = await response.json();

      // User is a developer only if they have an approved developer account
      const approvedDeveloper = developers?.find((d: any) => d.status === 'approved');
      const hasApprovedDeveloper = !!approvedDeveloper;
      setIsDeveloper(hasApprovedDeveloper);
      setDeveloperId(approvedDeveloper?.id || null);

      console.log('Developer check:', userId, 'Has approved developer?', hasApprovedDeveloper);
    } catch (error) {
      console.log('Error checking developer status:', error);
      setIsDeveloper(false);
      setDeveloperId(null);
    }
  };

  // Check admin from Cognito groups in ID token
  const checkAdminFromGroups = (idTokenPayload: any) => {
    // Cognito groups are in the 'cognito:groups' claim
    const groups = idTokenPayload?.['cognito:groups'] || [];
    const isAdminUser = groups.includes('Admin');
    setIsAdmin(isAdminUser);
    console.log('Admin check from groups:', groups, 'Is admin?', isAdminUser);
  };

  const handleSignOut = async () => {
    try {
      if (pollingIntervalRef.current) {
        clearInterval(pollingIntervalRef.current);
        pollingIntervalRef.current = null;
      }

      await signOut({ global: true });

      setUser(null);
      setIsZhigoPartner(false);
      setIsRider(false);
      setRiderId(null);
      setIsAdmin(false);
      setIsDeveloper(false);
      setDeveloperId(null);

      if (typeof window !== 'undefined') {
        sessionStorage.clear();

        const keysToRemove: string[] = [];
        for (let i = 0; i < localStorage.length; i++) {
          const key = localStorage.key(i);
          if (key && key.startsWith('amplify')) {
            keysToRemove.push(key);
          }
        }
        keysToRemove.forEach(key => localStorage.removeItem(key));
      }

      toast({
        title: 'Signed out',
        description: 'You have been successfully signed out.',
      });

      setTimeout(() => {
        window.location.href = '/map';
      }, 500);
    } catch (error) {
      console.error('Sign out error:', error);
      toast({
        title: 'Sign out failed',
        description: 'There was an error signing out. Refreshing page...',
        variant: 'destructive',
      });

      setTimeout(() => {
        window.location.href = '/map';
      }, 1000);
    }
  };

  const handleLogin = async () => {
    await fetchUserAndRoles();
    setIsLoginOpen(false);
    setIsSignupOpen(false);
  };

  return (
    <>
      <OAuthHandler />

      <div className="flex items-center gap-4 bg-transparent">
        <RiderStatusToggle isRider={isRider} riderId={riderId} />

        <Button variant="outline" size="icon">
          <ShoppingCart className="h-5 w-5" />
          <span className="sr-only">Cart</span>
        </Button>

        {user ? (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="relative h-8 w-8 rounded-full">
                <User className="h-5 w-5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="w-56" align="end" forceMount>
              <DropdownMenuLabel className="font-normal">
                <div className="flex flex-col space-y-1">
                  <p className="text-sm font-medium">{user.email}</p>
                </div>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />

              <DropdownMenuItem asChild>
                <Link href="/profile" className="flex items-center">
                  <User className="mr-2 h-4 w-4" />
                  Profile
                </Link>
              </DropdownMenuItem>

              {isZhigoPartner && (
                <DropdownMenuItem asChild>
                  <Link href="/dashboard" className="flex items-center">
                    <LayoutDashboard className="mr-2 h-4 w-4" />
                    Restaurant Dashboard
                  </Link>
                </DropdownMenuItem>
              )}

              {isRider && (
                <DropdownMenuItem asChild>
                  <Link href="/rider" className="flex items-center">
                    <Bike className="mr-2 h-4 w-4" />
                    Rider Dashboard
                  </Link>
                </DropdownMenuItem>
              )}

              {isDeveloper && (
                <DropdownMenuItem asChild>
                  <Link href="/developer/dashboard" className="flex items-center">
                    <Code2 className="mr-2 h-4 w-4" />
                    Developer Dashboard
                  </Link>
                </DropdownMenuItem>
              )}

              {isAdmin && (
                <DropdownMenuItem asChild>
                  <Link href="/admin" className="flex items-center">
                    <ShieldCheck className="mr-2 h-4 w-4" />
                    Admin Panel
                  </Link>
                </DropdownMenuItem>
              )}

              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleSignOut}>Log out</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        ) : (
          <div className="flex items-center gap-2">
            <Button variant="outline" onClick={() => setIsLoginOpen(true)}>
              Login
            </Button>
            <Button onClick={() => setIsSignupOpen(true)}>Sign Up</Button>
          </div>
        )}

        <LoginDialog
          open={isLoginOpen}
          onOpenChange={setIsLoginOpen}
          onSwitchToSignup={() => {
            setIsLoginOpen(false);
            setIsSignupOpen(true);
          }}
          onLoginSuccess={handleLogin}
        />
        <SignupDialog
          open={isSignupOpen}
          onOpenChange={setIsSignupOpen}
          onSwitchToLogin={() => {
            setIsSignupOpen(false);
            setIsLoginOpen(true);
          }}
          onSignupSuccess={handleLogin}
        />
      </div>
    </>
  );
}
