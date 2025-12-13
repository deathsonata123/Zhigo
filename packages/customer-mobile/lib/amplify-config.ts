import { generateClient } from 'aws-amplify/data';
import type { Schema } from '@food-delivery/shared-types';

// Export a strongly-typed client
export const client = generateClient<Schema>();