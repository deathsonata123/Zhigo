// src/app/admin/restaurants/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardFooter } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { Check, X, Mail, Phone, MapPin, RefreshCw, Loader2 } from 'lucide-react';
import { getUrl } from '../../lib/storage';
import Image from 'next/image';
import { useToast } from '../../hooks/use-toast';
import { Skeleton } from '../../components/ui/skeleton';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';


type Restaurant = {
  id: string;
  name: string;
  businessType: string;
  address: string;
  email: string;
  phone: string;
  photoUrl: string;
  imageUrl?: string;
  ownerId: string;
  status: string;
};

export default function RestaurantApprovalsPage() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('all');
  const [processingId, setProcessingId] = useState<string | null>(null);
  const { toast } = useToast();

  useEffect(() => {
    fetchRestaurants();
  }, []);

  const fetchRestaurants = async () => {
    try {
      setLoading(true);
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/restaurants`);

      if (!response.ok) throw new Error('Failed to fetch restaurants');

      const data = await response.json();

      if (data) {
        const restaurantsWithImages = await Promise.all(
          data.map(async (restaurant: any) => {
            let imageUrl = 'https://picsum.photos/seed/default/600/400';

            if (restaurant.photoUrl) {
              try {
                const urlResult = await getUrl({ path: restaurant.photoUrl });
                imageUrl = urlResult.url.toString();
              } catch (error) {
                console.log('Error fetching image:', error);
              }
            }

            return {
              id: restaurant.id,
              name: restaurant.name || 'Unknown',
              businessType: restaurant.businessType || 'N/A',
              address: restaurant.address || 'N/A',
              email: restaurant.email || 'N/A',
              phone: restaurant.phone || 'N/A',
              photoUrl: restaurant.photoUrl || '',
              imageUrl,
              ownerId: restaurant.ownerId || '',
              status: restaurant.status || 'pending',
            };
          })
        );

        setRestaurants(restaurantsWithImages);
      }
    } catch (error: any) {
      console.error('Error:', error);
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to load restaurants",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (restaurantId: string, restaurantName: string) => {
    if (processingId) return;

    setProcessingId(restaurantId);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/restaurants/${restaurantId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'approved' })
      });

      const result = { data: response.ok };

      if (result.data) {
        toast({
          title: "Restaurant Approved",
          description: `${restaurantName} is now live!`,
        });

        setRestaurants(prev => prev.map(r =>
          r.id === restaurantId ? { ...r, status: 'approved' } : r
        ));
      }
    } catch (error: any) {
      console.error('Error approving:', error);
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to approve restaurant",
      });
    } finally {
      setProcessingId(null);
    }
  };

  const handleReject = async (restaurantId: string, restaurantName: string) => {
    if (processingId) return;

    setProcessingId(restaurantId);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/restaurants/${restaurantId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'rejected' })
      });

      const result = { data: response.ok };

      if (result.data) {
        toast({
          title: "Restaurant Rejected",
          description: `${restaurantName} has been rejected.`,
        });

        setRestaurants(prev => prev.map(r =>
          r.id === restaurantId ? { ...r, status: 'rejected' } : r
        ));
      }
    } catch (error: any) {
      console.error('Error rejecting:', error);
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to reject restaurant",
      });
    } finally {
      setProcessingId(null);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return <Badge className="bg-orange-100 text-orange-700">Pending</Badge>;
      case 'approved':
        return <Badge className="bg-green-100 text-green-700">Approved</Badge>;
      case 'rejected':
        return <Badge className="bg-red-100 text-red-700">Rejected</Badge>;
      default:
        return <Badge>{status}</Badge>;
    }
  };

  const filteredRestaurants = restaurants.filter(restaurant => {
    if (activeTab === 'all') return true;
    return restaurant.status === activeTab;
  });

  const counts = {
    all: restaurants.length,
    pending: restaurants.filter(r => r.status === 'pending').length,
    approved: restaurants.filter(r => r.status === 'approved').length,
    rejected: restaurants.filter(r => r.status === 'rejected').length,
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <h1 className="text-3xl font-bold">Loading...</h1>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 6 }).map((_, i) => (
            <Card key={i}>
              <Skeleton className="h-48 w-full" />
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold font-headline">Restaurant Approvals</h1>
          <p className="text-muted-foreground mt-2">{counts.pending} pending</p>
        </div>
        <Button variant="outline" onClick={fetchRestaurants}>
          <RefreshCw className="h-4 w-4 mr-2" />
          Refresh
        </Button>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="all">All ({counts.all})</TabsTrigger>
          <TabsTrigger value="pending">Pending ({counts.pending})</TabsTrigger>
          <TabsTrigger value="approved">Approved ({counts.approved})</TabsTrigger>
          <TabsTrigger value="rejected">Rejected ({counts.rejected})</TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-6">
          {filteredRestaurants.length === 0 ? (
            <Card>
              <CardContent className="py-12 text-center">
                <p className="text-muted-foreground">No restaurants found</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredRestaurants.map((restaurant) => (
                <Card key={restaurant.id}>
                  <div className="relative h-48 w-full">
                    <Image
                      src={restaurant.imageUrl || 'https://picsum.photos/seed/default/600/400'}
                      alt={restaurant.name}
                      fill
                      className="object-cover"
                    />
                    <div className="absolute top-2 right-2">
                      {getStatusBadge(restaurant.status)}
                    </div>
                  </div>

                  <CardHeader>
                    <CardTitle>{restaurant.name}</CardTitle>
                    <p className="text-sm text-muted-foreground">{restaurant.businessType}</p>
                  </CardHeader>

                  <CardContent className="space-y-2 text-sm">
                    <div className="flex gap-2">
                      <MapPin className="h-4 w-4 mt-0.5 flex-shrink-0" />
                      <span>{restaurant.address}</span>
                    </div>
                    <div className="flex gap-2">
                      <Mail className="h-4 w-4" />
                      <span className="truncate">{restaurant.email}</span>
                    </div>
                    <div className="flex gap-2">
                      <Phone className="h-4 w-4" />
                      <span>{restaurant.phone}</span>
                    </div>
                  </CardContent>

                  {restaurant.status === 'pending' && (
                    <CardFooter className="grid grid-cols-2 gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => handleReject(restaurant.id, restaurant.name)}
                        disabled={processingId === restaurant.id}
                      >
                        {processingId === restaurant.id ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <>
                            <X className="h-4 w-4 mr-2" />
                            Reject
                          </>
                        )}
                      </Button>
                      <Button
                        size="sm"
                        onClick={() => handleApprove(restaurant.id, restaurant.name)}
                        disabled={processingId === restaurant.id}
                        className="bg-green-600 hover:bg-green-700"
                      >
                        {processingId === restaurant.id ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <>
                            <Check className="h-4 w-4 mr-2" />
                            Approve
                          </>
                        )}
                      </Button>
                    </CardFooter>
                  )}
                </Card>
              ))}
            </div>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
