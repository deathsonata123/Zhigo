import { DatabaseService } from '../client';
import { Order } from '../types';

export class OrderRepository {
    async findAll(filters?: {
        status?: string;
        restaurantId?: string;
        riderId?: string;
        limit?: number;
        offset?: number;
    }): Promise<Order[]> {
        const db = DatabaseService.getInstance();
        let query = 'SELECT * FROM orders WHERE 1=1';
        const params: any[] = [];
        let paramIndex = 1;

        if (filters?.status) {
            query += ` AND status = $${paramIndex++}`;
            params.push(filters.status);
        }

        if (filters?.restaurantId) {
            query += ` AND restaurant_id = $${paramIndex++}`;
            params.push(filters.restaurantId);
        }

        if (filters?.riderId) {
            query += ` AND rider_id = $${paramIndex++}`;
            params.push(filters.riderId);
        }

        query += ' ORDER BY created_at DESC';

        if (filters?.limit) {
            query += ` LIMIT $${paramIndex++}`;
            params.push(filters.limit);
        }

        if (filters?.offset) {
            query += ` OFFSET $${paramIndex++}`;
            params.push(filters.offset);
        }

        return await db.query<Order>(query, params);
    }

    async findById(id: string): Promise<Order | null> {
        const db = DatabaseService.getInstance();
        return await db.queryOne<Order>('SELECT * FROM orders WHERE id = $1', [id]);
    }

    async create(data: Partial<Order>): Promise<Order> {
        const db = DatabaseService.getInstance();
        const result = await db.query<Order>(
            `INSERT INTO orders (
        restaurant_id, restaurant_name, customer_name, customer_phone,
        customer_email, customer_address, restaurant_latitude, restaurant_longitude,
        customer_latitude, customer_longitude, delivery_zone, note_to_rider,
        note_to_restaurant, items, subtotal, delivery_fee, service_fee,
        vat, tip, total, payment_method, payment_status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12,
        $13, $14, $15, $16, $17, $18, $19, $20, $21, $22
      ) RETURNING *`,
            [
                data.restaurant_id,
                data.restaurant_name,
                data.customer_name,
                data.customer_phone,
                data.customer_email,
                data.customer_address,
                data.restaurant_latitude,
                data.restaurant_longitude,
                data.customer_latitude,
                data.customer_longitude,
                data.delivery_zone,
                data.note_to_rider,
                data.note_to_restaurant,
                JSON.stringify(data.items),
                data.subtotal,
                data.delivery_fee,
                data.service_fee,
                data.vat,
                data.tip || 0,
                data.total,
                data.payment_method || 'cod',
                data.payment_status || 'pending',
            ]
        );
        return result[0];
    }

    async updateStatus(
        id: string,
        status: string,
        additionalData?: Partial<Order>
    ): Promise<Order | null> {
        const db = DatabaseService.getInstance();
        const updates: any = { status, ...additionalData };

        // Set timestamp based on status
        if (status === 'accepted') updates.accepted_at = new Date();
        if (status === 'rejected') updates.rejected_at = new Date();
        if (status === 'picked_up') updates.picked_up_at = new Date();
        if (status === 'delivered') updates.delivered_at = new Date();

        const fields: string[] = [];
        const values: any[] = [];
        let paramIndex = 1;

        Object.entries(updates).forEach(([key, value]) => {
            if (value !== undefined) {
                fields.push(`${key} = $${paramIndex++}`);
                values.push(value);
            }
        });

        values.push(id);
        const query = `UPDATE orders SET ${fields.join(', ')} WHERE id = $${paramIndex} RETURNING *`;

        const result = await db.query<Order>(query, values);
        return result.length > 0 ? result[0] : null;
    }

    async assignRider(orderId: string, riderId: string): Promise<Order | null> {
        return this.updateStatus(orderId, 'assigned', {
            rider_id: riderId,
            rider_assigned_at: new Date(),
        } as any);
    }
}
