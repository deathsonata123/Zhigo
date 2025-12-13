//src/components/rider-sidebar.tsx
'use client';

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "../lib/utils";
import { 
    LayoutDashboard, 
    Package,
    Wallet,
    Bike,
    User,
    Settings
} from "lucide-react";


export function RiderSidebar() {
    const pathname = usePathname();

    const navLinks = [
        { href: '/rider', label: 'Dashboard', icon: LayoutDashboard },
        { href: '/rider/orders', label: 'My Orders', icon: Package },
        { href: '/rider/earnings', label: 'Earnings', icon: Wallet },
        { href: '/rider/settings', label: 'Settings', icon: Settings },
    ];
    

    return (
        <aside className="w-64 flex-shrink-0 border-r bg-card/50 p-4 flex flex-col">
            <div className="flex items-center gap-2 font-bold text-lg text-primary mb-6">
                <Bike className="h-6 w-6" />
                <span className="font-headline">Zhigo rider</span>
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
