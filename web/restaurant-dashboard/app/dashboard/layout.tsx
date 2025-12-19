'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getCurrentUser, fetchAuthSession, signOut } from 'aws-amplify/auth';
import { Loader2, LayoutDashboard, UtensilsCrossed, Clock, Star, BarChart3, Settings, CreditCard, LogOut, Menu } from 'lucide-react';
import Link from 'next/link';
import { Button } from 'shared-ui/components/ui/button';
import { Sheet, SheetContent, SheetTrigger } from 'shared-ui/components/ui/sheet';
import { cn } from 'shared-ui/lib/utils';
import { usePathname } from 'next/navigation';

const navigation = [
    { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
    { name: 'Menu', href: '/dashboard/menu', icon: UtensilsCrossed },
    { name: 'Orders', href: '/dashboard/orders', icon: Clock },
    { name: 'Reviews', href: '/dashboard/reviews', icon: Star },
    { name: 'Analytics', href: '/dashboard/analytics', icon: BarChart3 },
    { name: 'Settings', href: '/dashboard/settings', icon: Settings },
];

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const [loading, setLoading] = useState(true);
    const [user, setUser] = useState<any>(null);
    const [restaurant, setRestaurant] = useState<any>(null);
    const router = useRouter();
    const pathname = usePathname();

    useEffect(() => {
        checkAuth();
    }, []);

    const checkAuth = async () => {
        try {
            const currentUser = await getCurrentUser();
            const session = await fetchAuthSession();
            const groups = session.tokens?.idToken?.payload['cognito:groups'] as string[] || [];

            if (!groups.includes('RestaurantOwner')) {
                router.push('/pending');
                return;
            }

            // Fetch restaurant details
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
            const response = await fetch(`${apiUrl}/api/restaurants?ownerId=${currentUser.userId}`);
            if (response.ok) {
                const restaurants = await response.json();
                const approved = restaurants.find((r: any) => r.status === 'approved');
                if (approved) {
                    setRestaurant(approved);
                } else {
                    router.push('/pending');
                    return;
                }
            }

            setUser(currentUser);
            setLoading(false);
        } catch (error) {
            router.push('/login');
        }
    };

    const handleSignOut = async () => {
        try {
            await signOut();
            router.push('/login');
        } catch (error) {
            console.error('Sign out error:', error);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="flex h-screen bg-background">
            {/* Desktop Sidebar */}
            <aside className="hidden md:flex md:flex-col md:w-64 border-r bg-card">
                <div className="flex items-center gap-2 h-16 px-6 border-b">
                    <UtensilsCrossed className="h-6 w-6 text-primary" />
                    <span className="font-bold text-lg">Zhigo</span>
                </div>
                <div className="px-4 py-3 border-b">
                    <p className="text-sm font-medium truncate">{restaurant?.name}</p>
                    <p className="text-xs text-muted-foreground">Restaurant Dashboard</p>
                </div>
                <nav className="flex-1 p-4 space-y-1">
                    {navigation.map((item) => {
                        const Icon = item.icon;
                        const isActive = pathname === item.href || pathname.startsWith(item.href + '/');
                        return (
                            <Link
                                key={item.name}
                                href={item.href}
                                className={cn(
                                    'flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors',
                                    isActive
                                        ? 'bg-primary text-primary-foreground'
                                        : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                                )}
                            >
                                <Icon className="h-5 w-5" />
                                {item.name}
                            </Link>
                        );
                    })}
                </nav>
                <div className="p-4 border-t">
                    <div className="mb-3 px-3">
                        <p className="text-sm font-medium truncate">{user?.signInDetails?.loginId || 'Owner'}</p>
                        <p className="text-xs text-muted-foreground">Restaurant Owner</p>
                    </div>
                    <Button
                        variant="outline"
                        className="w-full justify-start"
                        onClick={handleSignOut}
                    >
                        <LogOut className="h-4 w-4 mr-2" />
                        Sign Out
                    </Button>
                </div>
            </aside>

            {/* Mobile Header */}
            <div className="md:hidden fixed top-0 left-0 right-0 z-50 flex items-center justify-between h-16 px-4 bg-card border-b">
                <div className="flex items-center gap-2">
                    <UtensilsCrossed className="h-6 w-6 text-primary" />
                    <span className="font-bold">{restaurant?.name || 'Zhigo'}</span>
                </div>
                <Sheet>
                    <SheetTrigger asChild>
                        <Button variant="ghost" size="icon">
                            <Menu className="h-5 w-5" />
                        </Button>
                    </SheetTrigger>
                    <SheetContent side="right" className="w-64 p-0">
                        <div className="flex flex-col h-full">
                            <div className="flex items-center gap-2 h-16 px-6 border-b">
                                <UtensilsCrossed className="h-6 w-6 text-primary" />
                                <span className="font-bold text-lg">Zhigo</span>
                            </div>
                            <div className="px-4 py-3 border-b">
                                <p className="text-sm font-medium truncate">{restaurant?.name}</p>
                                <p className="text-xs text-muted-foreground">Restaurant Dashboard</p>
                            </div>
                            <nav className="flex-1 p-4 space-y-1">
                                {navigation.map((item) => {
                                    const Icon = item.icon;
                                    const isActive = pathname === item.href || pathname.startsWith(item.href + '/');
                                    return (
                                        <Link
                                            key={item.name}
                                            href={item.href}
                                            className={cn(
                                                'flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors',
                                                isActive
                                                    ? 'bg-primary text-primary-foreground'
                                                    : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                                            )}
                                        >
                                            <Icon className="h-5 w-5" />
                                            {item.name}
                                        </Link>
                                    );
                                })}
                            </nav>
                            <div className="p-4 border-t">
                                <div className="mb-3 px-3">
                                    <p className="text-sm font-medium truncate">{user?.signInDetails?.loginId || 'Owner'}</p>
                                    <p className="text-xs text-muted-foreground">Restaurant Owner</p>
                                </div>
                                <Button
                                    variant="outline"
                                    className="w-full justify-start"
                                    onClick={handleSignOut}
                                >
                                    <LogOut className="h-4 w-4 mr-2" />
                                    Sign Out
                                </Button>
                            </div>
                        </div>
                    </SheetContent>
                </Sheet>
            </div>

            {/* Main Content */}
            <main className="flex-1 overflow-auto md:mt-0 mt-16">
                <div className="container mx-auto p-6 md:p-8">
                    {children}
                </div>
            </main>
        </div>
    );
}
