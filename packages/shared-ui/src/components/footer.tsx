
import { UtensilsCrossed } from "lucide-react";
import Link from "next/link";

export function Footer() {
    return (
        <footer className="bg-card border-t mt-auto">
            <div className="container mx-auto py-8 px-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                    <div>
                         <Link href="/" className="flex items-center gap-2 font-bold text-lg text-primary mb-2">
                            <UtensilsCrossed className="h-6 w-6" />
                            <span className="font-headline">Zhigo</span>
                        </Link>
                        <p className="text-sm text-muted-foreground">Your favorite food, delivered.</p>
                    </div>
                    <div>
                        <h3 className="font-semibold mb-3">Company</h3>
                        <nav className="flex flex-col gap-2 text-sm text-muted-foreground">
                            <Link href="#" className="hover:text-primary">About Us</Link>
                            <Link href="#" className="hover:text-primary">Careers</Link>
                            <Link href="#" className="hover:text-primary">Press</Link>
                        </nav>
                    </div>
                    <div>
                        <h3 className="font-semibold mb-3">Partnerships</h3>
                        <nav className="flex flex-col gap-2 text-sm text-muted-foreground">
                            <Link href="/partner" className="hover:text-primary">Become a Zhigo Partner</Link>
                            <Link href="/rider-signup" className="hover:text-primary">Become a Rider</Link>
                            <Link href="/developer" className="hover:text-primary">Become a Developer</Link>
                        </nav>
                    </div>
                     <div>
                        <h3 className="font-semibold mb-3">Help</h3>
                        <nav className="flex flex-col gap-2 text-sm text-muted-foreground">
                            <Link href="#" className="hover:text-primary">Contact Us</Link>
                            <Link href="#" className="hover:text-primary">FAQs</Link>
                        </nav>
                    </div>
                </div>
                 <div className="border-t mt-8 pt-4 text-center text-sm text-muted-foreground">
                    <p>&copy; {new Date().getFullYear()} Zhigo. All rights reserved.</p>
                </div>
            </div>
        </footer>
    );
}
