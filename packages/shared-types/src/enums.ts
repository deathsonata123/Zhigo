// User Roles
export enum UserRole {
  ADMIN = 'admin',
  RESTAURANT = 'restaurant',
  RIDER = 'rider',
  CUSTOMER = 'customer',
}

// Order Status Enum
export enum OrderStatusEnum {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PREPARING = 'preparing',
  READY_FOR_PICKUP = 'ready_for_pickup',
  PICKED_UP = 'picked_up',
  ON_THE_WAY = 'on_the_way',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
}

// Payment Status
export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

// Vehicle Types
export enum VehicleType {
  BIKE = 'bike',
  MOTORCYCLE = 'motorcycle',
  CAR = 'car',
}