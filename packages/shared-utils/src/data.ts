
export interface AddonOption {
  id: string;
  name: string;
  price: number; // Can be 0 for no extra cost
}

export interface AddonGroup {
  id: string;
  name: string; // e.g., "Size", "Extra Toppings"
  type: 'single' | 'multiple'; // Can user select one or many?
  options: AddonOption[];
}

export interface ScheduleRule {
  id: string;
  days: ('Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri' | 'Sat' | 'Sun')[];
  startTime: string; // "HH:MM"
  endTime: string; // "HH:MM"
}

export interface MenuItem {
  id:string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: string;
  isAvailable: boolean;
  addonGroups?: AddonGroup[];
  scheduleRules?: ScheduleRule[];
}

// Represents a public-facing restaurant (a "Foodie Partner")
export interface Restaurant {
  id: string;
  name: string;
  cuisine: string;
  rating: number;
  address: string;
  imageUrl: string;
  latitude: number;
  longitude: number;
  menu: MenuItem[];
  ownerId: string;
}

    