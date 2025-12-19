// src/components/admin-sidebar.tsx
'use client';

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "../lib/utils";
import { 
    LayoutDashboard, 
    Users,
    Bike,
    ShieldCheck,
    UtensilsCrossed
} from "lucide-react";

export function AdminSidebar() {
    const pathname = usePathname();

    // Navigation links for admin panel - each link represents a different management section
    const navLinks = [
        { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
        { href: '/admin/restaurants', label: 'Restaurant Approvals', icon: UtensilsCrossed },
        { href: '/admin/riders', label: 'Rider Management', icon: Bike },
    ];

    return (
        <aside className="w-64 flex-shrink-0 border-r bg-card/50 p-4 flex flex-col">
            {/* Admin panel branding header */}
            <div className="flex items-center gap-2 font-bold text-lg text-primary mb-6">
                <ShieldCheck className="h-6 w-6" />
                <span className="font-headline">Zhigo Admin</span>
            </div>
            
            {/* Navigation menu with active state highlighting */}
            <nav className="flex flex-col gap-1 flex-grow">
                {navLinks.map((link) => (
                    <Link
                        key={link.href}
                        href={link.href}
                        className={cn(
                            "flex items-center gap-3 rounded-md px-3 py-2 text-muted-foreground transition-all hover:text-primary hover:bg-primary/10",
                            // Highlight current page
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
