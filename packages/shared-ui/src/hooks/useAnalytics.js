// packages/shared-ui/src/hooks/useAnalytics.ts
"use client";
import { useState, useEffect } from 'react';
export const useAnalytics = (restaurantId, period) => {
    const [loading, setLoading] = useState(true);
    const [analytics, setAnalytics] = useState({
        salesData: [],
        bestSellers: [],
        feedback: [],
        cancellationData: [],
        busyHoursData: [],
        stats: {
            totalRevenue: 0,
            totalOrders: 0,
            averageOrderValue: 0,
            completionRate: 0,
            totalMenuItems: 0,
            averageRating: 0,
        },
    });
    useEffect(() => {
        if (!restaurantId)
            return;
        const fetchAnalytics = async () => {
            setLoading(true);
            try {
                const dateRange = getDateRange(period);
                const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
                const [ordersResult, menuItemsResult, reviewsResult] = await Promise.all([
                    fetch(`${apiUrl}/api/orders?restaurantId=${restaurantId}&createdAtGte=${dateRange.start.toISOString()}`).then(r => r.json()).then(orders => ({ data: orders })),
                    fetch(`${apiUrl}/api/menu-items?restaurantId=${restaurantId}`).then(r => r.json()).then(items => ({ data: items })),
                    fetch(`${apiUrl}/api/reviews?restaurantId=${restaurantId}&createdAtGte=${dateRange.start.toISOString()}`).then(r => r.json()).then(reviews => ({ data: reviews })),
                ]);
                const processedData = processAnalyticsData(ordersResult.data || [], menuItemsResult.data || [], reviewsResult.data || [], period);
                setAnalytics(processedData);
            }
            catch (error) {
                console.error('Error fetching analytics:', error);
            }
            finally {
                setLoading(false);
            }
        };
        fetchAnalytics();
    }, [restaurantId, period]);
    return { analytics, loading };
};
const getDateRange = (period) => {
    const now = new Date();
    const start = new Date();
    switch (period) {
        case 'today':
            start.setHours(0, 0, 0, 0);
            break;
        case 'this-week':
            start.setDate(now.getDate() - 7);
            break;
        case 'this-month':
            start.setDate(now.getDate() - 30);
            break;
    }
    return { start, end: now };
};
const processAnalyticsData = (orders, menuItems, reviews, period) => {
    const completedOrders = orders.filter(o => o.status === 'delivered');
    const cancelledOrders = orders.filter(o => o.status === 'cancelled' || o.status === 'rejected');
    const totalRevenue = completedOrders.reduce((sum, order) => sum + (order.total || 0), 0);
    const totalOrders = orders.length;
    const averageOrderValue = completedOrders.length > 0
        ? totalRevenue / completedOrders.length
        : 0;
    const completionRate = totalOrders > 0
        ? (completedOrders.length / totalOrders) * 100
        : 0;
    const avgRating = reviews.length > 0
        ? reviews.reduce((sum, r) => sum + (r.rating || 0), 0) / reviews.length
        : 0;
    const salesData = getSalesByPeriod(completedOrders, period);
    const bestSellers = calculateBestSellers(completedOrders);
    const busyHoursData = calculateBusyHours(completedOrders);
    const cancellationData = processCancellations(cancelledOrders);
    const feedback = reviews
        .sort((a, b) => new Date(b.createdAt || '').getTime() - new Date(a.createdAt || '').getTime())
        .slice(0, 3)
        .map(r => ({
        rating: r.rating || 0,
        comment: r.comment || 'No comment provided',
        createdAt: r.createdAt || new Date().toISOString(),
    }));
    return {
        salesData,
        bestSellers,
        feedback,
        cancellationData,
        busyHoursData,
        stats: {
            totalRevenue,
            totalOrders,
            averageOrderValue,
            completionRate,
            totalMenuItems: menuItems.length,
            averageRating: avgRating,
        },
    };
};
const getSalesByPeriod = (orders, period) => {
    const periodMap = new Map();
    orders.forEach(order => {
        const date = new Date(order.createdAt || '');
        let key;
        if (period === 'today') {
            key = `${String(date.getHours()).padStart(2, '0')}:00`;
        }
        else if (period === 'this-week') {
            const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            key = days[date.getDay()];
        }
        else {
            key = `${date.getMonth() + 1}/${date.getDate()}`;
        }
        const existing = periodMap.get(key) || { sales: 0, orders: 0 };
        periodMap.set(key, {
            sales: existing.sales + (order.total || 0),
            orders: existing.orders + 1,
        });
    });
    const sortedEntries = Array.from(periodMap.entries()).sort((a, b) => {
        if (period === 'today') {
            return a[0].localeCompare(b[0]);
        }
        else if (period === 'this-week') {
            const dayOrder = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            return dayOrder.indexOf(a[0]) - dayOrder.indexOf(b[0]);
        }
        else {
            const [aMonth, aDay] = a[0].split('/').map(Number);
            const [bMonth, bDay] = b[0].split('/').map(Number);
            return aMonth === bMonth ? aDay - bDay : aMonth - bMonth;
        }
    });
    return sortedEntries.map(([date, data]) => ({
        date,
        ...data,
    }));
};
const calculateBestSellers = (orders) => {
    const itemSales = new Map();
    orders.forEach(order => {
        try {
            const items = typeof order.items === 'string'
                ? JSON.parse(order.items)
                : order.items;
            if (Array.isArray(items)) {
                items.forEach((item) => {
                    const name = item.name || 'Unknown Item';
                    const quantity = item.quantity || 1;
                    const price = item.price || 0;
                    const existing = itemSales.get(name) || { orders: 0, revenue: 0 };
                    itemSales.set(name, {
                        orders: existing.orders + quantity,
                        revenue: existing.revenue + (price * quantity),
                    });
                });
            }
        }
        catch (error) {
            console.error('Error parsing order items:', error);
        }
    });
    return Array.from(itemSales.entries())
        .map(([name, data]) => ({ name, ...data }))
        .sort((a, b) => b.orders - a.orders)
        .slice(0, 5);
};
const calculateBusyHours = (orders) => {
    const hourlyOrders = new Map();
    orders.forEach(order => {
        const hour = new Date(order.createdAt || '').getHours();
        hourlyOrders.set(hour, (hourlyOrders.get(hour) || 0) + 1);
    });
    const peakHours = [11, 12, 13, 18, 19, 20, 21];
    return peakHours.map(hour => ({
        hour: hour > 12 ? `${hour - 12}pm` : hour === 12 ? '12pm' : `${hour}am`,
        orders: hourlyOrders.get(hour) || 0,
    }));
};
const processCancellations = (cancelledOrders) => {
    const reasonMap = new Map();
    cancelledOrders.forEach(order => {
        let reason = 'User Cancelled';
        if (order.rejectionReason) {
            reason = order.rejectionReason;
        }
        else if (order.status === 'rejected') {
            reason = 'Restaurant Rejected';
        }
        reasonMap.set(reason, (reasonMap.get(reason) || 0) + 1);
    });
    return Array.from(reasonMap.entries())
        .map(([name, value]) => ({ name, value }))
        .sort((a, b) => b.value - a.value)
        .slice(0, 4);
};
export const useRestaurantId = () => {
    const [restaurantId, setRestaurantId] = useState(null);
    const [loading, setLoading] = useState(true);
    useEffect(() => {
        const fetchRestaurantId = async () => {
            try {
                const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
                const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?status=approved&limit=1`);
                if (restaurantsRes.ok) {
                    const restaurants = await restaurantsRes.json();
                    if (restaurants && restaurants.length > 0) {
                        setRestaurantId(restaurants[0].id);
                    }
                }
            }
            catch (error) {
                console.error('Error fetching restaurant:', error);
            }
            finally {
                setLoading(false);
            }
        };
        fetchRestaurantId();
    }, []);
    return { restaurantId, loading };
};
