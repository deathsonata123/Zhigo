import type { 
  Restaurant, 
  MenuItem, 
  Order, 
  Rider, 
  UserProfile, 
  Developer, 
  Review,
  OpeningHours,
  // Add these if you have them in models.ts, otherwise the previous ones are enough for the errors shown
  RiderNotification,
  RiderPerformance,
  CustomerBehavior,
  SystemMetrics
} from './models';

// This matches the structure expected by generateClient<Schema>()
export type Schema = {
  Restaurant: Restaurant;
  MenuItem: MenuItem;
  Order: Order;
  Rider: Rider;
  UserProfile: UserProfile;
  Developer: Developer;
  Review: Review;
  OpeningHours: OpeningHours;
  // Optional: add these if you defined interfaces for them in models.ts
  RiderNotification: RiderNotification;
  RiderPerformance: RiderPerformance;
  CustomerBehavior: CustomerBehavior;
  SystemMetrics: SystemMetrics;
};

// Re-export specific types so they can be imported as 
// import { Schema } from '@food-delivery/shared-types'
export type { 
  Restaurant, 
  MenuItem, 
  Order, 
  Rider, 
  UserProfile, 
  Developer, 
  Review,
  OpeningHours,
  RiderNotification,
  RiderPerformance,
  CustomerBehavior,
  SystemMetrics
};



