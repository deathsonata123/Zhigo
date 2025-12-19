// src/app/check-rider-status/page.tsx
'use client';

import { useState } from 'react';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { getCurrentUser } from '../../lib/auth';
import { Loader2, CheckCircle, XCircle, AlertCircle } from 'lucide-react';


export default function CheckRiderStatusPage() {
  const [checking, setChecking] = useState(false);
  const [result, setResult] = useState<any>(null);

  const checkStatus = async () => {
    setChecking(true);
    setResult(null);

    try {
      const currentUser = await getCurrentUser();

      const result: any = {
        authenticated: true,
        userId: currentUser.userId,
        email: currentUser.signInDetails?.loginId,
        riders: [],
        hasApprovedRider: false,
        hasPendingRider: false,
      };

      // Fetch all riders for this user using API call
      if (!currentUser?.userId) {
        throw new Error("User not authenticated or user ID not available.");
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/riders?userId=${currentUser.userId}`);

      if (!response.ok) {
        throw new Error(`Failed to fetch riders: ${response.statusText}`);
      }

      const riders = await response.json();

      result.riders = riders || [];
      result.hasApprovedRider = riders?.some((r: any) => r.status === 'approved') || false;
      result.hasPendingRider = riders?.some((r: any) => r.status === 'pending') || false;

      setResult(result);
    } catch (error) {
      setResult({
        authenticated: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    } finally {
      setChecking(false);
    }
  };

  return (
    <div className="container mx-auto py-12 px-4">
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle>Rider Status Checker (Debug Tool)</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button onClick={checkStatus} disabled={checking} className="w-full">
            {checking && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Check My Rider Status
          </Button>

          {result && (
            <div className="space-y-4 mt-6">
              {result.authenticated ? (
                <>
                  <div className="flex items-center gap-2 text-green-600">
                    <CheckCircle className="h-5 w-5" />
                    <span className="font-medium">User Authenticated</span>
                  </div>

                  <div className="bg-muted p-4 rounded-lg space-y-2 text-sm">
                    <div><strong>User ID:</strong> {result.userId}</div>
                    <div><strong>Email:</strong> {result.email}</div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center gap-2">
                      {result.hasApprovedRider ? (
                        <>
                          <CheckCircle className="h-5 w-5 text-green-600" />
                          <span className="font-medium text-green-600">Has Approved Rider Account</span>
                        </>
                      ) : (
                        <>
                          <XCircle className="h-5 w-5 text-red-600" />
                          <span className="font-medium text-red-600">No Approved Rider Account</span>
                        </>
                      )}
                    </div>

                    <div className="flex items-center gap-2">
                      {result.hasPendingRider ? (
                        <>
                          <AlertCircle className="h-5 w-5 text-orange-600" />
                          <span className="font-medium text-orange-600">Has Pending Application</span>
                        </>
                      ) : (
                        <>
                          <XCircle className="h-5 w-5 text-gray-400" />
                          <span className="font-medium text-gray-600">No Pending Application</span>
                        </>
                      )}
                    </div>
                  </div>

                  {result.riders.length > 0 ? (
                    <div className="mt-4">
                      <h3 className="font-medium mb-2">Rider Records Found:</h3>
                      {result.riders.map((rider: any, index: number) => (
                        <div key={index} className="bg-muted p-3 rounded-lg mb-2 text-sm">
                          <div><strong>ID:</strong> {rider.id}</div>
                          <div><strong>Name:</strong> {rider.fullName}</div>
                          <div><strong>Status:</strong> <span className={
                            rider.status === 'approved' ? 'text-green-600 font-medium' :
                              rider.status === 'pending' ? 'text-orange-600 font-medium' :
                                'text-red-600 font-medium'
                          }>{rider.status}</span></div>
                          <div><strong>Zone:</strong> {rider.zone}</div>
                          <div><strong>Is Online:</strong> {rider.isOnline ? 'Yes' : 'No'}</div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="bg-yellow-50 border border-yellow-200 p-4 rounded-lg">
                      <p className="text-sm text-yellow-800">
                        No rider records found for this user. You haven't applied to become a rider yet.
                      </p>
                    </div>
                  )}
                </>
              ) : (
                <div className="flex items-center gap-2 text-red-600">
                  <XCircle className="h-5 w-5" />
                  <span className="font-medium">Not Authenticated: {result.error}</span>
                </div>
              )}
            </div>
          )}

          <div className="mt-6 pt-6 border-t">
            <h3 className="font-medium mb-2">Expected Behavior:</h3>
            <ul className="text-sm text-muted-foreground space-y-1 list-disc list-inside">
              <li>After submitting rider application: Status should be "pending"</li>
              <li>After admin approval: Status should be "approved"</li>
              <li>If approved: You should see "Rider Dashboard" in header dropdown</li>
              <li>If approved: You should see Online/Offline toggle in header</li>
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}