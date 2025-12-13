// Database Model Types
export interface Developer {
    id: string;
    user_id: string;
    email: string;
    display_name: string;
    company_name?: string;
    website?: string;
    github?: string;
    bio?: string;
    avatar_url?: string;
    status: 'pending' | 'approved' | 'rejected' | 'suspended';
    tier: 'free' | 'basic' | 'pro' | 'enterprise';
    total_earnings: number;
    current_balance: number;
    total_models: number;
    total_downloads: number;
    total_views: number;
    rating: number;
    total_reviews: number;
    payout_method?: string;
    payout_details?: any;
    notification_preferences?: any;
    created_at: Date;
    updated_at: Date;
}

export interface Model3D {
    id: string;
    developer_id: string;
    title: string;
    description: string;
    category: string;
    tags?: string[];
    model_url: string;
    thumbnail_url: string;
    preview_images?: string[];
    poly_count?: number;
    has_animations: boolean;
    animation_names?: string[];
    has_textures: boolean;
    texture_resolution?: string;
    file_size?: number;
    format: string;
    price: number;
    currency: string;
    license_type: string;
    views: number;
    downloads: number;
    likes: number;
    rating: number;
    review_count: number;
    status: 'draft' | 'pending' | 'approved' | 'rejected';
    rejection_reason?: string;
    is_featured: boolean;
    created_at: Date;
    updated_at: Date;
}

export interface UserProfile {
    id: string;
    user_id: string;
    email: string;
    full_name?: string;
    phone?: string;
    photo_url?: string;
    date_of_birth?: Date;
    bio?: string;
    created_at: Date;
    updated_at: Date;
}

export interface Address {
    id: string;
    user_id: string;
    label: string;
    street: string;
    city: string;
    state?: string;
    zip_code?: string;
    country: string;
    latitude?: number;
    longitude?: number;
    is_default: boolean;
    created_at: Date;
    updated_at: Date;
}

export interface Restaurant {
    id: string;
    name: string;
    email: string;
    phone: string;
    address: string;
    photo_url: string;
    owner_id: string;
    status: 'pending' | 'approved' | 'rejected';
    business_type?: string;
    has_bin_vat?: string;
    bin_vat_number?: string;
    display_price_with_vat?: string;
    account_holder_name?: string;
    account_type?: string;
    account_number?: string;
    bank_name?: string;
    branch_name?: string;
    routing_number?: string;
    zone?: string;
    city?: string;
    postal_code?: string;
    pricing_plan?: string;
    latitude?: number;
    longitude?: number;
    created_at: Date;
    updated_at: Date;
}

export interface MenuItem {
    id: string;
    restaurant_id: string;
    name: string;
    description: string;
    price: number;
    category: string;
    image_url: string;
    is_available: boolean;
    created_at: Date;
    updated_at: Date;
}

export interface OpeningHours {
    id: string;
    restaurant_id: string;
    day_of_week: number;
    is_open: boolean;
    open_time?: string;
    close_time?: string;
    created_at: Date;
    updated_at: Date;
}

export interface Review {
    id: string;
    restaurant_id: string;
    user_id: string;
    user_name: string;
    rating: number;
    comment?: string;
    order_type?: string;
    created_at: Date;
    updated_at: Date;
}

export interface Rider {
    id: string;
    full_name: string;
    email: string;
    phone: string;
    zone: string;
    user_id: string;
    status: 'pending' | 'approved' | 'rejected';
    is_online: boolean;
    birthday?: Date;
    gender?: string;
    present_address?: string;
    current_order_id?: string;
    total_deliveries: number;
    face_image_url?: string;
    nid_card_url?: string;
    nominee_nid_card_url?: string;
    has_motorbike?: boolean;
    vehicle_number?: string;
    driving_license_url?: string;
    bike_registration_url?: string;
    emergency_contact_name?: string;
    emergency_contact_number?: string;
    hear_about?: string;
    rider_captain_id?: string;
    created_at: Date;
    updated_at: Date;
}

export interface Order {
    id: string;
    restaurant_id: string;
    restaurant_name: string;
    customer_name: string;
    customer_phone: string;
    customer_email?: string;
    customer_address: string;
    restaurant_latitude?: number;
    restaurant_longitude?: number;
    customer_latitude?: number;
    customer_longitude?: number;
    delivery_zone: string;
    note_to_rider?: string;
    note_to_restaurant?: string;
    items: any;
    subtotal: number;
    delivery_fee: number;
    service_fee: number;
    vat: number;
    tip: number;
    total: number;
    payment_method: string;
    payment_status: string;
    payment_transaction_id?: string;
    status: string;
    accepted_at?: Date;
    rejected_at?: Date;
    rejection_reason?: string;
    prep_time?: number;
    rider_id?: string;
    rider_assigned_at?: Date;
    picked_up_at?: Date;
    delivered_at?: Date;
    created_at: Date;
    updated_at: Date;
}

export interface RiderNotification {
    id: string;
    rider_id: string;
    order_id: string;
    restaurant_name: string;
    customer_address: string;
    order_total: number;
    message: string;
    is_read: boolean;
    is_accepted?: boolean;
    created_at: Date;
}

export interface AnalyticsSummary {
    id: string;
    restaurant_id: string;
    date: Date;
    total_orders: number;
    total_revenue: number;
    cancelled_orders: number;
    completed_orders: number;
    average_order_value: number;
    top_selling_items?: any;
    hourly_order_distribution?: any;
    cancellation_reasons?: any;
    created_at: Date;
    updated_at: Date;
}

export interface RiderPerformance {
    id: string;
    rider_id: string;
    date: Date;
    total_deliveries: number;
    successful_deliveries: number;
    cancelled_deliveries: number;
    late_deliveries: number;
    average_delivery_time: number;
    average_rating: number;
    total_earnings: number;
    total_distance: number;
    online_hours: number;
    created_at: Date;
    updated_at: Date;
}

export interface CustomerBehavior {
    id: string;
    customer_id: string;
    restaurant_id: string;
    total_orders: number;
    total_spent: number;
    average_order_value: number;
    last_order_date?: Date;
    favorite_items?: any;
    preferred_order_time?: string;
    preferred_payment_method?: string;
    average_rating: number;
    lifetime_value: number;
    created_at: Date;
    updated_at: Date;
}

export interface SystemMetrics {
    id: string;
    date: Date;
    total_orders: number;
    total_revenue: number;
    active_restaurants: number;
    active_riders: number;
    active_customers: number;
    average_delivery_time: number;
    platform_commission: number;
    cancelled_orders_rate: number;
    success_rate: number;
    top_performing_restaurants?: any;
    top_performing_riders?: any;
    peak_order_hours?: any;
    created_at: Date;
    updated_at: Date;
}
