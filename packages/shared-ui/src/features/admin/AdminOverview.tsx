// packages/shared-ui/src/features/admin/AdminOverview.tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { UtensilsCrossed, Bike, TrendingUp } from 'lucide-react';
import { Skeleton } from '../../components/ui/skeleton';


export default function AdminDashboardPage() {
  const [stats, setStats] = useState({
    totalRestaurants: 0,
    pendingRestaurants: 0,
    approvedRestaurants: 0,
    rejectedRestaurants: 0,
    totalRiders: 0,
    pendingRiders: 0,
    approvedRiders: 0,
    onlineRiders: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const fetchDashboardStats = async () => {
    setLoading(true);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants`);
      if (!restaurantsRes.ok) throw new Error('Failed to fetch restaurants');
      const restaurantsJson = await restaurantsRes.json();
      const restaurants = restaurantsJson.data || restaurantsJson || [];

      const ridersRes = await fetch(`${apiUrl}/api/riders`);
      const ridersJson = ridersRes.ok ? await ridersRes.json() : { data: [] };
      const riders = ridersJson.data || ridersJson || [];

      if (Array.isArray(restaurants)) {
        const totalRestaurants = restaurants.length;
        const pendingRestaurants = restaurants.filter((r: any) => r.status === 'pending').length;
        const approvedRestaurants = restaurants.filter((r: any) => r.status === 'approved').length;
        const rejectedRestaurants = restaurants.filter((r: any) => r.status === 'rejected').length;

        const ridersArray = Array.isArray(riders) ? riders : [];
        const totalRiders = ridersArray.length;
        const pendingRiders = ridersArray.filter((r: any) => r.status === 'pending').length;
        const approvedRiders = ridersArray.filter((r: any) => r.status === 'approved').length;
        const onlineRiders = ridersArray.filter((r: any) => r.status === 'approved' && r.isOnline).length;

        setStats({
          totalRestaurants,
          pendingRestaurants,
          approvedRestaurants,
          rejectedRestaurants,
          totalRiders,
          pendingRiders,
          approvedRiders,
          onlineRiders,
        });
      }
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const hasRestaurants = stats.totalRestaurants !== 0;
  const approvalRate = hasRestaurants
    ? Math.round((stats.approvedRestaurants / stats.totalRestaurants) * 100)
    : 0;

  return (
    <div className="space-y-8">
      <header>
        <h1 className="text-4xl font-bold font-headline tracking-tight">Admin Dashboard</h1>
        <p className="text-muted-foreground mt-2 text-lg">Welcome, Admin! Manage your platform here.</p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Restaurants</CardTitle>
            <UtensilsCrossed className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <>
                <div className="text-2xl font-bold">{stats.totalRestaurants}</div>
                <p className="text-xs text-muted-foreground mt-1">
                  {stats.approvedRestaurants} approved
                </p>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending Approvals</CardTitle>
            <TrendingUp className="h-4 w-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <>
                <div className="text-2xl font-bold text-orange-600">
                  {stats.pendingRestaurants + stats.pendingRiders}
                </div>
                <p className="text-xs text-muted-foreground mt-1">
                  {stats.pendingRestaurants} restaurants, {stats.pendingRiders} riders
                </p>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Restaurants</CardTitle>
            <UtensilsCrossed className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <>
                <div className="text-2xl font-bold text-green-600">{stats.approvedRestaurants}</div>
                <p className="text-xs text-muted-foreground mt-1">
                  Live on platform
                </p>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Riders</CardTitle>
            <Bike className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <>
                <div className="text-2xl font-bold">{stats.approvedRiders}</div>
                <p className="text-xs text-muted-foreground mt-1">
                  {stats.onlineRiders} online now
                </p>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <a
            href="/admin/restaurants"
            className="block p-4 rounded-lg border hover:bg-muted/50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <UtensilsCrossed className="h-5 w-5 text-primary" />
                <div>
                  <p className="font-medium">Review Restaurant Applications</p>
                  {loading ? (
                    <Skeleton className="h-4 w-48 mt-1" />
                  ) : (
                    <p className="text-sm text-muted-foreground">
                      {stats.pendingRestaurants} applications waiting for approval
                    </p>
                  )}
                </div>
              </div>
              <span className="text-muted-foreground">→</span>
            </div>
          </a>

          <a
            href="/admin/riders"
            className="block p-4 rounded-lg border hover:bg-muted/50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Bike className="h-5 w-5 text-primary" />
                <div>
                  <p className="font-medium">Manage Riders</p>
                  {loading ? (
                    <Skeleton className="h-4 w-48 mt-1" />
                  ) : (
                    <p className="text-sm text-muted-foreground">
                      {stats.pendingRiders} applications waiting for approval
                    </p>
                  )}
                </div>
              </div>
              <span className="text-muted-foreground">→</span>
            </div>
          </a>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Platform Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {loading ? (
              <>
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-3/4" />
              </>
            ) : (
              <>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Restaurant Approval Rate</span>
                  <span className="text-sm font-medium">{approvalRate}%</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Rejected Applications</span>
                  <span className="text-sm font-medium">{stats.rejectedRestaurants}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Riders Online</span>
                  <span className="text-sm font-medium text-green-600">{stats.onlineRiders} / {stats.approvedRiders}</span>
                </div>
              </>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
