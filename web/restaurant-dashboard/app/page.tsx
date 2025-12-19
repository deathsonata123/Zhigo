'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Amplify } from 'aws-amplify';
import { getCurrentUser, fetchAuthSession } from 'aws-amplify/auth';

// Configure Amplify
Amplify.configure({
    Auth: {
        Cognito: {
            userPoolId: process.env.NEXT_PUBLIC_COGNITO_USER_POOL_ID!,
            userPoolClientId: process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID!,
            region: process.env.NEXT_PUBLIC_AWS_REGION || 'us-east-1',
        }
    }
});

export default function HomePage() {
    const router = useRouter();

    useEffect(() => {
        checkAuth();
    }, []);

    const checkAuth = async () => {
        try {
            const user = await getCurrentUser();
            const session = await fetchAuthSession();
            const groups = session.tokens?.idToken?.payload['cognito:groups'] as string[] || [];

            if (groups.includes('RestaurantOwner')) {
                router.push('/dashboard');
            } else {
                router.push('/pending');
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
