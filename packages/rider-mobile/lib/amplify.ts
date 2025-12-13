import { generateClient } from 'aws-amplify/data';
import type { Schema } from '@food-delivery/shared-types';

// Export a strongly-typed client to use throughout the app
// This fixes the "Property does not exist" errors without needing 'as any'
export const client = generateClient<Schema>();