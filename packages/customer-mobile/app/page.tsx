'use client';

import { RestaurantListing } from '@food-delivery/shared-ui';

export default function HomePage() {
  return (
    <main className="min-h-screen bg-background">
      <RestaurantListing />
    </main>
  );
}