//src/app/rider/orders/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../../components/ui/card";
import { Badge } from "../../components/ui/badge";
import { Separator } from "../../components/ui/separator";
import { Loader2, Package, MapPin, Store, Calendar, DollarSign } from "lucide-react";
import { getCurrentUser } from 'aws-amplify/auth';


type Order = {
    id: string;
    restaurantName: string;
    customerName: string;
    customerAddress: string;
    total: number;
    status: string;
    deliveredAt?: string | null;
    createdAt: string;
};

export default function RiderOrdersPage() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [riderId, setRiderId] = useState<string | null>(null);

    useEffect(() => {
        fetchRiderOrders();
    }, []);

    const fetchRiderOrders = async () => {
        setLoading(true);
        try {
            const user = await getCurrentUser();
            
            // Get rider profile
            const { data: riders } = await client.models.Rider.list({
                filter: { userId: { eq: user.userId } }
            });

            if (!riders || riders.length === 0) {
                return;
            }

            const rider = riders[0];
            setRiderId(rider.id);

            // Get all orders for this rider
            const { data: orderData } = await client.models.Order.list({
                filter: { riderId: { eq: rider.id } }
            });

            if (orderData) {
                const sorted = (orderData as Order[]).sort((a, b) => 
                    new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
                );
                setOrders(sorted);
            }
        } catch (error) {
            console.error('Error fetching orders:', error);
        } finally {
            setLoading(false);
        }
    };

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const getStatusBadge = (status: string) => {
        const statusColors: Record<string, any> = {
            delivered: 'default',
            cancelled: 'destructive',
            rejected: 'destructive',
        };

        return (
            <Badge variant={statusColors[status] || 'secondary'}>
                {status.toUpperCase()}
            </Badge>
        );
    };

    const completedOrders = orders.filter(o => o.status === 'delivered');
    const cancelledOrders = orders.filter(o => ['cancelled', 'rejected'].includes(o.status));

    if (loading) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        );
    }

    return (
        <div>
            <div className="mb-8">
                <h1 className="text-4xl font-bold font-headline">My Orders</h1>
                <p className="text-muted-foreground mt-2 text-lg">
                    View your delivery history and completed orders.
                </p>
            </div>

            {/* Stats Overview */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription>Total Deliveries</CardDescription>
                        <CardTitle className="text-3xl">{orders.length}</CardTitle>
                    </CardHeader>
                </Card>
                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription>Completed</CardDescription>
                        <CardTitle className="text-3xl">{completedOrders.length}</CardTitle>
                    </CardHeader>
                </Card>
                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription>Cancelled</CardDescription>
                        <CardTitle className="text-3xl">{cancelledOrders.length}</CardTitle>
                    </CardHeader>
                </Card>
            </div>

            {/* Order History */}
            <Card>
                <CardHeader>
                    <CardTitle>Order History</CardTitle>
                    <CardDescription>
                        {orders.length > 0 
                            ? `${orders.length} delivery ${orders.length === 1 ? 'order' : 'orders'} completed`
                            : 'No delivery orders yet'
                        }
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    {orders.length === 0 ? (
                        <div className="text-center py-12">
                            <Package className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                            <p className="text-muted-foreground">No delivery history yet</p>
                            <p className="text-sm text-muted-foreground mt-2">
                                Your completed deliveries will appear here
                            </p>
                        </div>
                    ) : (
                        <div className="space-y-4">
                            {orders.map((order) => (
                                <div key={order.id} className="border rounded-lg p-4 hover:bg-muted/50 transition-colors">
                                    <div className="flex justify-between items-start mb-3">
                                        <div>
                                            <div className="flex items-center gap-2 mb-1">
                                                <p className="font-bold">#{order.id.slice(0, 8)}</p>
                                                {getStatusBadge(order.status)}
                                            </div>
                                            <p className="text-sm text-muted-foreground flex items-center gap-1">
                                                <Calendar className="h-3 w-3" />
                                                {formatDate(order.createdAt)}
                                            </p>
                                        </div>
                                        <div className="text-right">
                                            <p className="font-bold text-lg">Tk {order.total.toFixed(2)}</p>
                                        </div>
                                    </div>

                                    <Separator className="my-3" />

                                    <div className="space-y-2 text-sm">
                                        <div className="flex items-start gap-2">
                                            <Store className="h-4 w-4 text-muted-foreground mt-0.5" />
                                            <div>
                                                <p className="font-medium">Pickup</p>
                                                <p className="text-muted-foreground">{order.restaurantName}</p>
                                            </div>
                                        </div>
                                        <div className="flex items-start gap-2">
                                            <MapPin className="h-4 w-4 text-muted-foreground mt-0.5" />
                                            <div>
                                                <p className="font-medium">Delivery</p>
                                                <p className="text-muted-foreground">{order.customerAddress}</p>
                                            </div>
                                        </div>
                                    </div>

                                    {order.deliveredAt && (
                                        <>
                                            <Separator className="my-3" />
                                            <p className="text-xs text-muted-foreground">
                                                Delivered on {formatDate(order.deliveredAt)}
                                            </p>
                                        </>
                                    )}
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}