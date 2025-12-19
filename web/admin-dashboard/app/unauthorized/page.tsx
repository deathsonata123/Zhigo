'use client';

import { UtensilsCrossed } from 'lucide-react';
import { Button } from 'shared-ui/components/ui/button';
import { useRouter } from 'next/navigation';

export default function UnauthorizedPage() {
  const router = useRouter();

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-red-50 to-orange-100">
      <div className="text-center space-y-6 max-w-md p-8">
        <div className="flex justify-center">
          <div className="bg-red-100 p-4 rounded-full">
            <UtensilsCrossed className="h-12 w-12 text-red-600" />
          </div>
        </div>
        <h1 className="text-3xl font-bold text-gray-900">Access Denied</h1>
        <p className="text-gray-600">
          You don't have permission to access the admin dashboard. Please contact your administrator if you believe this is an error.
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
