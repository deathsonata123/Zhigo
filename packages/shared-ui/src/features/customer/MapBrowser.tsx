// src/app/map/page.tsx
'use client';

import { useEffect, useRef, useState } from 'react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import Link from 'next/link';
import { Button } from '../../components/ui/button';
import { UtensilsCrossed, Navigation, User, ShoppingCart, LayoutDashboard, Bike, ShieldCheck, Sun, Moon, Sunset, Sunrise, Code2 } from 'lucide-react';
import { getCurrentUser, signOut, fetchAuthSession } from '../../lib/auth';
import { LoginDialog } from '../../components/login-dialog';
import { SignupDialog } from '../../components/signup-dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../../components/ui/dropdown-menu";

mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN || '';


// ADMIN EMAIL - Only this user can access admin panel
const ADMIN_EMAIL = "khanzayed197@gmail.com";

// Lighting presets for different times of day
const LIGHTING_PRESETS = {
  day: { label: 'Day', icon: Sun },
  dawn: { label: 'Dawn', icon: Sunrise },
  dusk: { label: 'Dusk', icon: Sunset },
  night: { label: 'Night', icon: Moon }
};

function MapSidebar({ onLightingChange }: { onLightingChange: (preset: keyof typeof LIGHTING_PRESETS) => void }) {
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isSignupOpen, setIsSignupOpen] = useState(false);
  const [user, setUser] = useState<{ email: string; userId: string } | null>(null);
  const [currentLighting, setCurrentLighting] = useState<keyof typeof LIGHTING_PRESETS>('day');

  // Track user roles dynamically
  const [isZhigoPartner, setIsZhigoPartner] = useState(false);
  const [isRider, setIsRider] = useState(false);
  const [riderId, setRiderId] = useState<string | null>(null);
  const [isDeveloper, setIsDeveloper] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);

  // Fetch user and check their roles on mount
  useEffect(() => {
    fetchUserAndRoles();
  }, []);

  // Function to fetch user and check all their roles
  const fetchUserAndRoles = async () => {
    try {
      const session = await fetchAuthSession({ forceRefresh: true });

      if (!session.tokens) {
        throw new Error('No valid session');
      }

      const currentUser = await getCurrentUser();

      // CRITICAL: Get email from token for Google OAuth users
      const userEmail = currentUser?.signInDetails?.loginId ||
        session.tokens?.idToken?.payload?.email as string ||
        currentUser?.username;

      if (userEmail && currentUser?.userId) {
        setUser({
          email: userEmail,
          userId: currentUser.userId
        });

        // Check if user owns an approved restaurant
        await checkRestaurantOwner(currentUser.userId);

        // Check if user is an approved rider
        await checkRider(currentUser.userId);

        // Check if user is an approved developer
        await checkDeveloper(currentUser.userId);

        // Check if user is admin
        checkAdmin(userEmail);
      }
    } catch {
      // User not authenticated
      setUser(null);
      setIsZhigoPartner(false);
      setIsRider(false);
      setRiderId(null);
      setIsDeveloper(false);
      setIsAdmin(false);
    }
  };

  // Check if user owns a restaurant by querying the Restaurant model
  const checkRestaurantOwner = async (userId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?ownerId=${userId}`);

      if (restaurantsRes.ok) {
        const restaurants = await restaurantsRes.json();
        const hasApprovedRestaurant = restaurants?.some((r: any) => r.status === 'approved') || false;
        setIsZhigoPartner(hasApprovedRestaurant);

        console.log('Restaurant check (Map):', userId, 'Has approved restaurant?', hasApprovedRestaurant);
      } else {
        setIsZhigoPartner(false);
      }
    } catch (error) {
      console.log('Error checking restaurant ownership:', error);
      setIsZhigoPartner(false);
    }
  };

  // Check if user is an approved rider
  const checkRider = async (userId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      const ridersRes = await fetch(`${apiUrl}/api/riders?userId=${userId}`);

      if (ridersRes.ok) {
        const riders = await ridersRes.json();
        const approvedRider = riders?.find((r: any) => r.status === 'approved');
        const hasApprovedRider = !!approvedRider;
        setIsRider(hasApprovedRider);
        setRiderId(approvedRider?.id || null);

        console.log('Rider check (Map):', userId, 'Has approved rider?', hasApprovedRider);
      } else {
        setIsRider(false);
        setRiderId(null);
      }
    } catch (error) {
      console.log('Error checking rider status:', error);
      setIsRider(false);
      setRiderId(null);
    }
  };

  // Check if user is an approved developer
  const checkDeveloper = async (userId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      const developersRes = await fetch(`${apiUrl}/api/developers?userId=${userId}`);

      if (developersRes.ok) {
        const developers = await developersRes.json();
        const approvedDeveloper = developers?.find((d: any) => d.status === 'approved');
        const hasApprovedDeveloper = !!approvedDeveloper;
        setIsDeveloper(hasApprovedDeveloper);

        console.log('Developer check (Map):', userId, 'Has approved developer?', hasApprovedDeveloper);
      } else {
        setIsDeveloper(false);
      }
    } catch (error) {
      console.log('Error checking developer status:', error);
      setIsDeveloper(false);
    }
  };

  // Check if user is admin - synchronous check against admin email
  const checkAdmin = (email: string) => {
    const isAdminUser = email === ADMIN_EMAIL;
    setIsAdmin(isAdminUser);
    console.log('Admin check (Map):', email, 'Is admin?', isAdminUser);
  };

  // Handle user sign out
  const handleSignOut = async () => {
    await signOut({ global: true });
    setUser(null);
    setIsZhigoPartner(false);
    setIsRider(false);
    setRiderId(null);
    setIsDeveloper(false);
    setIsAdmin(false);
  };

  // Refresh user data after successful login/signup
  const handleLoginSuccess = async () => {
    await fetchUserAndRoles();
    setIsLoginOpen(false);
    setIsSignupOpen(false);
  };

  // Handle lighting preset change
  const handleLightingChange = (preset: keyof typeof LIGHTING_PRESETS) => {
    setCurrentLighting(preset);
    onLightingChange(preset);
  };

  return (
    <>
      {/* Vertical sidebar with circular icon buttons */}
      <div className="fixed right-6 top-1/2 -translate-y-1/2 z-20 flex flex-col gap-3">

        {/* Restaurants navigation button */}
        <Button
          variant="ghost"
          size="icon"
          asChild
          className="bg-transparent backdrop-blur-sm hover:bg-white/10 shadow-lg h-12 w-12 rounded-full text-blue"
        >
          <Link href="/restaurants">
            <UtensilsCrossed className="h-6 w-6" />
            <span className="sr-only">Restaurants</span>
          </Link>
        </Button>

        {/* Map navigation button */}
        <Button
          variant="ghost"
          size="icon"
          asChild
          className="bg-transparent backdrop-blur-sm hover:bg-white/10 shadow-lg h-12 w-12 rounded-full text-blue"
        >
          <Link href="/map">
            <Navigation className="h-6 w-6" />
            <span className="sr-only">Map</span>
          </Link>
        </Button>

        {/* Visual divider */}
        <div className="h-px bg-white/30 mx-2" />

        {/* Time of Day Selector */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="bg-transparent backdrop-blur-sm hover:bg-white/10 shadow-lg h-12 w-12 rounded-full text-blue"
            >
              {(() => {
                const Icon = LIGHTING_PRESETS[currentLighting].icon;
                return <Icon className="h-6 w-6" />;
              })()}
              <span className="sr-only">Time of Day</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-40">
            <DropdownMenuLabel>Time of Day</DropdownMenuLabel>
            <DropdownMenuSeparator />
            {Object.entries(LIGHTING_PRESETS).map(([key, { label, icon: Icon }]) => (
              <DropdownMenuItem
                key={key}
                onClick={() => handleLightingChange(key as keyof typeof LIGHTING_PRESETS)}
                className={currentLighting === key ? 'bg-accent' : ''}
              >
                <Icon className="mr-2 h-4 w-4" />
                {label}
              </DropdownMenuItem>
            ))}
          </DropdownMenuContent>
        </DropdownMenu>

        {/* Shopping cart button */}
        <Button
          variant="ghost"
          size="icon"
          className="bg-transparent backdrop-blur-sm hover:bg-white/10 shadow-lg h-12 w-12 rounded-full text-blue"
        >
          <ShoppingCart className="h-6 w-6" />
          <span className="sr-only">Cart</span>
        </Button>

        {/* User profile button with authentication logic */}
        {user ? (
          // Show dropdown menu for authenticated users
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="bg-transparent backdrop-blur-sm hover:bg-white/10 shadow-lg h-12 w-12 rounded-full text-blue"
              >
                <User className="h-6 w-6" />
                <span className="sr-only">Profile</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              {/* Display user email */}
              <DropdownMenuLabel>{user.email}</DropdownMenuLabel>
              <DropdownMenuSeparator />

              {/* Profile link - always visible for authenticated users */}
              <DropdownMenuItem asChild>
                <Link href="/profile" className="flex items-center">
                  <User className="mr-2 h-4 w-4" />
                  Profile
                </Link>
              </DropdownMenuItem>

              {/* Restaurant Dashboard - only visible if user has approved restaurant */}
              {isZhigoPartner && (
                <DropdownMenuItem asChild>
                  <Link href="/dashboard" className="flex items-center">
                    <LayoutDashboard className="mr-2 h-4 w-4" />
                    Restaurant Dashboard
                  </Link>
                </DropdownMenuItem>
              )}

              {/* Rider Dashboard - only visible if user is an approved rider */}
              {isRider && (
                <DropdownMenuItem asChild>
                  <Link href="/rider" className="flex items-center">
                    <Bike className="mr-2 h-4 w-4" />
                    Rider Dashboard
                  </Link>
                </DropdownMenuItem>
              )}

              {/* Developer Dashboard - only visible if user is an approved developer */}
              {isDeveloper && (
                <DropdownMenuItem asChild>
                  <Link href="/developer" className="flex items-center">
                    <Code2 className="mr-2 h-4 w-4" />
                    Developer Dashboard
                  </Link>
                </DropdownMenuItem>
              )}

              {/* Admin Panel - only visible if user email matches admin email */}
              {isAdmin && (
                <DropdownMenuItem asChild>
                  <Link href="/admin" className="flex items-center">
                    <ShieldCheck className="mr-2 h-4 w-4" />
                    Admin Panel
                  </Link>
                </DropdownMenuItem>
              )}

              <DropdownMenuSeparator />
              {/* Sign out option */}
              <DropdownMenuItem onClick={handleSignOut}>Log out</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        ) : (
          // Show signup button for non-authenticated users
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setIsSignupOpen(true)}
            className="bg-transparent backdrop-blur-sm hover:bg-white/10 shadow-lg h-12 w-12 rounded-full text-blue"
          >
            <User className="h-6 w-6" />
            <span className="sr-only">Sign Up / Login</span>
          </Button>
        )}
      </div>

      {/* Authentication modals */}
      <LoginDialog
        open={isLoginOpen}
        onOpenChange={setIsLoginOpen}
        onSwitchToSignup={() => {
          setIsLoginOpen(false);
          setIsSignupOpen(true);
        }}
        onLoginSuccess={handleLoginSuccess}
      />
      <SignupDialog
        open={isSignupOpen}
        onOpenChange={setIsSignupOpen}
        onSwitchToLogin={() => {
          setIsSignupOpen(false);
          setIsLoginOpen(true);
        }}
        onSignupSuccess={handleLoginSuccess}
      />
    </>
  );
}

export default function MapPage() {
  const mapContainerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<mapboxgl.Map | null>(null);

  useEffect(() => {
    if (!mapContainerRef.current) return;

    // Use streets-v12 with proper configuration
    mapRef.current = new mapboxgl.Map({
      container: mapContainerRef.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [90.4125, 23.8103],
      zoom: 16,
      pitch: 70,
      bearing: -17.6,
      antialias: true,
      attributionControl: false,
    });

    const map = mapRef.current;

    map.on('load', () => {
      console.log('Map loaded');

      // Add terrain
      map.addSource('mapbox-dem', {
        type: 'raster-dem',
        url: 'mapbox://mapbox.mapbox-terrain-dem-v1',
        tileSize: 512,
        maxzoom: 14
      });

      map.setTerrain({
        source: 'mapbox-dem',
        exaggeration: 1.5
      });

      // Keep road labels, hide POI labels, and make buildings solid
      setTimeout(() => {
        const style = map.getStyle();
        if (style && style.layers) {
          style.layers.forEach(layer => {
            // Hide POI and place labels only (not road labels)
            if (layer.type === 'symbol' && layer.id) {
              // Keep road labels visible
              if (layer.id.includes('road') ||
                layer.id.includes('street') ||
                layer.id.includes('highway') ||
                layer.id.includes('path') ||
                layer.id.includes('label-road')) {
                // Keep road labels visible
                console.log('Keeping visible:', layer.id);
              } else {
                // Hide POI, place, and other labels
                try {
                  map.setLayoutProperty(layer.id, 'visibility', 'none');
                  console.log('Hidden:', layer.id);
                } catch (e) {
                  console.log('Could not hide:', layer.id);
                }
              }
            }

            // Remove transparency from 3D buildings
            if (layer.type === 'fill-extrusion' && layer.id.includes('building')) {
              try {
                map.setPaintProperty(layer.id, 'fill-extrusion-opacity', 1.0);
                console.log('Made solid:', layer.id);
              } catch (e) {
                console.log('Could not modify:', layer.id);
              }
            }
          });
        }
      }, 1000);
    });

    return () => {
      mapRef.current?.remove();
    };
  }, []);

  const handleLightingChange = (preset: keyof typeof LIGHTING_PRESETS) => {
    // Lighting change handler - can be implemented later if needed
    console.log('Lighting changed to:', preset);
  };

  return (
    <div className="relative w-full h-screen overflow-hidden">
      <MapSidebar onLightingChange={handleLightingChange} />
      <div ref={mapContainerRef} className="absolute inset-0 w-full h-full" />

      <style dangerouslySetInnerHTML={{
        __html: `
        .mapboxgl-ctrl-logo,
        .mapboxgl-ctrl-attrib,
        .mapboxgl-ctrl-scale,
        .mapboxgl-ctrl,
        .mapboxgl-ctrl-bottom-left,
        .mapboxgl-ctrl-bottom-right {
          display: none !important;
        }
      `}} />
    </div>
  );
}
