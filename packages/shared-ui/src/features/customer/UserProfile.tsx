'use client';

import { useState, useEffect } from 'react';
import { Card } from "../../components/ui/card";
import { Button } from "../../components/ui/button";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { Textarea } from "../../components/ui/textarea";
import { Avatar, AvatarFallback, AvatarImage } from "../../components/ui/avatar";
import { Separator } from "../../components/ui/separator";
import { Badge } from "../../components/ui/badge";
import {
  User,
  MapPin,
  Bell,
  Lock,
  CreditCard,
  Shield,
  Trash2,
  Plus,
  Camera,
  Save,
  Mail,
  Phone,
  Calendar,
  Home,
  Briefcase,
  Building2,
  Check,
  X
} from 'lucide-react';
import { uploadData, getUrl, remove } from '../../lib/storage';
import { getCurrentUser, updatePassword } from '../../lib/auth';
import { toast } from 'sonner';


interface UserProfile {
  id: string;
  userId: string;
  email: string;
  fullName?: string;
  phone?: string;
  photoUrl?: string;
  dateOfBirth?: string;
  bio?: string;
}

interface Address {
  id: string;
  label: string;
  street: string;
  city: string;
  state?: string;
  zipCode?: string;
  country: string;
  isDefault: boolean;
}

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('profile');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [addresses, setAddresses] = useState<Address[]>([]);
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [profilePhotoUrl, setProfilePhotoUrl] = useState<string>('');

  // Form states
  const [profileForm, setProfileForm] = useState({
    fullName: '',
    phone: '',
    dateOfBirth: '',
    bio: ''
  });

  const [passwordForm, setPasswordForm] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });

  const [addressForm, setAddressForm] = useState({
    label: 'Home',
    street: '',
    city: '',
    state: '',
    zipCode: '',
    country: '',
    isDefault: false
  });

  const [showAddressForm, setShowAddressForm] = useState(false);

  // Load user data
  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      setLoading(true);
      const user = await getCurrentUser();
      setCurrentUser(user);

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';

      // Fetch user profile
      const profilesRes = await fetch(`${apiUrl}/api/users?userId=${user.userId}`);
      if (!profilesRes.ok) throw new Error('Failed to fetch profile');
      const profiles = await profilesRes.json();

      if (profiles && profiles.length > 0) {
        const profile = profiles[0];
        setUserProfile(profile as UserProfile);
        setProfileForm({
          fullName: profile.fullName || '',
          phone: profile.phone || '',
          dateOfBirth: profile.dateOfBirth || '',
          bio: profile.bio || ''
        });

        // Get profile photo URL if exists
        if (profile.photoUrl) {
          const url = await getUrl({ path: profile.photoUrl });
          setProfilePhotoUrl(url.url.toString());
        }

        // Fetch addresses
        const addressesRes = await fetch(`${apiUrl}/api/addresses?userId=${user.userId}`);
        if (!addressesRes.ok) throw new Error('Failed to fetch addresses');
        const userAddresses = await addressesRes.json();
        setAddresses(userAddresses as Address[]);
      } else {
        // Create initial profile
        const createRes = await fetch(`${apiUrl}/api/users`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            userId: user.userId,
            email: user.signInDetails?.loginId || '',
          })
        });
        if (!createRes.ok) throw new Error('Failed to create profile');
        const newProfile = await createRes.json();
        setUserProfile(newProfile as UserProfile);
      }
    } catch (error) {
      console.error('Error loading user data:', error);
      toast.error('Failed to load user data');
    } finally {
      setLoading(false);
    }
  };

  // Handle profile photo upload
  const handlePhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !currentUser) return;

    try {
      setSaving(true);
      const fileExtension = file.name.split('.').pop();
      const fileName = `profile-photos/${currentUser.userId}.${fileExtension}`;

      // Delete old photo if exists
      if (userProfile?.photoUrl) {
        await remove({ path: userProfile.photoUrl });
      }

      // Upload new photo
      await uploadData({
        path: fileName,
        data: file,
      });

      // Update profile
      if (userProfile?.id) {
        const updateRes = await fetch(`${apiUrl}/api/users/${userProfile.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ photoUrl: fileName })
        });
        if (!updateRes.ok) throw new Error('Failed to update profile');

        const url = await getUrl({ path: fileName });
        setProfilePhotoUrl(url.url.toString());
        toast.success('Profile photo updated successfully');
      }
    } catch (error) {
      console.error('Error uploading photo:', error);
      toast.error('Failed to upload photo');
    } finally {
      setSaving(false);
    }
  };

  // Save profile
  const handleSaveProfile = async () => {
    if (!userProfile?.id) return;

    try {
      setSaving(true);
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      const updateRes = await fetch(`${apiUrl}/api/users/${userProfile.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          fullName: profileForm.fullName,
          phone: profileForm.phone,
          dateOfBirth: profileForm.dateOfBirth,
          bio: profileForm.bio
        })
      });
      if (!updateRes.ok) throw new Error('Failed to update profile');
      toast.success('Profile updated successfully');
    } catch (error) {
      console.error('Error saving profile:', error);
      toast.error('Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  // Change password
  const handleChangePassword = async () => {
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    if (passwordForm.newPassword.length < 8) {
      toast.error('Password must be at least 8 characters');
      return;
    }

    try {
      setSaving(true);
      await updatePassword({
        oldPassword: passwordForm.currentPassword,
        newPassword: passwordForm.newPassword
      });
      setPasswordForm({ currentPassword: '', newPassword: '', confirmPassword: '' });
      toast.success('Password changed successfully');
    } catch (error: any) {
      console.error('Error changing password:', error);
      toast.error(error.message || 'Failed to change password');
    } finally {
      setSaving(false);
    }
  };

  // Add address
  const handleAddAddress = async () => {
    if (!currentUser || !addressForm.street || !addressForm.city) {
      toast.error('Please fill in all required fields');
      return;
    }

    try {
      setSaving(true);
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      const createRes = await fetch(`${apiUrl}/api/addresses`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: currentUser.userId,
          label: addressForm.label,
          street: addressForm.street,
          city: addressForm.city,
          state: addressForm.state,
          zipCode: addressForm.zipCode,
          country: addressForm.country || 'Bangladesh',
          isDefault: addressForm.isDefault
        })
      });
      if (!createRes.ok) throw new Error('Failed to create address');
      const newAddress = await createRes.json();

      setAddresses([...addresses, newAddress as Address]);
      setAddressForm({
        label: 'Home',
        street: '',
        city: '',
        state: '',
        zipCode: '',
        country: '',
        isDefault: false
      });
      setShowAddressForm(false);
      toast.success('Address added successfully');
    } catch (error) {
      console.error('Error adding address:', error);
      toast.error('Failed to add address');
    } finally {
      setSaving(false);
    }
  };

  // Delete address
  const handleDeleteAddress = async (id: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      const deleteRes = await fetch(`${apiUrl}/api/addresses/${id}`, {
        method: 'DELETE'
      });
      if (!deleteRes.ok) throw new Error('Failed to delete address');
      setAddresses(addresses.filter(addr => addr.id !== id));
      toast.success('Address deleted successfully');
    } catch (error) {
      console.error('Error deleting address:', error);
      toast.error('Failed to delete address');
    }
  };

  // Set default address
  const handleSetDefaultAddress = async (id: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
      // Remove default from all addresses
      await Promise.all(
        addresses.map(addr =>
          fetch(`${apiUrl}/api/addresses/${addr.id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ isDefault: addr.id === id })
          })
        )
      );

      setAddresses(addresses.map(addr => ({
        ...addr,
        isDefault: addr.id === id
      })));
      toast.success('Default address updated');
    } catch (error) {
      console.error('Error setting default address:', error);
      toast.error('Failed to update default address');
    }
  };

  const navItems = [
    { id: 'profile', label: 'Profile', icon: User },
    { id: 'addresses', label: 'Addresses', icon: MapPin },
    { id: 'security', label: 'Security', icon: Lock },
    { id: 'notifications', label: 'Notifications', icon: Bell },
    { id: 'payment', label: 'Payment', icon: CreditCard },
    { id: 'privacy', label: 'Privacy', icon: Shield },
  ];

  const addressIcons = {
    Home: Home,
    Work: Briefcase,
    Other: Building2
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50">
        <div className="container mx-auto px-4 py-8">
          <div className="animate-pulse">
            <div className="h-8 w-48 bg-gray-200 rounded mb-8"></div>
            <div className="grid lg:grid-cols-4 gap-6">
              <div className="h-96 bg-gray-200 rounded-xl"></div>
              <div className="lg:col-span-3 h-96 bg-gray-200 rounded-xl"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-transparent">
            Settings
          </h1>
          <p className="text-gray-500 mt-2">Manage your account settings and preferences</p>
        </div>

        <div className="grid lg:grid-cols-4 gap-6">
          {/* Sidebar Navigation */}
          <Card className="lg:col-span-1 h-fit sticky top-4 border-0 shadow-xl bg-white/80 backdrop-blur">
            <div className="p-6">
              <div className="flex flex-col items-center mb-6 pb-6 border-b">
                <div className="relative group">
                  <Avatar className="h-24 w-24 border-4 border-white shadow-lg ring-2 ring-gray-100">
                    <AvatarImage src={profilePhotoUrl || 'https://placehold.co/100x100.png'} />
                    <AvatarFallback className="bg-gradient-to-br from-blue-500 to-purple-500 text-white text-2xl">
                      {profileForm.fullName?.[0] || userProfile?.email?.[0]?.toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <label className="absolute bottom-0 right-0 bg-blue-600 hover:bg-blue-700 text-white p-2 rounded-full cursor-pointer shadow-lg transition-all group-hover:scale-110">
                    <Camera className="h-4 w-4" />
                    <input type="file" className="hidden" accept="image/*" onChange={handlePhotoUpload} />
                  </label>
                </div>
                <h3 className="font-semibold text-lg mt-4">{profileForm.fullName || 'User'}</h3>
                <p className="text-sm text-gray-500">{userProfile?.email}</p>
              </div>

              <nav className="space-y-1">
                {navItems.map((item) => {
                  const Icon = item.icon;
                  return (
                    <button
                      key={item.id}
                      onClick={() => setActiveTab(item.id)}
                      className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${activeTab === item.id
                        ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-md'
                        : 'text-gray-600 hover:bg-gray-100'
                        }`}
                    >
                      <Icon className="h-5 w-5" />
                      <span className="font-medium">{item.label}</span>
                    </button>
                  );
                })}
              </nav>
            </div>
          </Card>

          {/* Main Content */}
          <div className="lg:col-span-3">
            {/* Profile Tab */}
            {activeTab === 'profile' && (
              <Card className="border-0 shadow-xl bg-white/80 backdrop-blur">
                <div className="p-8">
                  <div className="flex items-center justify-between mb-6">
                    <div>
                      <h2 className="text-2xl font-bold">Profile Information</h2>
                      <p className="text-gray-500 mt-1">Update your personal details</p>
                    </div>
                    <Button onClick={handleSaveProfile} disabled={saving} className="bg-gradient-to-r from-blue-600 to-purple-600">
                      <Save className="h-4 w-4 mr-2" />
                      {saving ? 'Saving...' : 'Save Changes'}
                    </Button>
                  </div>

                  <div className="space-y-6">
                    <div className="grid md:grid-cols-2 gap-6">
                      <div className="space-y-2">
                        <Label htmlFor="fullName" className="text-gray-700">Full Name</Label>
                        <div className="relative">
                          <User className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                          <Input
                            id="fullName"
                            value={profileForm.fullName}
                            onChange={(e) => setProfileForm({ ...profileForm, fullName: e.target.value })}
                            className="pl-10 border-gray-200 focus:border-blue-500"
                            placeholder="Enter your full name"
                          />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="email" className="text-gray-700">Email Address</Label>
                        <div className="relative">
                          <Mail className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                          <Input
                            id="email"
                            value={userProfile?.email || ''}
                            disabled
                            className="pl-10 bg-gray-50 border-gray-200"
                          />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="phone" className="text-gray-700">Phone Number</Label>
                        <div className="relative">
                          <Phone className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                          <Input
                            id="phone"
                            value={profileForm.phone}
                            onChange={(e) => setProfileForm({ ...profileForm, phone: e.target.value })}
                            className="pl-10 border-gray-200 focus:border-blue-500"
                            placeholder="+880 1234567890"
                          />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="dob" className="text-gray-700">Date of Birth</Label>
                        <div className="relative">
                          <Calendar className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                          <Input
                            id="dob"
                            type="date"
                            value={profileForm.dateOfBirth}
                            onChange={(e) => setProfileForm({ ...profileForm, dateOfBirth: e.target.value })}
                            className="pl-10 border-gray-200 focus:border-blue-500"
                          />
                        </div>
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="bio" className="text-gray-700">Bio</Label>
                      <Textarea
                        id="bio"
                        value={profileForm.bio}
                        onChange={(e) => setProfileForm({ ...profileForm, bio: e.target.value })}
                        className="border-gray-200 focus:border-blue-500 min-h-[100px]"
                        placeholder="Tell us about yourself..."
                      />
                    </div>
                  </div>
                </div>
              </Card>
            )}

            {/* Addresses Tab */}
            {activeTab === 'addresses' && (
              <Card className="border-0 shadow-xl bg-white/80 backdrop-blur">
                <div className="p-8">
                  <div className="flex items-center justify-between mb-6">
                    <div>
                      <h2 className="text-2xl font-bold">Delivery Addresses</h2>
                      <p className="text-gray-500 mt-1">Manage your saved addresses</p>
                    </div>
                    <Button onClick={() => setShowAddressForm(!showAddressForm)} className="bg-gradient-to-r from-blue-600 to-purple-600">
                      <Plus className="h-4 w-4 mr-2" />
                      Add Address
                    </Button>
                  </div>

                  {showAddressForm && (
                    <Card className="mb-6 bg-gradient-to-br from-blue-50 to-purple-50 border-blue-200">
                      <div className="p-6 space-y-4">
                        <h3 className="font-semibold text-lg">New Address</h3>

                        <div className="grid md:grid-cols-3 gap-4">
                          <div className="space-y-2">
                            <Label>Address Type</Label>
                            <select
                              value={addressForm.label}
                              onChange={(e) => setAddressForm({ ...addressForm, label: e.target.value })}
                              className="w-full px-3 py-2 border rounded-lg"
                            >
                              <option value="Home">Home</option>
                              <option value="Work">Work</option>
                              <option value="Other">Other</option>
                            </select>
                          </div>

                          <div className="space-y-2 md:col-span-2">
                            <Label>Street Address</Label>
                            <Input
                              value={addressForm.street}
                              onChange={(e) => setAddressForm({ ...addressForm, street: e.target.value })}
                              placeholder="123 Main Street"
                            />
                          </div>

                          <div className="space-y-2">
                            <Label>City</Label>
                            <Input
                              value={addressForm.city}
                              onChange={(e) => setAddressForm({ ...addressForm, city: e.target.value })}
                              placeholder="Dhaka"
                            />
                          </div>

                          <div className="space-y-2">
                            <Label>State/Division</Label>
                            <Input
                              value={addressForm.state}
                              onChange={(e) => setAddressForm({ ...addressForm, state: e.target.value })}
                              placeholder="Dhaka Division"
                            />
                          </div>

                          <div className="space-y-2">
                            <Label>ZIP Code</Label>
                            <Input
                              value={addressForm.zipCode}
                              onChange={(e) => setAddressForm({ ...addressForm, zipCode: e.target.value })}
                              placeholder="1000"
                            />
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <input
                            type="checkbox"
                            id="defaultAddress"
                            checked={addressForm.isDefault}
                            onChange={(e) => setAddressForm({ ...addressForm, isDefault: e.target.checked })}
                            className="rounded"
                          />
                          <Label htmlFor="defaultAddress" className="cursor-pointer">Set as default address</Label>
                        </div>

                        <div className="flex gap-3">
                          <Button onClick={handleAddAddress} disabled={saving} className="bg-gradient-to-r from-blue-600 to-purple-600">
                            {saving ? 'Saving...' : 'Save Address'}
                          </Button>
                          <Button variant="outline" onClick={() => setShowAddressForm(false)}>
                            Cancel
                          </Button>
                        </div>
                      </div>
                    </Card>
                  )}

                  <div className="space-y-4">
                    {addresses.length === 0 ? (
                      <div className="text-center py-12">
                        <MapPin className="h-12 w-12 text-gray-300 mx-auto mb-4" />
                        <p className="text-gray-500">No addresses saved yet</p>
                        <p className="text-sm text-gray-400">Add your first delivery address</p>
                      </div>
                    ) : (
                      addresses.map((address) => {
                        const Icon = addressIcons[address.label as keyof typeof addressIcons] || Building2;
                        return (
                          <Card key={address.id} className={`p-6 hover:shadow-lg transition-all ${address.isDefault ? 'border-2 border-blue-500 bg-blue-50/50' : 'border-gray-200'}`}>
                            <div className="flex items-start justify-between">
                              <div className="flex items-start gap-4 flex-1">
                                <div className={`p-3 rounded-full ${address.isDefault ? 'bg-blue-600' : 'bg-gray-100'}`}>
                                  <Icon className={`h-6 w-6 ${address.isDefault ? 'text-white' : 'text-gray-600'}`} />
                                </div>
                                <div className="flex-1">
                                  <div className="flex items-center gap-2 mb-2">
                                    <h3 className="font-semibold text-lg">{address.label}</h3>
                                    {address.isDefault && (
                                      <Badge className="bg-blue-600">Default</Badge>
                                    )}
                                  </div>
                                  <p className="text-gray-600">{address.street}</p>
                                  <p className="text-gray-500 text-sm">
                                    {address.city}{address.state ? `, ${address.state}` : ''} {address.zipCode}
                                  </p>
                                  {!address.isDefault && (
                                    <Button
                                      variant="link"
                                      onClick={() => handleSetDefaultAddress(address.id)}
                                      className="px-0 text-blue-600 hover:text-blue-700"
                                    >
                                      Set as Default
                                    </Button>
                                  )}
                                </div>
                              </div>
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => handleDeleteAddress(address.id)}
                                className="text-red-500 hover:text-red-700 hover:bg-red-50"
                              >
                                <Trash2 className="h-5 w-5" />
                              </Button>
                            </div>
                          </Card>
                        );
                      })
                    )}
                  </div>
                </div>
              </Card>
            )}

            {/* Security Tab */}
            {activeTab === 'security' && (
              <Card className="border-0 shadow-xl bg-white/80 backdrop-blur">
                <div className="p-8">
                  <div className="mb-6">
                    <h2 className="text-2xl font-bold">Security Settings</h2>
                    <p className="text-gray-500 mt-1">Manage your password and security preferences</p>
                  </div>

                  <div className="space-y-6">
                    <Card className="bg-gradient-to-br from-amber-50 to-orange-50 border-amber-200">
                      <div className="p-6">
                        <div className="flex items-start gap-4">
                          <div className="p-3 bg-amber-500 rounded-full">
                            <Lock className="h-6 w-6 text-white" />
                          </div>
                          <div>
                            <h3 className="font-semibold text-lg mb-2">Change Password</h3>
                            <p className="text-sm text-gray-600 mb-4">
                              Make sure your password is strong and secure
                            </p>

                            <div className="space-y-4 max-w-md">
                              <div className="space-y-2">
                                <Label htmlFor="currentPassword">Current Password</Label>
                                <Input
                                  id="currentPassword"
                                  type="password"
                                  value={passwordForm.currentPassword}
                                  onChange={(e) => setPasswordForm({ ...passwordForm, currentPassword: e.target.value })}
                                  placeholder="Enter current password"
                                />
                              </div>

                              <div className="space-y-2">
                                <Label htmlFor="newPassword">New Password</Label>
                                <Input
                                  id="newPassword"
                                  type="password"
                                  value={passwordForm.newPassword}
                                  onChange={(e) => setPasswordForm({ ...passwordForm, newPassword: e.target.value })}
                                  placeholder="Enter new password"
                                />
                              </div>

                              <div className="space-y-2">
                                <Label htmlFor="confirmPassword">Confirm New Password</Label>
                                <Input
                                  id="confirmPassword"
                                  type="password"
                                  value={passwordForm.confirmPassword}
                                  onChange={(e) => setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })}
                                  placeholder="Confirm new password"
                                />
                              </div>

                              <Button
                                onClick={handleChangePassword}
                                disabled={saving || !passwordForm.currentPassword || !passwordForm.newPassword}
                                className="bg-gradient-to-r from-amber-600 to-orange-600"
                              >
                                <Lock className="h-4 w-4 mr-2" />
                                {saving ? 'Updating...' : 'Update Password'}
                              </Button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </Card>

                    <Card className="bg-gradient-to-br from-green-50 to-emerald-50 border-green-200">
                      <div className="p-6">
                        <div className="flex items-center gap-4">
                          <div className="p-3 bg-green-500 rounded-full">
                            <Shield className="h-6 w-6 text-white" />
                          </div>
                          <div className="flex-1">
                            <h3 className="font-semibold text-lg">Two-Factor Authentication</h3>
                            <p className="text-sm text-gray-600">Add an extra layer of security to your account</p>
                          </div>
                          <Button variant="outline" disabled className="border-green-600 text-green-600">
                            Enable 2FA
                          </Button>
                        </div>
                      </div>
                    </Card>

                    <Card className="bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200">
                      <div className="p-6">
                        <div className="flex items-center gap-4">
                          <div className="p-3 bg-purple-500 rounded-full">
                            <Shield className="h-6 w-6 text-white" />
                          </div>
                          <div className="flex-1">
                            <h3 className="font-semibold text-lg">Active Sessions</h3>
                            <p className="text-sm text-gray-600">Manage devices where you're signed in</p>
                          </div>
                          <Button variant="outline" disabled className="border-purple-600 text-purple-600">
                            View Sessions
                          </Button>
                        </div>
                      </div>
                    </Card>
                  </div>
                </div>
              </Card>
            )}

            {/* Notifications Tab */}
            {activeTab === 'notifications' && (
              <Card className="border-0 shadow-xl bg-white/80 backdrop-blur">
                <div className="p-8">
                  <div className="mb-6">
                    <h2 className="text-2xl font-bold">Notification Preferences</h2>
                    <p className="text-gray-500 mt-1">Choose what updates you want to receive</p>
                  </div>

                  <div className="space-y-6">
                    {[
                      { title: 'Order Updates', desc: 'Get notified about your order status', enabled: true },
                      { title: 'Promotions & Offers', desc: 'Receive special deals and discounts', enabled: true },
                      { title: 'New Restaurants', desc: 'Be first to know about new restaurants', enabled: false },
                      { title: 'Rating Reminders', desc: 'Reminders to rate your orders', enabled: true },
                      { title: 'Email Notifications', desc: 'Receive updates via email', enabled: true },
                      { title: 'SMS Notifications', desc: 'Receive updates via SMS', enabled: false },
                    ].map((item, index) => (
                      <Card key={index} className="p-6 hover:shadow-md transition-all">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-4">
                            <div className={`p-3 rounded-full ${item.enabled ? 'bg-blue-100' : 'bg-gray-100'}`}>
                              <Bell className={`h-5 w-5 ${item.enabled ? 'text-blue-600' : 'text-gray-400'}`} />
                            </div>
                            <div>
                              <h3 className="font-semibold">{item.title}</h3>
                              <p className="text-sm text-gray-500">{item.desc}</p>
                            </div>
                          </div>
                          <label className="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" className="sr-only peer" defaultChecked={item.enabled} />
                            <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                          </label>
                        </div>
                      </Card>
                    ))}
                  </div>
                </div>
              </Card>
            )}

            {/* Payment Tab */}
            {activeTab === 'payment' && (
              <Card className="border-0 shadow-xl bg-white/80 backdrop-blur">
                <div className="p-8">
                  <div className="flex items-center justify-between mb-6">
                    <div>
                      <h2 className="text-2xl font-bold">Payment Methods</h2>
                      <p className="text-gray-500 mt-1">Manage your payment options</p>
                    </div>
                    <Button disabled className="bg-gradient-to-r from-blue-600 to-purple-600">
                      <Plus className="h-4 w-4 mr-2" />
                      Add Payment
                    </Button>
                  </div>

                  <div className="space-y-4">
                    <Card className="p-6 bg-gradient-to-r from-blue-600 to-purple-600 text-white">
                      <div className="flex justify-between items-start mb-8">
                        <div>
                          <p className="text-blue-100 text-sm mb-1">Credit Card</p>
                          <p className="text-2xl font-bold tracking-wider">•••• •••• •••• 1234</p>
                        </div>
                        <Badge className="bg-white/20 text-white">Default</Badge>
                      </div>
                      <div className="flex justify-between items-end">
                        <div>
                          <p className="text-blue-100 text-xs mb-1">Cardholder</p>
                          <p className="font-semibold">{profileForm.fullName || 'John Doe'}</p>
                        </div>
                        <div>
                          <p className="text-blue-100 text-xs mb-1">Expires</p>
                          <p className="font-semibold">12/25</p>
                        </div>
                        <CreditCard className="h-8 w-8 opacity-70" />
                      </div>
                    </Card>

                    <Card className="p-6 border-2 border-dashed border-gray-300 hover:border-blue-400 transition-all">
                      <div className="flex items-center justify-center gap-4 text-gray-400">
                        <CreditCard className="h-8 w-8" />
                        <div>
                          <p className="font-semibold text-gray-600">Add a new payment method</p>
                          <p className="text-sm">Credit card, debit card, or mobile payment</p>
                        </div>
                      </div>
                    </Card>
                  </div>

                  <Separator className="my-8" />

                  <div>
                    <h3 className="text-lg font-semibold mb-4">Transaction History</h3>
                    <div className="space-y-3">
                      {[
                        { date: 'Oct 15, 2025', amount: '৳850', status: 'Completed', restaurant: 'Spice Garden' },
                        { date: 'Oct 12, 2025', amount: '৳1,200', status: 'Completed', restaurant: 'Burger Palace' },
                        { date: 'Oct 10, 2025', amount: '৳650', status: 'Refunded', restaurant: 'Pizza House' },
                      ].map((transaction, index) => (
                        <Card key={index} className="p-4 hover:shadow-md transition-all">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-4">
                              <div className={`p-2 rounded-full ${transaction.status === 'Completed' ? 'bg-green-100' : 'bg-amber-100'}`}>
                                {transaction.status === 'Completed' ? (
                                  <Check className={`h-4 w-4 text-green-600`} />
                                ) : (
                                  <X className={`h-4 w-4 text-amber-600`} />
                                )}
                              </div>
                              <div>
                                <p className="font-semibold">{transaction.restaurant}</p>
                                <p className="text-sm text-gray-500">{transaction.date}</p>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-lg">{transaction.amount}</p>
                              <Badge variant={transaction.status === 'Completed' ? 'default' : 'secondary'} className="text-xs">
                                {transaction.status}
                              </Badge>
                            </div>
                          </div>
                        </Card>
                      ))}
                    </div>
                  </div>
                </div>
              </Card>
            )}

            {/* Privacy Tab */}
            {activeTab === 'privacy' && (
              <Card className="border-0 shadow-xl bg-white/80 backdrop-blur">
                <div className="p-8">
                  <div className="mb-6">
                    <h2 className="text-2xl font-bold">Privacy & Data</h2>
                    <p className="text-gray-500 mt-1">Control your data and privacy settings</p>
                  </div>

                  <div className="space-y-6">
                    <Card className="p-6 bg-gradient-to-br from-blue-50 to-cyan-50 border-blue-200">
                      <div className="flex items-start gap-4">
                        <div className="p-3 bg-blue-600 rounded-full">
                          <Shield className="h-6 w-6 text-white" />
                        </div>
                        <div className="flex-1">
                          <h3 className="font-semibold text-lg mb-2">Data Privacy</h3>
                          <p className="text-sm text-gray-600 mb-4">
                            We take your privacy seriously. Review our data collection and usage policies.
                          </p>
                          <div className="space-y-3">
                            <label className="flex items-center gap-3 cursor-pointer">
                              <input type="checkbox" className="rounded" defaultChecked />
                              <span className="text-sm">Share my data for personalized recommendations</span>
                            </label>
                            <label className="flex items-center gap-3 cursor-pointer">
                              <input type="checkbox" className="rounded" defaultChecked />
                              <span className="text-sm">Allow analytics for service improvement</span>
                            </label>
                            <label className="flex items-center gap-3 cursor-pointer">
                              <input type="checkbox" className="rounded" />
                              <span className="text-sm">Share my location for better delivery experience</span>
                            </label>
                          </div>
                        </div>
                      </div>
                    </Card>

                    <Card className="p-6 bg-gradient-to-br from-red-50 to-pink-50 border-red-200">
                      <div className="flex items-start gap-4">
                        <div className="p-3 bg-red-600 rounded-full">
                          <Trash2 className="h-6 w-6 text-white" />
                        </div>
                        <div className="flex-1">
                          <h3 className="font-semibold text-lg mb-2 text-red-900">Delete Account</h3>
                          <p className="text-sm text-gray-600 mb-4">
                            Permanently delete your account and all associated data. This action cannot be undone.
                          </p>
                          <Button variant="destructive" disabled>
                            Delete My Account
                          </Button>
                        </div>
                      </div>
                    </Card>

                    <Card className="p-6 bg-gradient-to-br from-purple-50 to-indigo-50 border-purple-200">
                      <div className="flex items-start gap-4">
                        <div className="p-3 bg-purple-600 rounded-full">
                          <Shield className="h-6 w-6 text-white" />
                        </div>
                        <div className="flex-1">
                          <h3 className="font-semibold text-lg mb-2">Download Your Data</h3>
                          <p className="text-sm text-gray-600 mb-4">
                            Request a copy of all your data stored in our system
                          </p>
                          <Button variant="outline" className="border-purple-600 text-purple-600" disabled>
                            Request Data Export
                          </Button>
                        </div>
                      </div>
                    </Card>
                  </div>
                </div>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
