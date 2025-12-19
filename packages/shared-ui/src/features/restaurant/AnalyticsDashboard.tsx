'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../../components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Button } from '../../components/ui/button';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from 'recharts';
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '../../components/ui/chart';
import {
  Utensils, Clock, MessageSquare, AlertTriangle, Star, DollarSign,
  ShoppingCart, Package, TrendingUp, Download, FileText, Printer
} from 'lucide-react';
import { useAnalytics } from '../../hooks/useAnalytics';

const PIE_COLORS = ["hsl(var(--chart-1))", "hsl(var(--chart-2))", "hsl(var(--chart-3))", "hsl(var(--chart-4))"];

// Mock hook if not available
const useRestaurantId = () => ({ restaurantId: "mock-id", loading: false });

export function AnalyticsDashboard() {
  const [period, setPeriod] = useState<'today' | 'this-week' | 'this-month'>('this-month');
  const { restaurantId, loading: restaurantLoading } = useRestaurantId();
  const { analytics, loading: analyticsLoading } = useAnalytics(restaurantId, period);

  const loading = restaurantLoading || analyticsLoading;

  const handleExportCSV = () => {
    const csvData = JSON.stringify(analytics, null, 2);
    const blob = new Blob([csvData], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'analytics.csv';
    a.click();
  };

  // Placeholder handlers
  const handleExportJSON = () => console.log("Export JSON not implemented");
  const printReport = () => window.print();

  if (loading) {
    return (
      <div className="space-y-8">
        <header>
          <h1 className="text-4xl font-bold font-headline tracking-tight">Analytics Dashboard</h1>
          <p className="text-muted-foreground mt-2 text-lg">Loading analytics data...</p>
        </header>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i}>
              <CardContent className="h-24 animate-pulse bg-muted/50" />
            </Card>
          ))}
        </div>
      </div>
    );
  }

  if (!restaurantId) {
    return (
      <div className="space-y-8">
        <header>
          <h1 className="text-4xl font-bold font-headline tracking-tight">Analytics Dashboard</h1>
          <p className="text-muted-foreground mt-2 text-lg">No restaurant found. Please register your restaurant first.</p>
        </header>
      </div>
    );
  }

  // Safe access to stats
  const stats = analytics?.stats || { totalRevenue: 0, totalOrders: 0, averageOrderValue: 0, cancelledOrders: 0, completionRate: 0, averageRating: 0 };
  const cancellationData = analytics?.cancellationData || [];
  const feedback = analytics?.feedback || [];
  const bestSellers = analytics?.bestSellers || [];

  return (
    <div className="space-y-8">
      {/* Header with Export Options */}
      <header className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-4xl font-bold font-headline tracking-tight">Analytics Dashboard</h1>
          <p className="text-muted-foreground mt-2 text-lg capitalize">
            {period.replace('-', ' ')}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={handleExportCSV}>
            <Download className="h-4 w-4 mr-2" />
            Export CSV
          </Button>
          <Button variant="outline" size="sm" onClick={handleExportJSON}>
            <FileText className="h-4 w-4 mr-2" />
            Export JSON
          </Button>
          <Button variant="outline" size="sm" onClick={printReport}>
            <Printer className="h-4 w-4 mr-2" />
            Print
          </Button>
        </div>
      </header>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${stats.totalRevenue.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              {stats.totalOrders} {stats.totalOrders === 1 ? 'order' : 'orders'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">Avg Order Value</CardTitle>
            <ShoppingCart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${stats.averageOrderValue.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground mt-1">Per completed order</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{(stats.completionRate || 0).toFixed(1)}%</div>
            <p className="text-xs text-muted-foreground mt-1">Successfully delivered</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">Average Rating</CardTitle>
            <Star className="h-4 w-4 text-amber-400 fill-amber-400" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold flex items-center gap-1">
              {(stats.averageRating || 0).toFixed(1)}
              <Star className="h-5 w-5 text-amber-400 fill-amber-400" />
            </div>
            <p className="text-xs text-muted-foreground mt-1">Customer satisfaction</p>
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
              <Select value={period} onValueChange={(val) => setPeriod(val as any)}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Select period" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="today">Today</SelectItem>
                  <SelectItem value="this-week">This Week</SelectItem>
                  <SelectItem value="this-month">This Month</SelectItem>
                </SelectContent>
              </Select>
            </CardHeader>
            <CardContent>
              <ChartContainer config={{ orders: { label: "Orders", color: "hsl(var(--primary))" } }} className="h-[250px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={analytics.salesData} margin={{ top: 20, right: 20, left: -10, bottom: 0 }}>
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
                <CardTitle>Cancellations</CardTitle>
                <CardDescription>Reasons breakdown</CardDescription>
              </CardHeader>
              <CardContent>
                {cancellationData.length > 0 ? (
                  <ResponsiveContainer width="100%" height={200}>
                    <PieChart>
                      <Pie
                        data={cancellationData}
                        cx="50%"
                        cy="50%"
                        labelLine={false}
                        label={({ name, value }) => `${name}: ${value}`}
                        outerRadius={80}
                        fill="#8884d8"
                        dataKey="value"
                      >
                        {cancellationData.map((entry: any, index: number) => (
                          <Cell key={`cell-${index}`} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                ) : (
                  <div className="flex items-center justify-center h-[200px] text-muted-foreground">
                    No cancellations
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Top Selling Items</CardTitle>
              <CardDescription>Best performing menu items</CardDescription>
            </CardHeader>
            <CardContent>
              {bestSellers.length > 0 ? (
                <div className="space-y-3">
                  {bestSellers.map((item: any, index: number) => (
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
              <CardTitle className="flex items-center gap-2">
                <MessageSquare className="h-5 w-5" />
                Recent Feedback
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {feedback.length > 0 ? (
                feedback.map((fb: any, i: number) => (
                  <div key={i} className="border-b last:border-0 pb-3 last:pb-0">
                    <div className="flex items-center gap-1 mb-1">
                      {Array.from({ length: 5 }).map((_, j) => (
                        <Star
                          key={j}
                          className={`h-3.5 w-3.5 ${j < fb.rating
                            ? 'text-amber-400 fill-amber-400'
                            : 'text-gray-300'
                            }`}
                        />
                      ))}
                    </div>
                    <p className="text-sm text-muted-foreground italic line-clamp-2">
                      "{fb.comment}"
                    </p>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">No feedback received yet</p>
              )}
            </CardContent>
          </Card>
        </aside>
      </div>
    </div>
  );
}
