import { DatabaseService } from '../client';
import { Restaurant } from '../types';

export class RestaurantRepository {
    async findAll(filters?: {
        status?: string;
        zone?: string;
        city?: string;
        limit?: number;
        offset?: number;
    }): Promise<Restaurant[]> {
        const db = DatabaseService.getInstance();
        let query = 'SELECT * FROM restaurants WHERE 1=1';
        const params: any[] = [];
        let paramIndex = 1;

        if (filters?.status) {
            query += ` AND status = $${paramIndex++}`;
            params.push(filters.status);
        }

        if (filters?.zone) {
            query += ` AND zone = $${paramIndex++}`;
            params.push(filters.zone);
        }

        if (filters?.city) {
            query += ` AND city = $${paramIndex++}`;
            params.push(filters.city);
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

        return await db.query<Restaurant>(query, params);
    }

    async findById(id: string): Promise<Restaurant | null> {
        const db = DatabaseService.getInstance();
        return await db.queryOne<Restaurant>(
            'SELECT * FROM restaurants WHERE id = $1',
            [id]
        );
    }

    async findByOwnerId(ownerId: string): Promise<Restaurant[]> {
        const db = DatabaseService.getInstance();
        return await db.query<Restaurant>(
            'SELECT * FROM restaurants WHERE owner_id = $1 ORDER BY created_at DESC',
            [ownerId]
        );
    }

    async create(data: Partial<Restaurant>): Promise<Restaurant> {
        const db = DatabaseService.getInstance();
        const result = await db.query<Restaurant>(
            `INSERT INTO restaurants (
        name, email, phone, address, photo_url, owner_id,
        business_type, has_bin_vat, bin_vat_number, display_price_with_vat,
        account_holder_name, account_type, account_number, bank_name,
        branch_name, routing_number, zone, city, postal_code,
        pricing_plan, latitude, longitude
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
        $11, $12, $13, $14, $15, $16, $17, $18, $19,
        $20, $21, $22
      ) RETURNING *`,
            [
                data.name,
                data.email,
                data.phone,
                data.address,
                data.photo_url,
                data.owner_id,
                data.business_type,
                data.has_bin_vat,
                data.bin_vat_number,
                data.display_price_with_vat,
                data.account_holder_name,
                data.account_type,
                data.account_number,
                data.bank_name,
                data.branch_name,
                data.routing_number,
                data.zone,
                data.city,
                data.postal_code,
                data.pricing_plan,
                data.latitude,
                data.longitude,
            ]
        );
        return result[0];
    }

    async update(id: string, data: Partial<Restaurant>): Promise<Restaurant | null> {
        const db = DatabaseService.getInstance();
        const fields: string[] = [];
        const values: any[] = [];
        let paramIndex = 1;

        Object.entries(data).forEach(([key, value]) => {
            if (value !== undefined && key !== 'id' && key !== 'created_at' && key !== 'updated_at') {
                fields.push(`${key} = $${paramIndex++}`);
                values.push(value);
            }
        });

        if (fields.length === 0) {
            return this.findById(id);
        }

        values.push(id);
        const query = `UPDATE restaurants SET ${fields.join(', ')} WHERE id = $${paramIndex} RETURNING *`;

        const result = await db.query<Restaurant>(query, values);
        return result.length > 0 ? result[0] : null;
    }

    async delete(id: string): Promise<boolean> {
        const db = DatabaseService.getInstance();
        const result = await db.query('DELETE FROM restaurants WHERE id = $1', [id]);
        return true;
    }

    async updateStatus(id: string, status: 'pending' | 'approved' | 'rejected'): Promise<Restaurant | null> {
        return this.update(id, { status });
    }
}
