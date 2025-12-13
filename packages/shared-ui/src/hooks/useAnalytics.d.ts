import type { AnalyticsData, AnalyticsPeriod } from '@food-delivery/shared-types';
export declare const useAnalytics: (restaurantId: string | null, period: AnalyticsPeriod) => {
    analytics: AnalyticsData;
    loading: boolean;
};
export declare const useRestaurantId: () => {
    restaurantId: string | null;
    loading: boolean;
};
//# sourceMappingURL=useAnalytics.d.ts.map