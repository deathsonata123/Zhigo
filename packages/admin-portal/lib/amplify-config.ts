'use client';

import { Amplify } from '@aws-amplify/core';
import { generateClient } from '@aws-amplify/api';
import outputs from '../amplify_outputs.json';

// Configure Amplify
Amplify.configure(outputs, {
  ssr: false
});

export const client = generateClient();

export default Amplify;