'use client';

import React, { Suspense } from 'react';
import { RestaurantDetails } from '@food-delivery/shared-ui';
import { useSearchParams } from 'next/navigation';

// We separate the content component to wrap it in Suspense
function RestaurantContent() {
  const searchParams = useSearchParams();
  const id = searchParams.get('id');

  if (!id) return <div className="p-8 text-center">Restaurant not found</div>;

  return <RestaurantDetails restaurantId={id} />;
}

export default function RestaurantPage() {
  return (
    // Suspense is REQUIRED for useSearchParams in static builds
    <Suspense fallback={<div className="p-8 text-center">Loading...</div>}>
      <RestaurantContent />
    </Suspense>
  );
}