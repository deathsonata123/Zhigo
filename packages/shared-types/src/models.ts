export type UserRole = 'CUSTOMER' | 'RESTAURANT_OWNER' | 'RIDER' | 'ADMIN' | 'DEVELOPER';
export type OrderStatus = 'PENDING' | 'CONFIRMED' | 'PREPARING' | 'READY' | 'PICKED_UP' | 'DELIVERED' | 'CANCELLED';
export type ApprovalStatus = 'pending' | 'approved' | 'rejected';
export type AnalyticsPeriod = 'today' | 'this-week' | 'this-month' | 'week' | 'month' | 'year';

export interface UserProfile {
  id: string;
  userId: string;
  email: string;
  name?: string;
  phone?: string;
  role: UserRole;
  address?: string;
  photoUrl?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Restaurant {
  id: string;
  ownerId: string;
  name: string;
  address: string;
  phone?: string;
  email?: string;
  photoUrl?: string;
  status: ApprovalStatus;
  createdAt: string;
  updatedAt: string;
}

export interface MenuItem {
  id: string;
  restaurantId: string;
  name: string;
  description?: string;
  price: number;
  category: string;
  imageUrl?: string;
  isAvailable: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface OpeningHours {
  id: string;
  restaurantId: string;
  dayOfWeek: number;
  isOpen: boolean;
  openTime: string;
  closeTime: string;
  createdAt: string;
  updatedAt: string;
}

export interface Order {
  id: string;
  customerId: string;
  restaurantId: string;
  riderId?: string;
  items: any; 
  total: number;
  status: OrderStatus;
  deliveryAddress: string;
  customerName?: string;
  customerPhone?: string;
  specialInstructions?: string;
  estimatedDeliveryTime?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Rider {
  id: string;
  userId: string;
  name: string;
  phone?: string;
  vehicleType?: string;
  licensePlate?: string;
  status: ApprovalStatus;
  isAvailable: boolean;
  currentLocation?: { lat: number; lng: number };
  createdAt: string;
  updatedAt: string;
}

export interface Developer {
  id: string;
  userId: string;
  name: string;
  email: string;
  company?: string;
  apiKey?: string;
  status: ApprovalStatus;
  createdAt: string;
  updatedAt: string;
}

export interface Review {
  id: string;
  restaurantId: string;
  userId: string;
  userName?: string;
  rating: number;
  comment?: string;
  orderType?: string;
  createdAt: string;
  updatedAt: string;
}

export interface RiderNotification {
  id: string;
  riderId: string;
  orderId: string;
  restaurantName: string;
  customerAddress: string;
  orderTotal: number;
  message: string;
  isRead: boolean;
  isAccepted?: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface AnalyticsSummary {
  id: string;
  restaurantId: string;
  date: string;
  totalOrders: number;
  totalRevenue: number;
  cancelledOrders: number;
  completedOrders: number;
  averageOrderValue: number;
  topSellingItems?: any;
  hourlyOrderDistribution?: any;
  cancellationReasons?: any;
  createdAt: string;
  updatedAt: string;
}

export interface RiderPerformance {
  id: string;
  riderId: string;
  date: string;
  totalDeliveries: number;
  successfulDeliveries: number;
  cancelledDeliveries: number;
  lateDeliveries: number;
  averageDeliveryTime: number;
  averageRating: number;
  totalEarnings: number;
  totalDistance: number;
  onlineHours: number;
  createdAt: string;
  updatedAt: string;
}

export interface CustomerBehavior {
  id: string;
  customerId: string;
  restaurantId: string;
  totalOrders: number;
  totalSpent: number;
  averageOrderValue: number;
  lastOrderDate?: string;
  favoriteItems?: any; 
  preferredOrderTime?: string;
  preferredPaymentMethod?: string;
  averageRating: number;
  lifetimeValue: number;
  createdAt: string;
  updatedAt: string;
}

export interface SystemMetrics {
  id: string;
  date: string;
  totalOrders: number;
  totalRevenue: number;
  activeRestaurants: number;
  activeRiders: number;
  activeCustomers: number;
  averageDeliveryTime: number;
  platformCommission: number;
  cancelledOrdersRate: number;
  successRate: number;
  topPerformingRestaurants?: any;
  topPerformingRiders?: any;
  peakOrderHours?: any;
  createdAt: string;
  updatedAt: string;
}

export interface AnalyticsData {
  stats: {
    totalRevenue: number;
    totalOrders: number;
    averageOrderValue: number;
    cancelledOrders: number;
    completionRate: number;
    averageRating: number;
  };
  salesData: Array<{ date: string; sales: number; orders: number }>;
  bestSellers: Array<{ name: string; quantity: number; revenue: number }>;
  busyHoursData: Array<{ hour: string; count: number }>;
  cancellationReasons: Array<{ reason: string; count: number }>;
  cancellationData?: Array<{ name: string; value: number }>;
  feedback: Array<{ userName: string; rating: number; comment: string; createdAt: string }>;
}