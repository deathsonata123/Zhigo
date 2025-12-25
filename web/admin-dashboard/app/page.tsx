'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function HomePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if admin user is stored
    const storedUser = localStorage.getItem('admin_user');

    if (storedUser) {
      const userData = JSON.parse(storedUser);
      if (userData.role === 'admin') {
        router.push('/dashboard');
        return;
      }
    }

    // Not logged in or not admin - go to login
    router.push('/login');
  }, [router]);

  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-spin h-8 w-8 border-4 border-cyan-500 border-t-transparent rounded-full"></div>
    </div>
  );
}
