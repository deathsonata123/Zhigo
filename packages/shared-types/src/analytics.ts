// packages/shared-types/src/analytics.ts
// ONLY TYPE DEFINITIONS - NO HOOKS OR RUNTIME CODE

import type { Schema } from './amplify-schema';

// Analytics Event Types
export type AnalyticsEventType = 
  | 'page_view'
  | 'user_signup'
  | 'user_login'
  | 'user_logout'
  | 'order_placed'
  | 'order_completed'
  | 'order_cancelled'
  | 'item_added_to_cart'
  | 'checkout_started'
  | 'payment_completed'
  | 'restaurant_viewed'
  | 'menu_item_viewed'
  | 'search_performed'
  | 'delivery_started'
  | 'delivery_completed';

export interface BaseAnalyticsEvent {
  eventType: AnalyticsEventType;
  timestamp: string;
  userId?: string;
  sessionId?: string;
  userAgent?: string;
  platform?: 'web' | 'ios' | 'android';
}

export interface PageViewEvent extends BaseAnalyticsEvent {
  eventType: 'page_view';
  pagePath: string;
  pageTitle: string;
  referrer?: string;
}

export interface UserEvent extends BaseAnalyticsEvent {
  eventType: 'user_signup' | 'user_login' | 'user_logout';
  userType: string;
  method?: 'email' | 'google' | 'facebook';
}

export interface OrderEvent extends BaseAnalyticsEvent {
  eventType: 'order_placed' | 'order_completed' | 'order_cancelled';
  orderId: string;
  restaurantId: string;
  totalAmount: number;
  itemCount: number;
  deliveryMethod?: 'pickup' | 'delivery';
}

export interface CartEvent extends BaseAnalyticsEvent {
  eventType: 'item_added_to_cart';
  menuItemId: string;
  restaurantId: string;
  quantity: number;
  price: number;
}

export interface CheckoutEvent extends BaseAnalyticsEvent {
  eventType: 'checkout_started' | 'payment_completed';
  cartValue: number;
  itemCount: number;
  paymentMethod?: 'cash' | 'card' | 'digital_wallet';
}

export interface RestaurantEvent extends BaseAnalyticsEvent {
  eventType: 'restaurant_viewed';
  restaurantId: string;
  restaurantName: string;
  source?: 'search' | 'recommendation' | 'direct';
}

export interface MenuItemEvent extends BaseAnalyticsEvent {
  eventType: 'menu_item_viewed';
  menuItemId: string;
  restaurantId: string;
  category: string;
  price: number;
}

export interface SearchEvent extends BaseAnalyticsEvent {
  eventType: 'search_performed';
  searchTerm: string;
  resultCount: number;
  category?: string;
}

export interface DeliveryEvent extends BaseAnalyticsEvent {
  eventType: 'delivery_started' | 'delivery_completed';
  orderId: string;
  riderId: string;
  estimatedTime?: number;
  actualTime?: number;
  distance?: number;
}

export type AnalyticsEvent = 
  | PageViewEvent
  | UserEvent
  | OrderEvent
  | CartEvent
  | CheckoutEvent
  | RestaurantEvent
  | MenuItemEvent
  | SearchEvent
  | DeliveryEvent;

// Analytics Data Types (for useAnalytics hook return value)
export interface AnalyticsData {
  salesData: Array<{ date: string; sales: number; orders: number }>;
  bestSellers: Array<{ name: string; orders: number; revenue: number }>;
  feedback: Array<{ rating: number; comment: string; createdAt: string }>;
  cancellationData: Array<{ name: string; value: number }>;
  busyHoursData: Array<{ hour: string; orders: number }>;
  stats: {
    totalRevenue: number;
    totalOrders: number;
    averageOrderValue: number;
    completionRate: number;
    totalMenuItems: number;
    averageRating: number;
  };
}

export type AnalyticsPeriod = 'today' | 'this-week' | 'this-month';

// Analytics Configuration Types
export interface AnalyticsConfig {
  enabled: boolean;
  endpoint?: string;
  batchSize?: number;
  flushInterval?: number;
}

export interface AnalyticsMetadata {
  environment: 'development' | 'staging' | 'production';
  appVersion: string;
  buildNumber?: string;
}