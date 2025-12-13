//src/components/DeliveryRequestPopup.tsx
'use client';

import { useState } from 'react';
import { ChevronDown, ChevronUp, MapPin, DollarSign } from 'lucide-react';

interface DeliveryRequestPopupProps {
  open: boolean;
  onAccept: () => Promise<void>;
  onDecline: () => Promise<void>;
  isAccepting: boolean;
  notification: any;
  riderLocation: { lat: number; lng: number };
  restaurantLocation: { lat: number; lng: number };
  customerLocation: { lat: number; lng: number };
}

export default function DeliveryRequestPopup({
  open,
  onAccept,
  onDecline,
  isAccepting,
  notification,
  riderLocation,
  restaurantLocation,
  customerLocation
}: DeliveryRequestPopupProps) {
  const [isCollapsed, setIsCollapsed] = useState(false);

  if (!open || !notification) return null;

  const handleAccept = async () => {
    try {
      await onAccept();
    } catch (error) {
      console.error('Error accepting order:', error);
    }
  };

  if (isCollapsed) {
    return (
      <div className="fixed bottom-4 right-4 bg-white rounded-lg shadow-2xl border border-gray-200 p-4 w-80 z-50">
        <div className="flex justify-between items-center">
          <div>
            <p className="font-semibold text-gray-900">New Delivery Request</p>
            <p className="text-sm text-gray-500">Order #{notification.orderId.slice(0, 8)}</p>
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

  return (
    <div className="fixed bottom-4 right-4 bg-white rounded-2xl shadow-2xl border border-gray-200 w-96 z-50 overflow-hidden">
      {/* Header with collapse button */}
      <div className="bg-gradient-to-r from-pink-500 to-pink-600 p-4 flex justify-between items-center">
        <div className="text-white">
          <h3 className="font-bold text-lg">New Delivery Request</h3>
          <p className="text-sm text-pink-100">Order #{notification.orderId.slice(0, 8)}</p>
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
        <div className="bg-gray-50 p-3 rounded-lg">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 bg-pink-100 rounded-lg flex items-center justify-center flex-shrink-0">
              <MapPin className="w-5 h-5 text-pink-600" />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-gray-900">{notification.restaurantName}</p>
              <p className="text-sm text-gray-600 mt-1">
                {restaurantLocation.lat.toFixed(4)}, {restaurantLocation.lng.toFixed(4)}
              </p>
            </div>
          </div>
        </div>

        {/* Customer Info */}
        <div className="bg-gray-50 p-3 rounded-lg">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0">
              <MapPin className="w-5 h-5 text-blue-600" />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-gray-900">Customer</p>
              <p className="text-sm text-gray-600 mt-1">{notification.customerAddress}</p>
            </div>
          </div>
        </div>

        {/* Order Total */}
        <div className="bg-green-50 p-3 rounded-lg flex items-center justify-between">
          <div className="flex items-center gap-2">
            <DollarSign className="w-5 h-5 text-green-600" />
            <span className="font-medium text-gray-700">Order Total</span>
          </div>
          <span className="font-bold text-green-600">{notification.orderTotal} Tk</span>
        </div>

        {/* Distance */}
        <div className="flex items-center justify-between text-sm">
          <span className="text-gray-600">Estimated Distance</span>
          <span className="font-semibold text-gray-900">
            Calculating...
          </span>
        </div>

        {/* Action Buttons */}
        <div className="flex gap-2">
          <button
            onClick={onDecline}
            disabled={isAccepting}
            className="flex-1 bg-gray-200 hover:bg-gray-300 disabled:bg-gray-100 text-gray-800 font-semibold py-3 rounded-xl transition-colors"
          >
            Decline
          </button>
          <button
            onClick={handleAccept}
            disabled={isAccepting}
            className="flex-1 bg-pink-600 hover:bg-pink-700 disabled:bg-gray-400 text-white font-semibold py-3 rounded-xl transition-colors"
          >
            {isAccepting ? 'Accepting...' : 'Accept Order'}
          </button>
        </div>
      </div>
    </div>
  );
}