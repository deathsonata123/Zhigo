//src/app/dashboard/orders/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Badge } from '../../components/ui/badge';
import { Separator } from '../../components/ui/separator';
import { Loader2, User, MapPin, Phone, Package, Clock } from 'lucide-react';
import { useToast } from '../../hooks/use-toast';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '../../components/ui/dialog';
import { Textarea } from '../../components/ui/textarea';
import { Label } from '../../components/ui/label';
import { Input } from '../../components/ui/input';
import { getCurrentUser } from '../../lib/auth';


type Order = {
  id: string;
  restaurantName: string;
  customerName: string;
  customerPhone: string;
  customerAddress: string;
  deliveryZone: string;
  noteToRestaurant?: string | null;
  items: string;
  total: number;
  status: string;
  paymentMethod: string;
  createdAt: string;
  rejectionReason?: string | null;
  prepTime?: number | null;
};

export default function RestaurantOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [restaurantId, setRestaurantId] = useState<string | null>(null);
  const [restaurantZone, setRestaurantZone] = useState<string>('');
  const { toast } = useToast();

  // Reject dialog
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [rejectionReason, setRejectionReason] = useState('');
  const [isRejecting, setIsRejecting] = useState(false);

  // Accept dialog
  const [acceptDialogOpen, setAcceptDialogOpen] = useState(false);
  const [prepTime, setPrepTime] = useState(20);
  const [isAccepting, setIsAccepting] = useState(false);

  useEffect(() => {
    fetchRestaurantAndOrders();
  }, []);

  useEffect(() => {
    if (!restaurantId) return;

    // TODO: Implement WebSocket or polling for real-time order updates
    // Subscription removed - implement alternative real-time solution
    console.log('🔄 Real-time subscription removed - implement WebSocket or polling');
  }, [restaurantId]);

  const fetchRestaurantAndOrders = async () => {
    setLoading(true);
    try {
      const user = await getCurrentUser();
      console.log('👤 Current user:', user.userId);

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?ownerId=${user.userId}`);
      if (!restaurantsRes.ok) throw new Error('No restaurant found');
      const restaurants = await restaurantsRes.json();

      if (!restaurants || restaurants.length === 0) {
        toast({
          title: "No Restaurant Found",
          description: "No restaurant associated with your account",
          variant: "destructive"
        });
        return;
      }

      const restaurant = restaurants[0];
      console.log('🏪 Restaurant found:', restaurant.id, restaurant.name, 'Zone:', restaurant.zone);
      setRestaurantId(restaurant.id);
      setRestaurantZone(restaurant.zone || 'Dhaka');

      const ordersRes = await fetch(`${apiUrl}/api/orders?restaurantId=${restaurant.id}`);
      if (!ordersRes.ok) throw new Error('Failed to fetch orders');
      const orderData = await ordersRes.json();

      console.log('📦 Initial orders loaded:', orderData?.length || 0);

      if (orderData) {
        const sorted = (orderData as Order[]).sort((a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );
        setOrders(sorted);
      }
    } catch (error) {
      console.error('❌ Error fetching restaurant/orders:', error);
      toast({
        title: "Error",
        description: "Failed to load orders",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  const handleAcceptOrder = async () => {
    if (!selectedOrder) return;

    console.log('✅ Accepting order:', selectedOrder.id);
    setIsAccepting(true);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const updateRes = await fetch(`${apiUrl}/api/orders/${selectedOrder.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          status: 'accepted',
          acceptedAt: new Date().toISOString(),
          prepTime,
        })
      });

      if (!updateRes.ok) throw new Error('Failed to accept order');
      const data = await updateRes.json();
      const errors = null;

      if (errors) {
        console.error('❌ Error accepting order:', errors);
        throw new Error('Failed to accept order');
      }

      console.log('✅ Order accepted successfully:', data);

      toast({
        title: "Order Accepted",
        description: `Prep time: ${prepTime} minutes`,
      });

      setAcceptDialogOpen(false);
      setSelectedOrder(null);
      setPrepTime(20);
    } catch (error) {
      console.error('❌ Error accepting order:', error);
      toast({
        title: "Error",
        description: "Failed to accept order",
        variant: "destructive"
      });
    } finally {
      setIsAccepting(false);
    }
  };

  const handleRejectOrder = async () => {
    if (!selectedOrder || !rejectionReason.trim()) {
      toast({
        title: "Reason Required",
        description: "Please provide a reason for rejection",
        variant: "destructive"
      });
      return;
    }

    console.log('❌ Rejecting order:', selectedOrder.id);
    setIsRejecting(true);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const updateRes = await fetch(`${apiUrl}/api/orders/${selectedOrder.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          status: 'rejected',
          rejectedAt: new Date().toISOString(),
          rejectionReason: rejectionReason,
        })
      });

      if (!updateRes.ok) throw new Error('Failed to reject order');
      const data = await updateRes.json();
      const errors = null;

      if (errors) {
        console.error('❌ Error rejecting order:', errors);
        throw new Error('Failed to reject order');
      }

      console.log('✅ Order rejected successfully:', data);

      toast({
        title: "Order Rejected",
        description: "Customer has been notified",
      });

      setRejectDialogOpen(false);
      setSelectedOrder(null);
      setRejectionReason('');
    } catch (error) {
      console.error('❌ Error rejecting order:', error);
      toast({
        title: "Error",
        description: "Failed to reject order",
        variant: "destructive"
      });
    } finally {
      setIsRejecting(false);
    }
  };

  const handleMarkPreparing = async (orderId: string) => {
    console.log('👨‍🍳 Marking order as preparing:', orderId);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const updateRes = await fetch(`${apiUrl}/api/orders/${orderId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'preparing' })
      });

      if (!updateRes.ok) throw new Error('Failed to update status');
      const data = await updateRes.json();
      const errors = null;

      if (errors) {
        console.error('❌ Error updating status:', errors);
        throw new Error('Failed to update status');
      }

      console.log('✅ Order marked as preparing:', data);

      toast({
        title: "Status Updated",
        description: "Order is now being prepared",
      });
    } catch (error) {
      console.error('❌ Error marking as preparing:', error);
      toast({
        title: "Error",
        description: "Failed to update order status",
        variant: "destructive"
      });
    }
  };

  const handleMarkReady = async (orderId: string, order: Order) => {
    console.log('✅ Marking order as ready:', orderId);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const updateRes = await fetch(`${apiUrl}/api/orders/${orderId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'ready' })
      });

      if (!updateRes.ok) throw new Error('Failed to update order');
      const updateData = await updateRes.json();
      const updateErrors = null;

      if (updateErrors) {
        console.error('❌ Error updating order:', updateErrors);
        throw new Error('Failed to update order');
      }

      console.log('✅ Order marked as ready:', updateData);

      // Then notify riders
      await notifyRiders(order);

      toast({
        title: "Order Ready",
        description: "Notifying available riders...",
      });
    } catch (error) {
      console.error('❌ Error marking as ready:', error);
      toast({
        title: "Error",
        description: "Failed to update order",
        variant: "destructive"
      });
    }
  };

  const notifyRiders = async (order: Order) => {
    try {
      console.log('🚴 Starting rider notification process...');
      console.log('📍 Order delivery zone:', order.deliveryZone);
      console.log('🏪 Restaurant zone:', restaurantZone);

      // Use restaurant zone as primary
      let targetZone = restaurantZone || 'Dhaka';

      console.log('🎯 Target zone for riders:', targetZone);

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const ridersRes = await fetch(`${apiUrl}/api/riders?status=approved&isOnline=true`);
      if (!ridersRes.ok) throw new Error('Failed to fetch riders');
      const riders = await ridersRes.json();
      const errors = null;

      if (errors) {
        console.error('❌ Error fetching riders:', errors);
        toast({
          title: "Error",
          description: "Failed to fetch riders",
          variant: "destructive"
        });
        return;
      }

      console.log('👥 Total online approved riders:', riders?.length || 0);

      if (!riders || riders.length === 0) {
        console.warn('⚠️ No online riders found');
        toast({
          title: "No Riders Available",
          description: "No online riders found at the moment",
          variant: "destructive"
        });
        return;
      }

      // Log all riders for debugging
      riders.forEach((rider: any) => {
        console.log(`  Rider: ${rider.fullName} | Zone: "${rider.zone}" | Online: ${rider.isOnline} | Status: ${rider.status}`);
      });

      // Filter riders by zone (flexible matching)
      const ridersInZone = riders.filter((rider: any) => {
        const riderZone = rider.zone?.trim() || '';

        // Match logic: exact match OR both are Dhaka/empty
        const isMatch =
          riderZone === targetZone ||
          (riderZone === '' && targetZone === 'Dhaka') ||
          (riderZone === 'Dhaka' && targetZone === '') ||
          riderZone === 'Dhaka' || // Accept Dhaka riders for any zone
          targetZone === 'Dhaka';

        console.log(`  🔍 Checking ${rider.fullName}: zone="${riderZone}" vs target="${targetZone}" → ${isMatch ? '✅ MATCH' : '❌ NO MATCH'}`);

        return isMatch;
      });

      console.log(`✅ Riders in target zone: ${ridersInZone.length}`);

      if (ridersInZone.length === 0) {
        console.warn(`⚠️ No riders available in ${targetZone}`);
        toast({
          title: "No Riders in Zone",
          description: `No riders available in ${targetZone}. Order is ready but awaiting rider.`,
          variant: "destructive"
        });
        return;
      }

      // Create notification for each rider
      console.log('📢 Creating notifications...');
      const notificationPromises = ridersInZone.map(async (rider: any) => {
        console.log(`  📨 Creating notification for: ${rider.fullName} (${rider.id})`);

        try {
          const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
          const createRes = await fetch(`${apiUrl}/api/rider-notifications`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              riderId: rider.id,
              orderId: order.id,
              restaurantName: order.restaurantName,
              customerAddress: order.customerAddress,
              orderTotal: order.total,
              message: `New delivery available: ${order.restaurantName} → ${order.customerAddress}`,
              isRead: false,
              createdAt: new Date().toISOString(),
            })
          });

          if (!createRes.ok) {
            const result = { errors: ['Failed to create notification'] };
            console.error(`  ❌ Failed for ${rider.fullName}:`, result.errors);
            return result;
          }

          const result = await createRes.json();
          console.log(`  ✅ Notification created for ${rider.fullName}`);
          return result;
        } catch (error) {
          console.error(`  ❌ Error creating notification for ${rider.fullName}:`, error);
          return { errors: [error] };
        }
      });

      const results = await Promise.all(notificationPromises);

      // Count successes
      const successCount = results.filter(r => !r.errors).length;
      const failureCount = results.filter(r => r.errors).length;

      console.log(`📊 Notification results: ${successCount} success, ${failureCount} failed`);

      if (successCount === 0) {
        toast({
          title: "Notification Failed",
          description: "Failed to notify riders. Please try again.",
          variant: "destructive"
        });
      } else {
        toast({
          title: "Riders Notified",
          description: `${successCount} rider(s) have been notified`,
        });
      }

      console.log('✅ Notification process complete');
    } catch (error) {
      console.error('❌ Error in notifyRiders:', error);
      toast({
        title: "Error",
        description: "Failed to notify riders",
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

  const getStatusBadge = (status: string) => {
    const variants: Record<string, any> = {
      pending: 'default',
      accepted: 'default',
      preparing: 'default',
      ready: 'default',
      assigned: 'secondary',
      picked_up: 'secondary',
      delivering: 'secondary',
      delivered: 'default',
      cancelled: 'destructive',
      rejected: 'destructive',
    };

    return <Badge variant={variants[status] || 'secondary'}>{status.toUpperCase()}</Badge>;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  const pendingOrders = orders.filter(o => o.status === 'pending');
  const activeOrders = orders.filter(o => ['accepted', 'preparing', 'ready', 'assigned', 'picked_up', 'delivering'].includes(o.status));
  const completedOrders = orders.filter(o => o.status === 'delivered');
  const cancelledOrders = orders.filter(o => ['cancelled', 'rejected'].includes(o.status));

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-4xl font-bold font-headline">Order Management</h1>
        <p className="text-muted-foreground mt-2 text-lg">
          Manage all incoming orders in real-time
        </p>
        {restaurantZone && (
          <p className="text-sm text-muted-foreground mt-1">
            Your zone: <Badge variant="outline">{restaurantZone}</Badge>
          </p>
        )}
      </div>

      <Tabs defaultValue="pending">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="pending">Pending ({pendingOrders.length})</TabsTrigger>
          <TabsTrigger value="active">Active ({activeOrders.length})</TabsTrigger>
          <TabsTrigger value="completed">Completed ({completedOrders.length})</TabsTrigger>
          <TabsTrigger value="cancelled">Cancelled ({cancelledOrders.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="pending" className="mt-6">
          {pendingOrders.length === 0 ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-12">
                <Package className="h-12 w-12 text-muted-foreground mb-4" />
                <p className="text-muted-foreground">No pending orders</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
              {pendingOrders.map(order => (
                <OrderCard
                  key={order.id}
                  order={order}
                  onAccept={() => {
                    setSelectedOrder(order);
                    setAcceptDialogOpen(true);
                  }}
                  onReject={() => {
                    setSelectedOrder(order);
                    setRejectDialogOpen(true);
                  }}
                  formatTime={formatTime}
                  getStatusBadge={getStatusBadge}
                />
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="active" className="mt-6">
          {activeOrders.length === 0 ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-12">
                <Clock className="h-12 w-12 text-muted-foreground mb-4" />
                <p className="text-muted-foreground">No active orders</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
              {activeOrders.map(order => (
                <ActiveOrderCard
                  key={order.id}
                  order={order}
                  onMarkPreparing={handleMarkPreparing}
                  onMarkReady={handleMarkReady}
                  formatTime={formatTime}
                  getStatusBadge={getStatusBadge}
                />
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="completed" className="mt-6">
          {completedOrders.length === 0 ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-12">
                <p className="text-muted-foreground">No completed orders</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
              {completedOrders.map(order => (
                <CompletedOrderCard
                  key={order.id}
                  order={order}
                  formatTime={formatTime}
                  getStatusBadge={getStatusBadge}
                />
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="cancelled" className="mt-6">
          {cancelledOrders.length === 0 ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-12">
                <p className="text-muted-foreground">No cancelled orders</p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
              {cancelledOrders.map(order => (
                <CancelledOrderCard
                  key={order.id}
                  order={order}
                  formatTime={formatTime}
                  getStatusBadge={getStatusBadge}
                />
              ))}
            </div>
          )}
        </TabsContent>
      </Tabs>

      {/* Accept Dialog */}
      <Dialog open={acceptDialogOpen} onOpenChange={setAcceptDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Accept Order</DialogTitle>
            <DialogDescription>
              Set estimated preparation time
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="prepTime">Preparation Time (minutes)</Label>
              <Input
                id="prepTime"
                type="number"
                min="5"
                max="120"
                value={prepTime}
                onChange={(e) => setPrepTime(parseInt(e.target.value) || 20)}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setAcceptDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleAcceptOrder} disabled={isAccepting}>
              {isAccepting ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Accept Order
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reject Dialog */}
      <Dialog open={rejectDialogOpen} onOpenChange={setRejectDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject Order</DialogTitle>
            <DialogDescription>
              Please provide a reason. Customer will be notified.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="reason">Rejection Reason *</Label>
              <Textarea
                id="reason"
                placeholder="e.g., Item out of stock, Kitchen closed"
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                rows={4}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRejectDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleRejectOrder}
              disabled={isRejecting || !rejectionReason.trim()}
            >
              {isRejecting ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Reject Order
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// Order Card Components
function OrderCard({ order, onAccept, onReject, formatTime, getStatusBadge }: any) {
  const items = JSON.parse(order.items);

  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-start">
          <div>
            <CardTitle className="text-lg">#{order.id.slice(0, 8)}</CardTitle>
            <p className="text-sm text-muted-foreground flex items-center gap-2 mt-1">
              <User className="h-4 w-4" /> {order.customerName}
            </p>
          </div>
          <div className="text-right">
            {getStatusBadge(order.status)}
            <p className="text-xs text-muted-foreground mt-1">{formatTime(order.createdAt)}</p>
          </div>
        </div>
      </CardHeader>

      <CardContent className="space-y-3">
        <Separator />

        <div className="space-y-2 text-sm">
          <div className="flex items-center gap-2">
            <Phone className="h-4 w-4 text-muted-foreground" />
            <span>{order.customerPhone}</span>
          </div>
          <div className="flex items-start gap-2">
            <MapPin className="h-4 w-4 text-muted-foreground mt-0.5" />
            <span className="text-muted-foreground">{order.customerAddress}</span>
          </div>
        </div>

        <Separator />

        <div className="space-y-2">
          {items.map((item: any, idx: number) => (
            <div key={idx} className="flex justify-between text-sm">
              <span>{item.quantity}x {item.name}</span>
              <span className="font-medium">Tk {(item.price * item.quantity).toFixed(2)}</span>
            </div>
          ))}
        </div>

        {order.noteToRestaurant && (
          <>
            <Separator />
            <div className="bg-muted p-3 rounded-md">
              <p className="text-sm font-medium">Note:</p>
              <p className="text-sm text-muted-foreground">{order.noteToRestaurant}</p>
            </div>
          </>
        )}

        <Separator />

        <div className="flex justify-between items-center">
          <span className="text-sm">Total</span>
          <span className="font-bold text-lg">Tk {order.total.toFixed(2)}</span>
        </div>
      </CardContent>

      <CardFooter className="bg-muted/50 p-3">
        <div className="grid grid-cols-2 gap-2 w-full">
          <Button variant="outline" onClick={onReject}>
            Reject
          </Button>
          <Button onClick={onAccept}>
            Accept
          </Button>
        </div>
      </CardFooter>
    </Card>
  );
}

function ActiveOrderCard({ order, onMarkPreparing, onMarkReady, formatTime, getStatusBadge }: any) {
  const items = JSON.parse(order.items);

  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-start">
          <CardTitle className="text-lg">#{order.id.slice(0, 8)}</CardTitle>
          <div className="text-right">
            {getStatusBadge(order.status)}
            <p className="text-xs text-muted-foreground mt-1">{formatTime(order.createdAt)}</p>
          </div>
        </div>
      </CardHeader>

      <CardContent className="space-y-3">
        <div className="space-y-1">
          {items.slice(0, 3).map((item: any, idx: number) => (
            <p key={idx} className="text-sm">{item.quantity}x {item.name}</p>
          ))}
        </div>

        <Separator />

        <div className="flex justify-between">
          <span className="text-sm">Total</span>
          <span className="font-bold">Tk {order.total.toFixed(2)}</span>
        </div>
      </CardContent>

      <CardFooter className="bg-muted/50 p-3">
        {order.status === 'accepted' && (
          <Button className="w-full" onClick={() => onMarkPreparing(order.id)}>
            Start Preparing
          </Button>
        )}
        {order.status === 'preparing' && (
          <Button className="w-full" onClick={() => onMarkReady(order.id, order)}>
            Mark as Ready
          </Button>
        )}
        {['ready', 'assigned', 'picked_up', 'delivering'].includes(order.status) && (
          <div className="w-full text-center text-sm text-muted-foreground">
            {order.status === 'ready' && 'Finding rider...'}
            {order.status === 'assigned' && 'Rider assigned'}
            {order.status === 'picked_up' && 'Rider picked up'}
            {order.status === 'delivering' && 'Out for delivery'}
          </div>
        )}
      </CardFooter>
    </Card>
  );
}

function CompletedOrderCard({ order, formatTime, getStatusBadge }: any) {
  const items = JSON.parse(order.items);

  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-start">
          <CardTitle className="text-lg">#{order.id.slice(0, 8)}</CardTitle>
          {getStatusBadge(order.status)}
        </div>
        <p className="text-xs text-muted-foreground">{formatTime(order.createdAt)}</p>
      </CardHeader>
      <CardContent className="space-y-2">
        <p className="text-sm">{items.length} item(s)</p>
        <p className="font-bold">Tk {order.total.toFixed(2)}</p>
      </CardContent>
    </Card>
  );
}

function CancelledOrderCard({ order, formatTime, getStatusBadge }: any) {
  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-start">
          <CardTitle className="text-lg">#{order.id.slice(0, 8)}</CardTitle>
          {getStatusBadge(order.status)}
        </div>
        <p className="text-xs text-muted-foreground">{formatTime(order.createdAt)}</p>
      </CardHeader>
      <CardContent className="space-y-2">
        {order.rejectionReason && (
          <div className="bg-destructive/10 p-3 rounded-md">
            <p className="text-sm font-medium">Reason:</p>
            <p className="text-sm">{order.rejectionReason}</p>
          </div>
        )}
        <p className="font-bold">Tk {order.total.toFixed(2)}</p>
      </CardContent>
    </Card>
  );
}
