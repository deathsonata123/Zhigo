//src/app/rider/earnings/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../../components/ui/card";
import { Badge } from "../../components/ui/badge";
import { Separator } from "../../components/ui/separator";
import { Loader2, DollarSign, TrendingUp, Calendar, Wallet } from "lucide-react";
import { getCurrentUser } from '../../lib/auth';


type Order = {
    id: string;
    restaurantName: string;
    total: number;
    tip: number;
    status: string;
    deliveredAt?: string | null;
    createdAt: string;
};

export default function RiderEarningsPage() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        fetchEarnings();
    }, []);

    const fetchEarnings = async () => {
        setLoading(true);
        setError(null);
        try {
            const user = await getCurrentUser();

            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

            // Get rider profile
            const ridersRes = await fetch(`${apiUrl}/api/riders?userId=${user.userId}`);
            if (!ridersRes.ok) throw new Error('Failed to fetch rider');
            const riders = await ridersRes.json();

            if (!riders || riders.length === 0) {
                setError('No rider profile found');
                setLoading(false);
                return;
            }

            const rider = riders[0];

            // Get delivered orders
            const ordersRes = await fetch(`${apiUrl}/api/orders?riderId=${rider.id}&status=delivered`);
            if (!ordersRes.ok) throw new Error('Failed to fetch orders');
            const orderData = await ordersRes.json();
            if (orderData) {
                // Filter delivered orders and sort
                const deliveredOrders = orderData
                    .filter((o: any) => o.status === 'delivered')
                    .sort((a: any, b: any) =>
                        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
                    ) as Order[];

                setOrders(deliveredOrders);
            }
        } catch (error) {
            console.error('Error fetching earnings:', error);
            setError('Failed to load earnings');
        } finally {
            setLoading(false);
        }
    };

    const formatDate = (dateString: string) => {
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric'
            });
        } catch {
            return 'Unknown date';
        }
    };

    // Calculate earnings (simplified - assumes flat rate per delivery + tips)
    const deliveryFeePerOrder = 50; // Tk 50 per delivery
    const totalDeliveries = orders.length;
    const totalDeliveryFees = totalDeliveries * deliveryFeePerOrder;
    const totalTips = orders.reduce((sum, order) => sum + (Number(order.tip) || 0), 0);
    const totalEarnings = totalDeliveryFees + totalTips;

    // Group orders by date for history
    const ordersByDate = orders.reduce((acc, order) => {
        const date = formatDate(order.createdAt);
        if (!acc[date]) {
            acc[date] = [];
        }
        acc[date].push(order);
        return acc;
    }, {} as Record<string, Order[]>);

    if (loading) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <Loader2 className="h-8 w-8 animate-spin" />
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex items-center justify-center min-h-screen">
                <Card className="max-w-md">
                    <CardHeader>
                        <CardTitle>Error</CardTitle>
                        <CardDescription>{error}</CardDescription>
                    </CardHeader>
                </Card>
            </div>
        );
    }

    return (
        <div>
            <div className="mb-8">
                <h1 className="text-4xl font-bold font-headline">My Earnings</h1>
                <p className="text-muted-foreground mt-2 text-lg">
                    Track your earnings and delivery income.
                </p>
            </div>

            {/* Earnings Overview */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription className="flex items-center gap-2">
                            <DollarSign className="h-4 w-4" />
                            Total Earnings
                        </CardDescription>
                        <CardTitle className="text-3xl text-green-600">
                            Tk {totalEarnings.toFixed(2)}
                        </CardTitle>
                    </CardHeader>
                </Card>

                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription className="flex items-center gap-2">
                            <TrendingUp className="h-4 w-4" />
                            Delivery Fees
                        </CardDescription>
                        <CardTitle className="text-3xl">
                            Tk {totalDeliveryFees.toFixed(2)}
                        </CardTitle>
                    </CardHeader>
                </Card>

                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription className="flex items-center gap-2">
                            <Wallet className="h-4 w-4" />
                            Tips Earned
                        </CardDescription>
                        <CardTitle className="text-3xl">
                            Tk {totalTips.toFixed(2)}
                        </CardTitle>
                    </CardHeader>
                </Card>

                <Card>
                    <CardHeader className="pb-3">
                        <CardDescription className="flex items-center gap-2">
                            <Calendar className="h-4 w-4" />
                            Deliveries
                        </CardDescription>
                        <CardTitle className="text-3xl">
                            {totalDeliveries}
                        </CardTitle>
                    </CardHeader>
                </Card>
            </div>

            {/* Earning Breakdown */}
            <Card className="mb-8">
                <CardHeader>
                    <CardTitle>Earning Breakdown</CardTitle>
                    <CardDescription>How your earnings are calculated</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="flex justify-between items-center p-4 bg-muted rounded-lg">
                        <div>
                            <p className="font-medium">Delivery Fee (per order)</p>
                            <p className="text-sm text-muted-foreground">
                                {totalDeliveries} {totalDeliveries === 1 ? 'delivery' : 'deliveries'} × Tk {deliveryFeePerOrder}
                            </p>
                        </div>
                        <p className="font-bold text-lg">Tk {totalDeliveryFees.toFixed(2)}</p>
                    </div>

                    <div className="flex justify-between items-center p-4 bg-muted rounded-lg">
                        <div>
                            <p className="font-medium">Customer Tips</p>
                            <p className="text-sm text-muted-foreground">100% goes to you</p>
                        </div>
                        <p className="font-bold text-lg text-green-600">Tk {totalTips.toFixed(2)}</p>
                    </div>

                    <Separator />

                    <div className="flex justify-between items-center p-4 bg-primary/10 rounded-lg">
                        <p className="font-bold text-lg">Total Earnings</p>
                        <p className="font-bold text-2xl text-primary">Tk {totalEarnings.toFixed(2)}</p>
                    </div>
                </CardContent>
            </Card>

            {/* Delivery History */}
            <Card>
                <CardHeader>
                    <CardTitle>Delivery History</CardTitle>
                    <CardDescription>
                        {totalDeliveries > 0
                            ? `${totalDeliveries} completed ${totalDeliveries === 1 ? 'delivery' : 'deliveries'}`
                            : 'No completed deliveries yet'
                        }
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    {totalDeliveries === 0 ? (
                        <div className="text-center py-12">
                            <Wallet className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                            <p className="text-muted-foreground">No earnings yet</p>
                            <p className="text-sm text-muted-foreground mt-2">
                                Complete deliveries to start earning
                            </p>
                        </div>
                    ) : (
                        <div className="space-y-6">
                            {Object.entries(ordersByDate).map(([date, dateOrders]) => {
                                const dateEarnings = dateOrders.reduce(
                                    (sum, order) => sum + deliveryFeePerOrder + (Number(order.tip) || 0),
                                    0
                                );

                                return (
                                    <div key={date}>
                                        <div className="flex items-center justify-between mb-3">
                                            <div className="flex items-center gap-2">
                                                <Calendar className="h-4 w-4 text-muted-foreground" />
                                                <p className="font-semibold">{date}</p>
                                                <Badge variant="secondary">
                                                    {dateOrders.length} {dateOrders.length === 1 ? 'delivery' : 'deliveries'}
                                                </Badge>
                                            </div>
                                            <p className="font-bold text-green-600">Tk {dateEarnings.toFixed(2)}</p>
                                        </div>

                                        <div className="space-y-2 ml-6">
                                            {dateOrders.map((order) => {
                                                const orderEarning = deliveryFeePerOrder + (Number(order.tip) || 0);
                                                return (
                                                    <div key={order.id} className="flex justify-between items-center p-3 border rounded-lg hover:bg-muted/50 transition-colors">
                                                        <div>
                                                            <p className="font-medium">#{order.id.slice(0, 8)}</p>
                                                            <p className="text-sm text-muted-foreground">{order.restaurantName}</p>
                                                        </div>
                                                        <div className="text-right">
                                                            <p className="font-bold">Tk {orderEarning.toFixed(2)}</p>
                                                            {order.tip > 0 && (
                                                                <p className="text-xs text-green-600">+Tk {Number(order.tip).toFixed(2)} tip</p>
                                                            )}
                                                        </div>
                                                    </div>
                                                );
                                            })}
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Payout Info */}
            <Card className="mt-8">
                <CardHeader>
                    <CardTitle>Payout Information</CardTitle>
                    <CardDescription>How and when you get paid</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="flex items-start gap-3 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                        <DollarSign className="h-5 w-5 text-blue-600 mt-0.5" />
                        <div>
                            <p className="font-medium text-blue-900">Weekly Payouts</p>
                            <p className="text-sm text-blue-700">
                                Earnings are calculated weekly and paid out every Monday.
                            </p>
                        </div>
                    </div>

                    <div className="flex items-start gap-3 p-4 bg-green-50 border border-green-200 rounded-lg">
                        <Wallet className="h-5 w-5 text-green-600 mt-0.5" />
                        <div>
                            <p className="font-medium text-green-900">Payment Methods</p>
                            <p className="text-sm text-green-700">
                                Get paid directly to your bank account or mobile wallet.
                            </p>
                        </div>
                    </div>

                    <div className="flex items-start gap-3 p-4 bg-purple-50 border border-purple-200 rounded-lg">
                        <TrendingUp className="h-5 w-5 text-purple-600 mt-0.5" />
                        <div>
                            <p className="font-medium text-purple-900">Earn More</p>
                            <p className="text-sm text-purple-700">
                                Complete more deliveries and provide great service to earn more tips!
                            </p>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}