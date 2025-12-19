'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function HomePage() {
    const router = useRouter();

    useEffect(() => {
        checkAuth();
    }, []);

    const checkAuth = async () => {
        try {
            const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/auth/me`, {
                credentials: 'include',
            });

            if (response.ok) {
                const user = await response.json();

                // Check if user is restaurant owner
                if (user.role === 'restaurant_owner' || user.restaurantId) {
                    router.push('/dashboard');
                } else {
                    router.push('/login');
                }
            } else {
                router.push('/login');
            }
        } catch (error) {
            router.push('/login');
        }
    };

    return (
        <div className="flex items-center justify-center min-h-screen">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
    );
}
