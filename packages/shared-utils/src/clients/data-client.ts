export class DataClient {
    private baseUrl: string;
    private static instance: DataClient;

    private constructor(baseUrl: string = '/api') {
        this.baseUrl = baseUrl;
    }

    static getInstance(baseUrl?: string): DataClient {
        if (!DataClient.instance) {
            DataClient.instance = new DataClient(baseUrl);
        }
        return DataClient.instance;
    }

    private async request<T>(
        endpoint: string,
        options?: RequestInit
    ): Promise<T> {
        const accessToken = typeof window !== 'undefined' ? localStorage.getItem('accessToken') : null;

        const response = await fetch(`${this.baseUrl}${endpoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...(accessToken && { 'Authorization': `Bearer ${accessToken}` }),
                ...options?.headers,
            },
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Request failed');
        }

        const { data } = await response.json();
        return data;
    }

    // Restaurants
    async getRestaurants(params?: { status?: string; zone?: string; city?: string }) {
        const query = new URLSearchParams(params as any).toString();
        return this.request(`/restaurants${query ? `?${query}` : ''}`);
    }

    async getRestaurant(id: string) {
        return this.request(`/restaurants/${id}`);
    }

    async createRestaurant(data: any) {
        return this.request('/restaurants', {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateRestaurant(id: string, data: any) {
        return this.request(`/restaurants/${id}`, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    async deleteRestaurant(id: string) {
        return this.request(`/restaurants/${id}`, {
            method: 'DELETE',
        });
    }

    // Menu Items
    async getMenuItems(restaurantId: string) {
        return this.request(`/restaurants/${restaurantId}/menu`);
    }

    async createMenuItem(restaurantId: string, data: any) {
        return this.request(`/restaurants/${restaurantId}/menu`, {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateMenuItem(restaurantId: string, itemId: string, data: any) {
        return this.request(`/restaurants/${restaurantId}/menu/${itemId}`, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    async deleteMenuItem(restaurantId: string, itemId: string) {
        return this.request(`/restaurants/${restaurantId}/menu/${itemId}`, {
            method: 'DELETE',
        });
    }

    // Orders
    async getOrders(params?: { status?: string; restaurantId?: string; riderId?: string }) {
        const query = new URLSearchParams(params as any).toString();
        return this.request(`/orders${query ? `?${query}` : ''}`);
    }

    async getOrder(id: string) {
        return this.request(`/orders/${id}`);
    }

    async createOrder(data: any) {
        return this.request('/orders', {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateOrderStatus(id: string, status: string, additionalData?: any) {
        return this.request(`/orders/${id}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status, ...additionalData }),
        });
    }

    async assignRider(orderId: string, riderId: string) {
        return this.request(`/orders/${orderId}/assign-rider`, {
            method: 'PUT',
            body: JSON.stringify({ riderId }),
        });
    }

    // Riders
    async getRiders(params?: { status?: string; zone?: string; isOnline?: boolean }) {
        const query = new URLSearchParams(params as any).toString();
        return this.request(`/riders${query ? `?${query}` : ''}`);
    }

    async getRider(id: string) {
        return this.request(`/riders/${id}`);
    }

    async createRider(data: any) {
        return this.request('/riders', {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateRider(id: string, data: any) {
        return this.request(`/riders/${id}`, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    async updateRiderStatus(id: string, status: string) {
        return this.request(`/riders/${id}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status }),
        });
    }

    async updateRiderOnlineStatus(id: string, isOnline: boolean) {
        return this.request(`/riders/${id}/online-status`, {
            method: 'PUT',
            body: JSON.stringify({ isOnline }),
        });
    }

    // User Profile
    async getUserProfile() {
        return this.request('/users/profile');
    }

    async updateUserProfile(data: any) {
        return this.request('/users/profile', {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    // Addresses
    async getAddresses() {
        return this.request('/users/addresses');
    }

    async createAddress(data: any) {
        return this.request('/users/addresses', {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }

    async updateAddress(id: string, data: any) {
        return this.request(`/users/addresses/${id}`, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
    }

    async deleteAddress(id: string) {
        return this.request(`/users/addresses/${id}`, {
            method: 'DELETE',
        });
    }

    // Reviews
    async getReviews(restaurantId: string) {
        return this.request(`/restaurants/${restaurantId}/reviews`);
    }

    async createReview(restaurantId: string, data: any) {
        return this.request(`/restaurants/${restaurantId}/reviews`, {
            method: 'POST',
            body: JSON.stringify(data),
        });
    }
}

// Export singleton instance
export const dataClient = DataClient.getInstance();
