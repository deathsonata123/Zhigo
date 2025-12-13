'use client';

import { Amplify } from 'aws-amplify';
import { PropsWithChildren, useEffect, useState } from 'react';
// Make sure amplify_outputs.json is in packages/customer-mobile/
import outputs from '../amplify_outputs.json'; 

// Configure immediately
Amplify.configure(outputs, { ssr: true });

export default function Providers({ children }: PropsWithChildren) {
  const [configured, setConfigured] = useState(false);

  useEffect(() => {
    // Ensure configuration runs on mount
    Amplify.configure(outputs, { ssr: true });
    setConfigured(true);
  }, []);

  // Return a placeholder or null to prevent hydration errors while Amplify loads
  if (!configured) return <div className="min-h-screen w-full bg-background" />;

  return <>{children}</>;
}