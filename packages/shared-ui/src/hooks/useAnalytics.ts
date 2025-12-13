'use client';
import { useState, useEffect } from 'react';
import type { AnalyticsData, AnalyticsPeriod } from '@food-delivery/shared-types';

export function useAnalytics(restaurantId: string, period: AnalyticsPeriod = 'today') {
  const [analytics, setAnalytics] = useState<AnalyticsData>({
    stats: {
      totalRevenue: 0,
      totalOrders: 0,
      averageOrderValue: 0,
      cancelledOrders: 0,
      completionRate: 0,
      averageRating: 0
    },
    salesData: [],
    bestSellers: [],
    busyHoursData: [],
    cancellationReasons: [],
    cancellationData: [],
    feedback: []
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchAnalytics = async () => {
      setLoading(true);
      try {
        // In a real app, use 'period' to filter the date range
        const { data: orders } = await client.models.Order.list({
          filter: { restaurantId: { eq: restaurantId } }
        });

        if (!orders) {
          setLoading(false);
          return;
        }

        // Calculate Stats
        const totalRevenue = orders.reduce((sum: number, order: any) => sum + (order.total || 0), 0);
        const totalOrders = orders.length;
        const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
        const cancelledOrders = orders.filter((o: any) => o.status === 'CANCELLED').length;
        const completionRate = totalOrders > 0 ? ((totalOrders - cancelledOrders) / totalOrders) * 100 : 0;
        const averageRating = 4.5;

        setAnalytics({
          stats: {
            totalRevenue,
            totalOrders,
            averageOrderValue,
            cancelledOrders,
            completionRate,
            averageRating
          },
          salesData: [
            { date: 'Mon', sales: 1200, orders: 45 },
            { date: 'Tue', sales: 1500, orders: 52 },
          ],
          // FIXED: Keys match models.ts (quantity, count)
          bestSellers: [
            { name: "Burger", quantity: 120, revenue: 1200 },
            { name: "Pizza", quantity: 80, revenue: 1600 }
          ],
          busyHoursData: [
            { hour: "12pm", count: 40 },
            { hour: "1pm", count: 55 },
            { hour: "7pm", count: 80 }
          ],
          cancellationReasons: [],
          cancellationData: [
            { name: "Out of stock", value: 5 },
            { name: "Customer changed mind", value: 3 }
          ],
          feedback: []
        });
      } catch (error) {
        console.error('Error fetching analytics:', error);
      } finally {
        setLoading(false);
      }
    };

    if (restaurantId) {
      fetchAnalytics();
    }
  }, [restaurantId, period]);

  return { analytics, loading };
}