'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from 'shared-ui/components/ui/card';
import { Button } from 'shared-ui/components/ui/button';
import { Input } from 'shared-ui/components/ui/input';
import { Label } from 'shared-ui/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from 'shared-ui/components/ui/tabs';
import { UtensilsCrossed, Clock, MapPin, Phone, Mail } from 'lucide-react';

export default function SettingsPage() {
    return (
        <div className="space-y-6">
            <header>
                <h1 className="text-3xl font-bold font-headline">Settings</h1>
                <p className="text-muted-foreground mt-2">Manage your restaurant settings and preferences</p>
            </header>

            <Tabs defaultValue="general" className="w-full">
                <TabsList>
                    <TabsTrigger value="general">General</TabsTrigger>
                    <TabsTrigger value="hours">Hours</TabsTrigger>
                    <TabsTrigger value="billing">Billing</TabsTrigger>
                </TabsList>

                <TabsContent value="general" className="space-y-4">
                    <Card>
                        <CardHeader>
                            <CardTitle>Restaurant Information</CardTitle>
                            <CardDescription>Update your restaurant details</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="name">Restaurant Name</Label>
                                <Input id="name" placeholder="Your Restaurant Name" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="email">Email</Label>
                                <Input id="email" type="email" placeholder="contact@restaurant.com" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="phone">Phone</Label>
                                <Input id="phone" type="tel" placeholder="+1234567890" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="address">Address</Label>
                                <Input id="address" placeholder="123 Main St, City" />
                            </div>
                            <Button>Save Changes</Button>
                        </CardContent>
                    </Card>
                </TabsContent>

                <TabsContent value="hours">
                    <Card>
                        <CardHeader>
                            <CardTitle>Operating Hours</CardTitle>
                            <CardDescription>Set your restaurant's operating hours</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <p className="text-muted-foreground">Operating hours management - See Hours Manager page for full features</p>
                            <Button asChild className="mt-4">
                                <a href="/dashboard/hours">Manage Hours</a>
                            </Button>
                        </CardContent>
                    </Card>
                </TabsContent>

                <TabsContent value="billing">
                    <Card>
                        <CardHeader>
                            <CardTitle>Billing & Payments</CardTitle>
                            <CardDescription>Manage your billing information</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <p className="text-muted-foreground">Billing management - Commission: 15% per order</p>
                            <div className="mt-4 p-4 bg-muted rounded-lg">
                                <p className="text-sm font-medium">Payment Details</p>
                                <p className="text-sm text-muted-foreground">Bank transfer on the 1st of each month</p>
                            </div>
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </div>
    );
}
