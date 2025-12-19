// src/app/dashboard/hours/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Button } from '../../components/ui/button';
import { Switch } from '../../components/ui/switch';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { useToast } from '../../hooks/use-toast';
import { Loader2, Save, Clock, MapPin } from 'lucide-react';
import { Separator } from '../../components/ui/separator';
import { getCurrentUser } from '../../lib/auth';


type OpeningHour = {
  id: string;
  dayOfWeek: number;
  isOpen: boolean;
  openTime: string;
  closeTime: string;
};

const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

export default function HoursPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [restaurantId, setRestaurantId] = useState<string | null>(null);
  const [restaurantAddress, setRestaurantAddress] = useState('');
  const [editingAddress, setEditingAddress] = useState(false);
  const [openingHours, setOpeningHours] = useState<OpeningHour[]>([]);
  const { toast } = useToast();

  useEffect(() => {
    fetchRestaurantAndHours();
  }, []);

  const fetchRestaurantAndHours = async () => {
    try {
      setLoading(true);
      const user = await getCurrentUser();

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

      // Get restaurant owned by current user
      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?ownerId=${user.userId}`);
      if (!restaurantsRes.ok) throw new Error('Failed to fetch restaurants');
      const restaurants = await restaurantsRes.json();

      if (restaurants && restaurants.length > 0) {
        const restaurant = restaurants[0];
        setRestaurantId(restaurant.id);
        setRestaurantAddress(restaurant.address || '');

        // Fetch existing opening hours
        const hoursRes = await fetch(`${apiUrl}/api/opening-hours?restaurantId=${restaurant.id}`);
        if (!hoursRes.ok) throw new Error('Failed to fetch hours');
        const hours = await hoursRes.json();

        if (hours && hours.length > 0) {
          // Map existing hours
          const mappedHours = hours.map((h: any) => ({
            id: h.id,
            dayOfWeek: h.dayOfWeek || 0,
            isOpen: h.isOpen ?? true,
            openTime: h.openTime || '09:00',
            closeTime: h.closeTime || '22:00',
          }));
          setOpeningHours(mappedHours);
        } else {
          // Initialize with default hours for all 7 days
          const defaultHours = Array.from({ length: 7 }, (_, i) => ({
            id: `temp-${i}`,
            dayOfWeek: i,
            isOpen: true,
            openTime: '09:00',
            closeTime: '22:00',
          }));
          setOpeningHours(defaultHours);
        }
      }
    } catch (error) {
      console.error('Error fetching restaurant hours:', error);
      toast({
        title: "Error",
        description: "Failed to load opening hours.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleHourChange = (dayOfWeek: number, field: 'isOpen' | 'openTime' | 'closeTime', value: boolean | string) => {
    setOpeningHours(prev =>
      prev.map(hour =>
        hour.dayOfWeek === dayOfWeek
          ? { ...hour, [field]: value }
          : hour
      )
    );
  };

  const saveOpeningHours = async () => {
    if (!restaurantId) return;

    try {
      setSaving(true);

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

      // Save or update each day's hours
      for (const hour of openingHours) {
        if (hour.id.startsWith('temp-')) {
          // Create new record
          const createRes = await fetch(`${apiUrl}/api/opening-hours`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              restaurantId,
              dayOfWeek: hour.dayOfWeek,
              isOpen: hour.isOpen,
              openTime: hour.openTime,
              closeTime: hour.closeTime,
            })
          });
          if (!createRes.ok) throw new Error('Failed to create hours');
        } else {
          // Update existing record
          const updateRes = await fetch(`${apiUrl}/api/opening-hours/${hour.id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              isOpen: hour.isOpen,
              openTime: hour.openTime,
              closeTime: hour.closeTime,
            })
          });
          if (!updateRes.ok) throw new Error('Failed to update hours');
        }
      }

      toast({
        title: "Success",
        description: "Opening hours updated successfully.",
      });

      // Refresh data to get actual IDs
      await fetchRestaurantAndHours();
    } catch (error) {
      console.error('Error saving opening hours:', error);
      toast({
        title: "Error",
        description: "Failed to save opening hours.",
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  const saveAddress = async () => {
    if (!restaurantId) return;

    try {
      setSaving(true);
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

      const updateRes = await fetch(`${apiUrl}/api/restaurants/${restaurantId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ address: restaurantAddress })
      });

      if (!updateRes.ok) throw new Error('Failed to update restaurant');

      toast({
        title: "Success",
        description: "Location updated successfully.",
      });
      setEditingAddress(false);
    } catch (error) {
      console.error('Error saving address:', error);
      toast({
        title: "Error",
        description: "Failed to update location.",
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-4xl font-bold font-headline">Location & Opening Hours</h1>
        <p className="text-muted-foreground mt-2 text-lg">
          Manage your restaurant's location and operating hours
        </p>
      </div>

      {/* Location Card */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MapPin className="h-5 w-5" />
            Restaurant Location
          </CardTitle>
          <CardDescription>
            Update your restaurant's address to help customers find you
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {editingAddress ? (
            <div className="space-y-4">
              <div>
                <Label htmlFor="address">Full Address</Label>
                <Input
                  id="address"
                  value={restaurantAddress}
                  onChange={(e) => setRestaurantAddress(e.target.value)}
                  placeholder="Enter complete address with city and postal code"
                  className="mt-1.5"
                />
              </div>
              <div className="flex gap-2">
                <Button onClick={saveAddress} disabled={saving}>
                  {saving ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : <Save className="h-4 w-4 mr-2" />}
                  Save Location
                </Button>
                <Button variant="outline" onClick={() => {
                  setEditingAddress(false);
                  fetchRestaurantAndHours();
                }}>
                  Cancel
                </Button>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-sm font-medium mb-1">Current Address</p>
                <p className="text-muted-foreground">{restaurantAddress || 'No address set'}</p>
              </div>
              <Button onClick={() => setEditingAddress(true)}>
                Edit Location
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Opening Hours Card */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Clock className="h-5 w-5" />
            Opening Hours
          </CardTitle>
          <CardDescription>
            Set your restaurant's operating hours for each day of the week
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {openingHours.map((hour) => (
            <div key={hour.dayOfWeek}>
              <div className="flex items-center justify-between gap-4 p-4 border rounded-lg">
                <div className="flex items-center gap-4 flex-1">
                  <div className="w-28">
                    <p className="font-medium">{DAYS[hour.dayOfWeek]}</p>
                  </div>

                  <div className="flex items-center gap-2">
                    <Switch
                      checked={hour.isOpen}
                      onCheckedChange={(checked) => handleHourChange(hour.dayOfWeek, 'isOpen', checked)}
                    />
                    <span className="text-sm text-muted-foreground">
                      {hour.isOpen ? 'Open' : 'Closed'}
                    </span>
                  </div>

                  {hour.isOpen && (
                    <div className="flex items-center gap-2 flex-1">
                      <Input
                        type="time"
                        value={hour.openTime}
                        onChange={(e) => handleHourChange(hour.dayOfWeek, 'openTime', e.target.value)}
                        className="w-32"
                      />
                      <span className="text-muted-foreground">to</span>
                      <Input
                        type="time"
                        value={hour.closeTime}
                        onChange={(e) => handleHourChange(hour.dayOfWeek, 'closeTime', e.target.value)}
                        className="w-32"
                      />
                    </div>
                  )}
                </div>
              </div>
              {hour.dayOfWeek < 6 && <Separator className="my-2" />}
            </div>
          ))}

          <div className="pt-4">
            <Button onClick={saveOpeningHours} disabled={saving} size="lg" className="w-full sm:w-auto">
              {saving ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin mr-2" />
                  Saving...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4 mr-2" />
                  Save Opening Hours
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
