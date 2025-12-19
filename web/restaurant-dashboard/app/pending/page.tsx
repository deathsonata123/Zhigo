'use client';

import { Clock } from 'lucide-react';
import { Button } from 'shared-ui/components/ui/button';
import { useRouter } from 'next/navigation';

export default function PendingPage() {
    const router = useRouter();

    return (
        <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-yellow-50 to-orange-100">
            <div className="text-center space-y-6 max-w-md p-8">
                <div className="flex justify-center">
                    <div className="bg-yellow-100 p-4 rounded-full">
                        <Clock className="h-12 w-12 text-yellow-600" />
                    </div>
                </div>
                <h1 className="text-3xl font-bold text-gray-900">Pending Approval</h1>
                <p className="text-gray-600">
                    Your restaurant application is currently under review by our admin team. You will receive an email and SMS notification once your restaurant is approved.
                </p>
                <p className="text-sm text-gray-500">
                    This usually takes 24-48 hours. Thank you for your patience!
                </p>
                <Button
                    onClick={() => router.push('/login')}
                    variant="outline"
                >
                    Back to Login
                </Button>
            </div>
        </div>
    );
}
