'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from 'recharts';
import { AlertCircle, CheckCircle2, CircleDollarSign, Clock, CookingPot, Star, XCircle, TrendingUp, Package, Users, Bike, DollarSign } from 'lucide-react';
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '../../components/ui/chart';


interface DashboardStats {
  totalOrders: number;
  totalRevenue: number;
  pendingOrders: number;
  preparingOrders: number;
  deliveredOrders: number;
  cancelledOrders: number;
  avgDeliveryTime: number;
  acceptanceRate: number;
  avgRating: number;
  commission: number;
  netRevenue: number;
  activeRiders: number;
  totalMenuItems: number;
  availableMenuItems: number;
}

interface OrderTrend {
  date: string;
  orders: number;
  revenue: number;
}

interface TopMenuItem {
  name: string;
  quantity: number;
  revenue: number;
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];

const chartConfig = {
  orders: { label: "Orders", color: "hsl(var(--primary))" },
  revenue: { label: "Revenue", color: "hsl(var(--chart-2))" },
};

export function RestaurantDashboard() {
  const [loading, setLoading] = useState(true);
  const [period, setPeriod] = useState('this-month');
  const [stats, setStats] = useState<DashboardStats>({
    totalOrders: 0,
    totalRevenue: 0,
    pendingOrders: 0,
    preparingOrders: 0,
    deliveredOrders: 0,
    cancelledOrders: 0,
    avgDeliveryTime: 0,
    acceptanceRate: 0,
    avgRating: 0,
    commission: 0,
    netRevenue: 0,
    activeRiders: 0,
    totalMenuItems: 0,
    availableMenuItems: 0,
  });
  const [orderTrends, setOrderTrends] = useState<OrderTrend[]>([]);
  const [topItems, setTopItems] = useState<TopMenuItem[]>([]);
  const [statusDistribution, setStatusDistribution] = useState<any[]>([]);

  useEffect(() => {
    fetchDashboardData();
  }, [period]);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';

      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants`);
      if (!restaurantsRes.ok) throw new Error('Failed to fetch restaurants');
      const restaurants = await restaurantsRes.json();

      if (restaurants && restaurants.length > 0) {
        const restaurant = restaurants[0];

        const ordersRes = await fetch(`${apiUrl}/api/orders?restaurantId=${restaurant.id}`);
        if (!ordersRes.ok) throw new Error('Failed to fetch orders');
        const orders = await ordersRes.json();

        const menuItemsRes = await fetch(`${apiUrl}/api/menu-items?restaurantId=${restaurant.id}`);
        if (!menuItemsRes.ok) throw new Error('Failed to fetch menu items');
        const menuItems = await menuItemsRes.json();

        const reviewsRes = await fetch(`${apiUrl}/api/reviews?restaurantId=${restaurant.id}`);
        if (!reviewsRes.ok) throw new Error('Failed to fetch reviews');
        const reviews = await reviewsRes.json();

        const ridersRes = await fetch(`${apiUrl}/api/riders?status=approved`);
        if (!ridersRes.ok) throw new Error('Failed to fetch riders');
        const riders = await ridersRes.json();

        const now = new Date();
        let startDate = new Date();

        switch (period) {
          case 'today':
            startDate.setHours(0, 0, 0, 0);
            break;
          case 'this-week':
            startDate.setDate(now.getDate() - 7);
            break;
          case 'this-month':
            startDate.setMonth(now.getMonth() - 1);
            break;
          case 'this-year':
            startDate.setFullYear(now.getFullYear() - 1);
            break;
        }

        // FIX: Explicit any
        const filteredOrders = orders.filter((order: any) =>
          new Date(order.createdAt!).getTime() >= startDate.getTime()
        );

        // FIX: Explicit any for reduce
        const totalRevenue = filteredOrders.reduce((sum: number, order: any) => sum + (order.total || 0), 0);
        const commission = totalRevenue * 0.15;
        const netRevenue = totalRevenue - commission;

        // FIX: Explicit any for filters
        const pendingOrders = filteredOrders.filter((o: any) => o.status === 'pending').length;
        const preparingOrders = filteredOrders.filter((o: any) =>
          ['accepted', 'preparing', 'ready'].includes(o.status || '')
        ).length;
        const deliveredOrders = filteredOrders.filter((o: any) => o.status === 'delivered').length;
        const cancelledOrders = filteredOrders.filter((o: any) =>
          ['cancelled', 'rejected'].includes(o.status || '')
        ).length;

        const totalRequests = filteredOrders.length;
        const accepted = filteredOrders.filter((o: any) => o.status !== 'rejected').length;
        const acceptanceRate = totalRequests > 0 ? (accepted / totalRequests) * 100 : 0;

        const avgRating = reviews.length > 0
          ? reviews.reduce((sum: number, r: any) => sum + (r.rating || 0), 0) / reviews.length
          : 0;

        const deliveredWithTime = filteredOrders.filter((o: any) =>
          o.status === 'delivered' && o.deliveredAt && o.createdAt
        );
        const avgDeliveryTime = deliveredWithTime.length > 0
          ? deliveredWithTime.reduce((sum: number, o: any) => {
            const diff = new Date(o.deliveredAt!).getTime() - new Date(o.createdAt!).getTime();
            return sum + diff / (1000 * 60);
          }, 0) / deliveredWithTime.length
          : 0;

        setStats({
          totalOrders: filteredOrders.length,
          totalRevenue,
          pendingOrders,
          preparingOrders,
          deliveredOrders,
          cancelledOrders,
          avgDeliveryTime: Math.round(avgDeliveryTime),
          acceptanceRate: Math.round(acceptanceRate),
          avgRating: Math.round(avgRating * 10) / 10,
          commission,
          netRevenue,
          activeRiders: riders.length,
          totalMenuItems: menuItems.length,
          // FIX: Explicit any
          availableMenuItems: menuItems.filter((m: any) => m.isAvailable).length,
        });

        const trendMap = new Map<string, { orders: number; revenue: number }>();
        // FIX: Explicit any
        filteredOrders.forEach((order: any) => {
          const date = new Date(order.createdAt!).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric'
          });
          const existing = trendMap.get(date) || { orders: 0, revenue: 0 };
          trendMap.set(date, {
            orders: existing.orders + 1,
            revenue: existing.revenue + (order.total || 0)
          });
        });

        const trends = Array.from(trendMap.entries())
          .map(([date, data]) => ({ date, ...data }))
          .slice(-7);

        setOrderTrends(trends);

        const itemMap = new Map<string, { quantity: number; revenue: number }>();
        // FIX: Explicit any
        filteredOrders.forEach((order: any) => {
          const items = JSON.parse(order.items as any) as any[];
          items.forEach(item => {
            const existing = itemMap.get(item.name) || { quantity: 0, revenue: 0 };
            itemMap.set(item.name, {
              quantity: existing.quantity + (item.quantity || 1),
              revenue: existing.revenue + (item.price * (item.quantity || 1))
            });
          });
        });

        const topItemsList = Array.from(itemMap.entries())
          .map(([name, data]) => ({ name, ...data }))
          .sort((a, b) => b.revenue - a.revenue)
          .slice(0, 5);

        setTopItems(topItemsList);

        const statusDist = [
          { name: 'Pending', value: pendingOrders, color: '#FFBB28' },
          { name: 'Preparing', value: preparingOrders, color: '#0088FE' },
          { name: 'Delivered', value: deliveredOrders, color: '#00C49F' },
          { name: 'Cancelled', value: cancelledOrders, color: '#FF8042' },
        ].filter(item => item.value > 0);

        setStatusDistribution(statusDist);

      }
      } catch (error) {
        console.error('Error fetching dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };

    if (loading) {
      return (
        <div className="flex items-center justify-center h-screen">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      );
    }

    return (
      <div>
        <header className="mb-8">
          <h1 className="text-4xl font-bold font-headline tracking-tight">Dashboard</h1>
          <p className="text-muted-foreground mt-2 text-lg">Real-time overview of your restaurant's performance.</p>
        </header>

        {/* Top Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Total Orders</CardTitle>
              <Package className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.totalOrders}</div>
              <p className="text-xs text-muted-foreground mt-1">
                {stats.deliveredOrders} delivered
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
              <TrendingUp className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold flex items-center">
                <CircleDollarSign className="h-5 w-5 mr-1" />
                {stats.totalRevenue.toFixed(2)}
              </div>
              <p className="text-xs text-green-600 mt-1">
                Net: ${stats.netRevenue.toFixed(2)}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Active Riders</CardTitle>
              <Bike className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.activeRiders}</div>
              <p className="text-xs text-muted-foreground mt-1">
                Online now
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Customer Rating</CardTitle>
              <Star className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.avgRating} / 5</div>
              <p className="text-xs text-muted-foreground mt-1">
                {stats.acceptanceRate}% acceptance rate
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content Column */}
          <div className="lg:col-span-2 space-y-6">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle>Order Trends</CardTitle>
                  <CardDescription>Orders and revenue over time</CardDescription>
                </div>
                <Select value={period} onValueChange={setPeriod}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Select period" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="today">Today</SelectItem>
                    <SelectItem value="this-week">This Week</SelectItem>
                    <SelectItem value="this-month">This Month</SelectItem>
                    <SelectItem value="this-year">This Year</SelectItem>
                  </SelectContent>
                </Select>
              </CardHeader>
              <CardContent>
                <ChartContainer config={chartConfig} className="h-[250px] w-full">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={orderTrends} margin={{ top: 20, right: 20, left: -10, bottom: 0 }}>
                      <CartesianGrid strokeDasharray="3 3" vertical={false} />
                      <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} />
                      <YAxis tickLine={false} axisLine={false} tickMargin={8} />
                      <Tooltip content={<ChartTooltipContent />} />
                      <Line type="monotone" dataKey="orders" stroke="var(--color-orders)" strokeWidth={2} dot={{ r: 4 }} />
                    </LineChart>
                  </ResponsiveContainer>
                </ChartContainer>
              </CardContent>
            </Card>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Order Status</CardTitle>
                  <CardDescription>Current order distribution</CardDescription>
                </CardHeader>
                <CardContent>
                  {statusDistribution.length > 0 ? (
                    <ResponsiveContainer width="100%" height={200}>
                      <PieChart>
                        <Pie
                          data={statusDistribution}
                          cx="50%"
                          cy="50%"
                          labelLine={false}
                          label={({ name, value }) => `${name}: ${value}`}
                          outerRadius={80}
                          fill="#8884d8"
                          dataKey="value"
                        >
                          {statusDistribution.map((entry, index) => (
                            <Cell key={`cell-${index}`} fill={entry.color} />
                          ))}
                        </Pie>
                        <Tooltip />
                      </PieChart>
                    </ResponsiveContainer>
                  ) : (
                    <div className="flex items-center justify-center h-[200px] text-muted-foreground">
                      No orders yet
                    </div>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Performance Stats</CardTitle>
                  <CardDescription>Key operational metrics</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Clock className="h-5 w-5" />
                      <span className="font-medium">Avg. Delivery Time</span>
                    </div>
                    <span className="font-bold text-lg">{stats.avgDeliveryTime} min</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <CheckCircle2 className="h-5 w-5" />
                      <span className="font-medium">Order Acceptance</span>
                    </div>
                    <span className="font-bold text-lg">{stats.acceptanceRate}%</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Users className="h-5 w-5" />
                      <span className="font-medium">Menu Items</span>
                    </div>
                    <span className="font-bold text-lg">{stats.availableMenuItems}/{stats.totalMenuItems}</span>
                  </div>
                </CardContent>
              </Card>
            </div>

            <Card>
              <CardHeader>
                <CardTitle>Top Selling Items</CardTitle>
                <CardDescription>Best performing menu items</CardDescription>
              </CardHeader>
              <CardContent>
                {topItems.length > 0 ? (
                  <div className="space-y-3">
                    {topItems.map((item, index) => (
                      <div key={index} className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
                        <div className="flex items-center gap-3">
                          <div className="flex items-center justify-center w-8 h-8 rounded-full bg-primary/10 text-primary font-bold">
                            {index + 1}
                          </div>
                          <div>
                            <p className="font-medium">{item.name}</p>
                            <p className="text-sm text-muted-foreground">{item.quantity} sold</p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="font-bold flex items-center">
                            <DollarSign className="h-4 w-4 mr-1" />
                            {item.revenue.toFixed(2)}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center text-muted-foreground py-8">
                    No sales data available
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Right Sidebar Column */}
          <aside className="lg:col-span-1 space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Quick Actions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                <button className="w-full p-3 text-left bg-primary/10 hover:bg-primary/20 rounded-lg transition-colors">
                  <p className="font-medium">View All Orders</p>
                  <p className="text-sm text-muted-foreground">Manage pending orders</p>
                </button>
                <button className="w-full p-3 text-left bg-primary/10 hover:bg-primary/20 rounded-lg transition-colors">
                  <p className="font-medium">Update Menu</p>
                  <p className="text-sm text-muted-foreground">Add or edit items</p>
                </button>
                <button className="w-full p-3 text-left bg-primary/10 hover:bg-primary/20 rounded-lg transition-colors">
                  <p className="font-medium">View Analytics</p>
                  <p className="text-sm text-muted-foreground">Detailed insights</p>
                </button>
              </CardContent>
            </Card>
          </aside>
        </div>
      </div>
    );
  }
