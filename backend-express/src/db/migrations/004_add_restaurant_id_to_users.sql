-- Migration: Add restaurant_id to users table
-- This column links partner users to their restaurants

-- Add restaurant_id column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'restaurant_id'
    ) THEN
        ALTER TABLE users ADD COLUMN restaurant_id UUID;
        CREATE INDEX idx_users_restaurant_id ON users(restaurant_id);
        RAISE NOTICE 'Added restaurant_id column to users table';
    ELSE
        RAISE NOTICE 'restaurant_id column already exists in users table';
    END IF;
END $$;

-- Add foreign key constraint if restaurants table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'restaurants'
    ) THEN
        BEGIN
            ALTER TABLE users 
            ADD CONSTRAINT fk_users_restaurant 
            FOREIGN KEY (restaurant_id) 
            REFERENCES restaurants(id) 
            ON DELETE SET NULL;
            RAISE NOTICE 'Added foreign key constraint for restaurant_id';
        EXCEPTION
            WHEN duplicate_object THEN 
                RAISE NOTICE 'Foreign key constraint already exists';
        END;
    END IF;
END $$;

COMMENT ON COLUMN users.restaurant_id IS 'Links partner users to their restaurant';
