//src/components/ActiveDeliveryTracking.tsx
'use client';

import { useState, useEffect, useRef } from 'react';
import { ChevronDown, ChevronUp, MapPin, Phone, Navigation, MessageCircle } from 'lucide-react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN || '';

interface ActiveDeliveryTrackingProps {
  order: any;
  onArrivedAtRestaurant: () => Promise<void>;
  onConfirmPickup: () => Promise<void>;
  onArrivedAtCustomer: () => Promise<void>;
}

export default function ActiveDeliveryTracking({
  order: initialOrder,
  onArrivedAtRestaurant,
  onConfirmPickup,
  onArrivedAtCustomer
}: ActiveDeliveryTrackingProps) {
  const [order, setOrder] = useState(initialOrder);
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [updating, setUpdating] = useState(false);
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const riderMarker = useRef<mapboxgl.Marker | null>(null);

  // Use status instead of stage
  const status = order.status || 'assigned';

  useEffect(() => {
    // TODO: Implement real-time order updates via WebSocket or polling
    // For now, we use the prop updates
    setOrder(initialOrder);
  }, [initialOrder]);

  useEffect(() => {
    if (!mapContainer.current || isCollapsed) return;

    // Initialize map
    if (!map.current) {
      const lat = order.restaurantLatitude || 23.8103;
      const lng = order.restaurantLongitude || 90.4125;

      map.current = new mapboxgl.Map({
        container: mapContainer.current,
        style: 'mapbox://styles/mapbox/streets-v12',
        center: [lng, lat],
        zoom: 13
      });

      // Add rider marker
      riderMarker.current = new mapboxgl.Marker({ color: '#ec4899' })
        .setLngLat([lng, lat])
        .addTo(map.current);
    }

    return () => {
      if (map.current) {
        map.current.remove();
        map.current = null;
      }
    };
  }, [isCollapsed, order.restaurantLatitude, order.restaurantLongitude]);

  const handleStatusUpdate = async (callback: () => Promise<void>) => {
    setUpdating(true);
    try {
      await callback();
    } catch (error) {
      console.error('Error updating status:', error);
    } finally {
      setUpdating(false);
    }
  };

  if (isCollapsed) {
    return (
      <div className="fixed bottom-4 right-4 bg-white rounded-lg shadow-2xl border border-gray-200 p-4 w-80 z-50">
        <div className="flex justify-between items-center">
          <div>
            <p className="font-semibold text-gray-900">Active Delivery</p>
            <p className="text-sm text-gray-500">Order #{order.id.slice(0, 8)}</p>
          </div>
          <button
            onClick={() => setIsCollapsed(false)}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <ChevronUp className="w-5 h-5 text-gray-600" />
          </button>
        </div>
      </div>
    );
  }

  // Stage 1: Going to Restaurant (status: assigned)
  if (status === 'assigned') {
    return (
      <div className="fixed bottom-4 right-4 bg-white rounded-2xl shadow-2xl border border-gray-200 w-96 z-50 overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-pink-500 to-pink-600 p-4 flex justify-between items-center">
          <div className="text-white">
            <h3 className="font-bold text-lg">{order.restaurantName}</h3>
            <p className="text-sm text-pink-100">Going to restaurant</p>
          </div>
          <button
            onClick={() => setIsCollapsed(true)}
            className="p-2 hover:bg-white/20 rounded-full transition-colors"
          >
            <ChevronDown className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 space-y-4">
          {/* Restaurant Address */}
          <div className="flex items-start gap-3">
            <MapPin className="w-5 h-5 text-gray-600 mt-1 flex-shrink-0" />
            <div className="flex-1">
              <p className="text-sm text-gray-500">Restaurant Address</p>
              <p className="font-medium text-gray-900">{order.restaurantName}</p>
              <p className="text-xs text-gray-500 mt-1">
                {order.restaurantLatitude && order.restaurantLongitude
                  ? `${order.restaurantLatitude.toFixed(4)}, ${order.restaurantLongitude.toFixed(4)}`
                  : 'Location not available'}
              </p>
            </div>
          </div>

          {/* Arrival Time */}
          <div className="bg-gray-50 p-3 rounded-lg">
            <p className="text-center font-semibold text-gray-900">
              Arrive in 8 min
            </p>
          </div>

          {/* Map */}
          <div
            ref={mapContainer}
            className="w-full h-48 rounded-lg overflow-hidden"
          />

          {/* Action Button */}
          <button
            onClick={() => handleStatusUpdate(onArrivedAtRestaurant)}
            disabled={updating}
            className="w-full bg-pink-600 hover:bg-pink-700 disabled:bg-gray-400 text-white font-semibold py-3 rounded-xl transition-colors flex items-center justify-center gap-2"
          >
            <Navigation className="w-5 h-5" />
            {updating ? 'Updating...' : 'Arrived at the restaurant'}
          </button>
        </div>

        {/* Chat Icon */}
        <button className="absolute bottom-20 right-4 w-12 h-12 bg-pink-600 rounded-full shadow-lg flex items-center justify-center hover:bg-pink-700 transition-colors">
          <MessageCircle className="w-6 h-6 text-white" />
        </button>
      </div>
    );
  }

  // Stage 2: At Restaurant - Pickup (status: at_restaurant)
  if (status === 'at_restaurant') {
    const items = order.items ? JSON.parse(order.items) : [];

    return (
      <div className="fixed bottom-4 right-4 bg-white rounded-2xl shadow-2xl border border-gray-200 w-96 z-50 overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-pink-500 to-pink-600 p-4 flex justify-between items-center">
          <div className="text-white">
            <h3 className="font-bold text-lg">Pickup</h3>
          </div>
          <button
            onClick={() => setIsCollapsed(true)}
            className="p-2 hover:bg-white/20 rounded-full transition-colors"
          >
            <ChevronDown className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 space-y-4">
          {/* Restaurant Info */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <div className="flex items-start justify-between mb-3">
              <div>
                <h4 className="font-bold text-gray-900">{order.restaurantName}</h4>
                <div className="flex items-center gap-2 mt-1">
                  <MapPin className="w-4 h-4 text-pink-600" />
                  <Phone className="w-4 h-4 text-pink-600" />
                </div>
              </div>
            </div>
          </div>

          {/* Order Details */}
          <div className="border border-gray-200 rounded-lg p-4">
            <p className="text-sm text-gray-500 mb-2">Order details</p>
            <p className="font-bold text-gray-900 mb-1">
              #{order.id.slice(0, 8)}
            </p>
            <p className="text-sm text-gray-600 mb-3">{order.customerName}</p>

            <button className="text-pink-600 text-sm font-medium flex items-center gap-1 mb-4">
              View order items ({items.length}) ▼
            </button>

            <div className="border-t pt-3">
              <p className="text-sm text-gray-500 mb-1">Payment</p>
              <p className="font-medium text-gray-900">
                {order.paymentMethod === 'cod' ? 'Cash on Delivery' : order.paymentMethod}
              </p>
            </div>
          </div>

          {/* Pickup Experience */}
          <div className="border border-gray-200 rounded-lg p-4">
            <p className="text-center text-gray-700 mb-3">
              How is the pick up experience?
            </p>
            <div className="flex justify-center gap-4">
              <button className="text-3xl hover:scale-110 transition-transform">
                😞
              </button>
              <button className="text-3xl hover:scale-110 transition-transform">
                😊
              </button>
            </div>
          </div>

          {/* Confirm Pickup Button */}
          <button
            onClick={() => handleStatusUpdate(onConfirmPickup)}
            disabled={updating}
            className="w-full bg-pink-600 hover:bg-pink-700 disabled:bg-gray-400 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            {updating ? 'Updating...' : 'Confirm pickup'}
          </button>
        </div>

        {/* Chat Icon */}
        <button className="absolute bottom-20 right-4 w-12 h-12 bg-pink-600 rounded-full shadow-lg flex items-center justify-center hover:bg-pink-700 transition-colors">
          <MessageCircle className="w-6 h-6 text-white" />
        </button>
      </div>
    );
  }

  // Stage 3: Going to Customer (status: picked_up)
  if (status === 'picked_up') {
    return (
      <div className="fixed bottom-4 right-4 bg-white rounded-2xl shadow-2xl border border-gray-200 w-96 z-50 overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-pink-500 to-pink-600 p-4 flex justify-between items-center">
          <div className="text-white">
            <h3 className="font-bold text-lg">{order.customerName}</h3>
            <p className="text-sm text-pink-100">Go to customer</p>
          </div>
          <button
            onClick={() => setIsCollapsed(true)}
            className="p-2 hover:bg-white/20 rounded-full transition-colors"
          >
            <ChevronDown className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 space-y-4">
          {/* Customer Address */}
          <div className="flex items-start gap-3">
            <MapPin className="w-5 h-5 text-gray-600 mt-1 flex-shrink-0" />
            <div className="flex-1">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-gray-900">{order.customerName}</p>
                  <p className="text-sm text-gray-600">{order.customerAddress}</p>
                </div>
                <div className="flex gap-2">
                  <button className="p-2 bg-pink-50 rounded-full hover:bg-pink-100 transition-colors">
                    <MapPin className="w-5 h-5 text-pink-600" />
                  </button>
                  <button className="p-2 bg-pink-50 rounded-full hover:bg-pink-100 transition-colors">
                    <Phone className="w-5 h-5 text-pink-600" />
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Payment Info */}
          <div className="bg-gray-50 p-3 rounded-lg">
            <div className="flex justify-between items-center">
              <span className="text-sm text-gray-600">Payment</span>
              <span className="font-semibold text-gray-900">
                {order.paymentMethod === 'cod' ? 'Collect cash' : 'Paid online'}
              </span>
            </div>
            <div className="flex justify-between items-center mt-1">
              <span className="text-2xl font-bold text-gray-900">{order.total} Tk</span>
              <span className="text-xs text-gray-500">
                (Customer requested change for 0.00 Tk)
              </span>
            </div>
          </div>

          {/* Customer Note */}
          {order.noteToRider && (
            <div className="bg-blue-50 p-3 rounded-lg">
              <p className="text-sm text-gray-600 mb-1">Customer note</p>
              <div className="flex items-start gap-2">
                <p className="text-sm text-gray-900">{order.noteToRider}</p>
                <button className="p-1 hover:bg-blue-100 rounded">
                  <MapPin className="w-4 h-4 text-pink-600" />
                </button>
              </div>
            </div>
          )}

          {/* Arrival Time */}
          <div className="bg-gray-50 p-3 rounded-lg">
            <p className="text-center font-semibold text-gray-900">
              Arrive in 21 min
            </p>
          </div>

          {/* Map */}
          <div
            ref={mapContainer}
            className="w-full h-48 rounded-lg overflow-hidden"
          />

          {/* Action Button */}
          <button
            onClick={() => handleStatusUpdate(onArrivedAtCustomer)}
            disabled={updating}
            className="w-full bg-pink-600 hover:bg-pink-700 disabled:bg-gray-400 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            {updating ? 'Updating...' : 'Arrived at the customer'}
          </button>
        </div>

        {/* Chat Icon */}
        <button className="absolute bottom-20 right-4 w-12 h-12 bg-pink-600 rounded-full shadow-lg flex items-center justify-center hover:bg-pink-700 transition-colors">
          <MessageCircle className="w-6 h-6 text-white" />
        </button>
      </div>
    );
  }

  return null;
}