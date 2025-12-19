// src/app/rider/page.tsx
'use client';

import { useEffect, useState, useRef } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { Separator } from '../../components/ui/separator';
import { Bike, MapPin, Store, User, Loader2, Package, CheckCircle, AlertCircle } from 'lucide-react';
import { useToast } from '../../hooks/use-toast';
import { getCurrentUser } from '../../lib/auth';
import DeliveryRequestPopup from '../../components/DeliveryRequestPopup';
import ActiveDeliveryTracking from '../../components/ActiveDeliveryTracking';


type RiderNotification = {
  id: string;
  orderId: string;
  restaurantName: string;
  customerAddress: string;
  orderTotal: number;
  message: string;
  isRead: boolean;
  isAccepted?: boolean | null;
  createdAt: string;
};

type Order = {
  id: string;
  restaurantName: string;
  customerName: string;
  customerPhone: string;
  customerAddress: string;
  restaurantLatitude?: number | null;
  restaurantLongitude?: number | null;
  customerLatitude?: number | null;
  customerLongitude?: number | null;
  noteToRider?: string | null;
  items: string;
  total: number;
  status: string;
  paymentMethod: string;
  prepTime?: number | null;
};

export default function RiderDashboard() {
  const [rider, setRider] = useState<any>(null);
  const [isOnline, setIsOnline] = useState(false);
  const [loading, setLoading] = useState(true);
  const [notifications, setNotifications] = useState<RiderNotification[]>([]);
  const [currentOrder, setCurrentOrder] = useState<Order | null>(null);
  const { toast } = useToast();

  // Delivery request popup state
  const [selectedNotification, setSelectedNotification] = useState<RiderNotification | null>(null);
  const [popupOpen, setPopupOpen] = useState(false);
  const [isAccepting, setIsAccepting] = useState(false);

  // Location states - LIVE TRACKING
  const [riderLocation, setRiderLocation] = useState({ lat: 23.8103, lng: 90.4125 });
  const watchId = useRef<number | null>(null);

  useEffect(() => {
    fetchRiderData();
  }, []);

  // Listen for header toggle changes
  useEffect(() => {
    const handleStatusChange = (e: any) => {
      console.log('🔄 Header toggle changed:', e.detail.isOnline);
      setIsOnline(e.detail.isOnline);
    };

    window.addEventListener('riderStatusChanged', handleStatusChange);
    return () => window.removeEventListener('riderStatusChanged', handleStatusChange);
  }, []);

  // START LIVE LOCATION TRACKING WHEN RIDER GOES ONLINE
  useEffect(() => {
    if (isOnline && 'geolocation' in navigator) {
      console.log('🚴 Starting live location tracking...');

      // Get initial position
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const newLocation = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          };
          setRiderLocation(newLocation);
          console.log('📍 Initial rider location:', newLocation);
        },
        (error) => console.warn('⚠️ Could not get initial location:', error),
        { enableHighAccuracy: true }
      );

      // Watch position continuously
      watchId.current = navigator.geolocation.watchPosition(
        (position) => {
          const newLocation = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          };
          setRiderLocation(newLocation);
          console.log('📍 Rider location updated:', newLocation);
        },
        (error) => console.error('❌ Geolocation error:', error),
        {
          enableHighAccuracy: true,
          maximumAge: 10000, // 10 seconds
          timeout: 5000
        }
      );
    } else if (!isOnline && watchId.current !== null) {
      // Stop tracking when offline
      console.log('🛑 Stopping live location tracking...');
      navigator.geolocation.clearWatch(watchId.current);
      watchId.current = null;
    }

    return () => {
      if (watchId.current !== null) {
        navigator.geolocation.clearWatch(watchId.current);
        watchId.current = null;
      }
    };
  }, [isOnline]);

  // Real-time notifications subscription
  useEffect(() => {
    if (!rider?.id || !isOnline) return;

    console.log('🔔 Setting up notification subscription...');

    const subscription = client.models.RiderNotification.observeQuery({
      filter: { riderId: { eq: rider.id } }
    }).subscribe({
      next: ({ items }: any) => {
        console.log('📥 Received notification update:', items.length, 'notifications');
        const sorted = (items as RiderNotification[]).sort((a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );

        const previousPending = notifications.filter(n => !n.isRead && (n.isAccepted === null || n.isAccepted === undefined));
        const newPending = sorted.filter(n => !n.isRead && (n.isAccepted === null || n.isAccepted === undefined));

        setNotifications(sorted);
        console.log('📬 Unread notifications:', newPending.length);

        // Auto-open popup for new notifications
        if (newPending.length > previousPending.length && newPending.length > 0 && !currentOrder) {
          const latestNotification = newPending[0];
          console.log('🚨 New delivery request! Auto-opening popup');
          setSelectedNotification(latestNotification);
          setPopupOpen(true);

          // Play notification sound (optional)
          try {
            const audio = new Audio('/notification.mp3');
            audio.play().catch(e => console.log('Could not play sound:', e));
          } catch (e) {
            console.log('No notification sound available');
          }
        }
      },
      error: (error: any) => {
        console.error('❌ Notification subscription error:', error);
      }
    });

    return () => {
      console.log('🛑 Unsubscribing from notifications');
      subscription.unsubscribe();
    };
  }, [rider?.id, isOnline, notifications, currentOrder]);

  // Real-time current order subscription
  useEffect(() => {
    if (!rider?.currentOrderId) {
      setCurrentOrder(null);
      return;
    }

    console.log('🔄 Setting up current order subscription:', rider.currentOrderId);

    const subscription = client.models.Order.observeQuery({
      filter: { id: { eq: rider.currentOrderId } }
    }).subscribe({
      next: ({ items }: any) => {
        console.log('📥 Current order update:', items.length);
        if (items.length > 0) {
          setCurrentOrder(items[0] as Order);
        } else {
          setCurrentOrder(null);
        }
      },
      error: (error: any) => {
        console.error('❌ Order subscription error:', error);
      }
    });

    return () => {
      console.log('🛑 Unsubscribing from current order');
      subscription.unsubscribe();
    };
  }, [rider?.currentOrderId]);

  const fetchRiderData = async () => {
    setLoading(true);
    try {
      const user = await getCurrentUser();
      console.log('👤 Current user:', user.userId);

      const { data: riders } = await client.models.Rider.list({
        filter: { userId: { eq: user.userId } }
      });

      if (!riders || riders.length === 0) {
        console.warn('⚠️ No rider profile found');
        toast({
          title: "No Rider Profile",
          description: "No rider profile found",
          variant: "destructive"
        });
        return;
      }

      const riderData = riders[0];
      console.log('🚴 Rider found:', riderData.id, riderData.fullName, 'Zone:', riderData.zone);
      setRider(riderData);
      setIsOnline(riderData.isOnline || false);

      // Fetch notifications
      const { data: notifData } = await client.models.RiderNotification.list({
        filter: { riderId: { eq: riderData.id } }
      });

      console.log('📬 Initial notifications loaded:', notifData?.length || 0);

      if (notifData) {
        const sorted = (notifData as RiderNotification[]).sort((a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );
        setNotifications(sorted);
      }

      // Fetch current order if exists
      if (riderData.currentOrderId) {
        console.log('📦 Fetching current order:', riderData.currentOrderId);
        const { data: order } = await client.models.Order.get({ id: riderData.currentOrderId });
        if (order) {
          console.log('✅ Current order loaded');
          setCurrentOrder(order as Order);
        }
      }
    } catch (error) {
      console.error('❌ Error fetching rider data:', error);
      toast({
        title: "Error",
        description: "Failed to load rider data",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const handleAcceptDelivery = async () => {
    if (!selectedNotification || !rider) return;

    console.log('✅ Accepting delivery:', selectedNotification.orderId);
    setIsAccepting(true);
    try {
      // Update notification as accepted
      const notifUpdate = await client.models.RiderNotification.update({
        id: selectedNotification.id,
        isAccepted: true,
        isRead: true,
      });

      if (notifUpdate.errors) {
        console.error('❌ Error updating notification:', notifUpdate.errors);
        throw new Error('Failed to update notification');
      }

      console.log('✅ Notification updated');

      // Assign rider to order
      const orderUpdate = await client.models.Order.update({
        id: selectedNotification.orderId,
        riderId: rider.id,
        status: 'assigned',
        riderAssignedAt: new Date().toISOString(),
      });

      if (orderUpdate.errors) {
        console.error('❌ Error assigning order:', orderUpdate.errors);
        throw new Error('Failed to assign order');
      }

      console.log('✅ Order assigned to rider');

      // Update rider's current order
      const riderUpdate = await client.models.Rider.update({
        id: rider.id,
        currentOrderId: selectedNotification.orderId,
      });

      if (riderUpdate.errors) {
        console.error('❌ Error updating rider:', riderUpdate.errors);
        throw new Error('Failed to update rider');
      }

      console.log('✅ Rider updated with current order');

      toast({
        title: "Delivery Accepted! 🎉",
        description: "Head to the restaurant to pick up",
      });

      setPopupOpen(false);
      setSelectedNotification(null);

      // Refresh data
      await fetchRiderData();
    } catch (error) {
      console.error('❌ Error accepting delivery:', error);
      toast({
        title: "Error",
        description: "Failed to accept delivery",
        variant: "destructive"
      });
    } finally {
      setIsAccepting(false);
    }
  };

  const handleDeclineDelivery = async () => {
    if (!selectedNotification) return;

    console.log('❌ Declining delivery:', selectedNotification.orderId);
    try {
      const { data, errors } = await client.models.RiderNotification.update({
        id: selectedNotification.id,
        isAccepted: false,
        isRead: true,
      });

      if (errors) {
        console.error('❌ Error declining:', errors);
        throw new Error('Failed to decline');
      }

      console.log('✅ Delivery declined');

      toast({
        title: "Delivery Declined",
        description: "Looking for other orders...",
      });

      setPopupOpen(false);
      setSelectedNotification(null);
    } catch (error) {
      console.error('❌ Error declining delivery:', error);
      toast({
        title: "Error",
        description: "Failed to decline delivery",
        variant: "destructive"
      });
    }
  };

  const handleArrivedAtRestaurant = async () => {
    if (!currentOrder) return;

    console.log('🏪 Marking arrived at restaurant');
    try {
      const { data, errors } = await client.models.Order.update({
        id: currentOrder.id,
        status: 'at_restaurant',
      });

      if (errors) {
        console.error('❌ Error updating status:', errors);
        throw new Error('Failed to update');
      }

      console.log('✅ Arrived at restaurant');

      toast({
        title: "Arrived at Restaurant",
        description: "Waiting for order preparation",
      });
    } catch (error) {
      console.error('❌ Error:', error);
      toast({
        title: "Error",
        description: "Failed to update status",
        variant: "destructive"
      });
    }
  };

  const handleConfirmPickup = async () => {
    if (!currentOrder) return;

    console.log('📦 Confirming pickup');
    try {
      const { data, errors } = await client.models.Order.update({
        id: currentOrder.id,
        status: 'picked_up',
        pickedUpAt: new Date().toISOString(),
      });

      if (errors) {
        console.error('❌ Error updating status:', errors);
        throw new Error('Failed to update');
      }

      console.log('✅ Order picked up');

      toast({
        title: "Order Picked Up",
        description: "Now delivering to customer",
      });
    } catch (error) {
      console.error('❌ Error:', error);
      toast({
        title: "Error",
        description: "Failed to update status",
        variant: "destructive"
      });
    }
  };

  const handleArrivedAtCustomer = async () => {
    if (!currentOrder) return;

    console.log('🏠 Marking arrived at customer');
    try {
      const { data, errors } = await client.models.Order.update({
        id: currentOrder.id,
        status: 'delivering',
      });

      if (errors) {
        console.error('❌ Error updating status:', errors);
        throw new Error('Failed to update');
      }

      console.log('✅ Arrived at customer');

      toast({
        title: "Arrived at Customer",
        description: "Complete the delivery",
      });
    } catch (error) {
      console.error('❌ Error:', error);
      toast({
        title: "Error",
        description: "Failed to update status",
        variant: "destructive"
      });
    }
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} mins ago`;
    return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  if (!rider || rider.status !== 'approved') {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Card className="max-w-md">
          <CardHeader>
            <CardTitle>Account Pending</CardTitle>
            <CardDescription>
              Your rider account is pending approval.
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    );
  }

  const pendingNotifications = notifications.filter(n => !n.isRead && (n.isAccepted === null || n.isAccepted === undefined));

  // Get restaurant and customer locations from current order
  const restaurantLocation = currentOrder
    ? { lat: currentOrder.restaurantLatitude || 23.8103, lng: currentOrder.restaurantLongitude || 90.4125 }
    : { lat: 23.8103, lng: 90.4125 };

  const customerLocation = currentOrder
    ? { lat: currentOrder.customerLatitude || 23.7805, lng: currentOrder.customerLongitude || 90.4200 }
    : { lat: 23.7805, lng: 90.4200 };

  return (
    <div className="space-y-6">
      {/* Delivery Request Popup */}
      <DeliveryRequestPopup
        open={popupOpen}
        onAccept={handleAcceptDelivery}
        onDecline={handleDeclineDelivery}
        isAccepting={isAccepting}
        notification={selectedNotification}
        riderLocation={riderLocation}
        restaurantLocation={restaurantLocation}
        customerLocation={customerLocation}
      />

      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold font-headline">Rider Dashboard</h1>
          <p className="text-muted-foreground mt-1">Welcome, {rider.fullName}!</p>
          {rider.zone && (
            <p className="text-sm text-muted-foreground">Zone: <Badge variant="outline">{rider.zone}</Badge></p>
          )}
          {isOnline && (
            <p className="text-xs text-green-600 mt-1 flex items-center gap-1">
              <span className="inline-block w-2 h-2 bg-green-600 rounded-full animate-pulse" />
              Live tracking active
            </p>
          )}
        </div>
        <div className="flex items-center space-x-2">
          <Badge variant={isOnline ? "default" : "secondary"} className="text-sm px-3 py-1">
            {isOnline ? 'Online' : 'Offline'}
          </Badge>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Total Deliveries</CardDescription>
            <CardTitle className="text-3xl">{rider.totalDeliveries || 0}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Pending Requests</CardDescription>
            <CardTitle className="text-3xl">{pendingNotifications.length}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-3">
            <CardDescription>Status</CardDescription>
            <CardTitle className="text-3xl">
              {isOnline ? (
                <Badge variant="default" className="text-lg">Online</Badge>
              ) : (
                <Badge variant="secondary" className="text-lg">Offline</Badge>
              )}
            </CardTitle>
          </CardHeader>
        </Card>
      </div>

      {/* Current Delivery - Show Active Delivery Tracking */}
      {currentOrder ? (
        <ActiveDeliveryTracking
          order={currentOrder}
          onArrivedAtRestaurant={handleArrivedAtRestaurant}
          onConfirmPickup={handleConfirmPickup}
          onArrivedAtCustomer={handleArrivedAtCustomer}
        />
      ) : (
        /* Available Deliveries - Simplified */
        <div>
          <h2 className="text-2xl font-bold mb-4">Available Deliveries</h2>

          {!isOnline && (
            <Card className="border-yellow-500 bg-yellow-50">
              <CardContent className="flex items-center gap-3 p-4">
                <AlertCircle className="h-5 w-5 text-yellow-600" />
                <div>
                  <p className="text-sm text-yellow-800 font-medium">
                    Turn online to receive delivery requests
                  </p>
                  <p className="text-xs text-yellow-700 mt-1">
                    Use the toggle in the header. Live location tracking will start automatically
                  </p>
                </div>
              </CardContent>
            </Card>
          )}

          {isOnline && pendingNotifications.length === 0 && (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-12">
                <Bike className="h-12 w-12 text-muted-foreground mb-4" />
                <p className="text-muted-foreground">No delivery requests at the moment</p>
                <p className="text-sm text-muted-foreground mt-2">Popup will appear when a new order arrives</p>
                <div className="mt-4 flex items-center gap-2 text-xs text-green-600">
                  <span className="inline-block w-2 h-2 bg-green-600 rounded-full animate-pulse" />
                  <span>Live tracking active</span>
                </div>
              </CardContent>
            </Card>
          )}

          {isOnline && pendingNotifications.length > 0 && (
            <Card className="border-primary bg-primary/5">
              <CardContent className="flex flex-col items-center justify-center py-12">
                <div className="relative mb-4">
                  <div className="absolute inset-0 bg-primary rounded-full animate-ping opacity-75" />
                  <Bike className="relative h-12 w-12 text-primary" />
                </div>
                <p className="text-lg font-bold">New Delivery Request!</p>
                <p className="text-sm text-muted-foreground mt-2">
                  {pendingNotifications.length} request(s) waiting
                </p>
                <Button
                  className="mt-4"
                  onClick={() => {
                    setSelectedNotification(pendingNotifications[0]);
                    setPopupOpen(true);
                  }}
                >
                  View Request
                </Button>
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {/* Location Debug Info (Remove in production) */}
      {process.env.NODE_ENV === 'development' && isOnline && (
        <Card className="bg-blue-50 border-blue-200">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Debug: Current Location</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-xs font-mono">
              Lat: {riderLocation.lat.toFixed(6)}, Lng: {riderLocation.lng.toFixed(6)}
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}