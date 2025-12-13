// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: ApiError;
  message?: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: any;
}

// Pagination
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

export interface PaginationParams {
  page?: number;
  pageSize?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

// Filter Types
export interface OrderFilters {
  status?: string[];
  restaurantId?: string;
  riderId?: string;
  customerId?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface RestaurantFilters {
  cuisine?: string[];
  rating?: number;
  isActive?: boolean;
  search?: string;
}