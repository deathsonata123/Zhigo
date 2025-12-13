
'use client';

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "../lib/utils";
import { 
    LayoutDashboard, 
    Megaphone, 
    BarChart3, 
    Package, 
    Star, 
    BookOpenCheck,
    Clock,
    FileText,
    UtensilsCrossed,
    QrCode,
    Settings,
    HelpCircle,
    Cuboid
} from "lucide-react";


export function DashboardSidebar() {
    const pathname = usePathname();

    const navLinks = [
        { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
        { href: '/dashboard/orders', label: 'Orders', icon: Package },
        { href: '/dashboard/menu', label: 'Menu Management', icon: BookOpenCheck },
        { href: '/dashboard/reviews', label: 'Ratings and Reviews', icon: Star },
        { href: '/dashboard/qrcode', label: 'QR Code', icon: QrCode },
        { href: '/dashboard/hours', label: 'Opening Times', icon: Clock },
        { href: '/dashboard/3d', label: '3D', icon: Cuboid },
        { href: '/dashboard/analytics', label: 'Analytics', icon: BarChart3 },
        { href: '/dashboard/marketing', label: 'Marketing & Promotions', icon: Megaphone },
        { href: '/dashboard/billing', label: 'Billing', icon: FileText },
        { href: '/dashboard/user-management', label: 'User Management', icon: HelpCircle },
        { href: '/dashboard/settings', label: 'Settings', icon: Settings },
    ];
    

    return (
        <aside className="w-64 flex-shrink-0 border-r bg-card/50 p-4 flex flex-col">
            <div className="flex items-center gap-2 font-bold text-lg text-primary mb-6">
                <UtensilsCrossed className="h-6 w-6" />
                <span className="font-headline">Zhigo partner</span>
            </div>
            <nav className="flex flex-col gap-1 flex-grow">
                {navLinks.map((link) => (
                    <Link
                        key={link.href}
                        href={link.href}
                        className={cn(
                            "flex items-center gap-3 rounded-md px-3 py-2 text-muted-foreground transition-all hover:text-primary hover:bg-primary/10",
                            pathname === link.href && "bg-primary/10 text-primary font-medium"
                        )}
                    >
                        <link.icon className="h-4 w-4" />
                        {link.label}
                    </Link>
                ))}
            </nav>
        </aside>
    );
}
