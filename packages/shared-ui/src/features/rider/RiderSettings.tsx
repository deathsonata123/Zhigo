//src/app/rider/settings/page.tsx
'use client';

import { Button } from "../../components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../../components/ui/card";
import { Input } from "../../components/ui/input";
import { Label } from "../../components/ui/label";
import { AlertTriangle, Loader2 } from "lucide-react";
import { useState } from "react";
import { cn } from "../../lib/utils";

function ProfileTabContent() {
    const user = { displayName: 'John Doe', email: 'rider@example.com' };
    const loading = false;

    if (loading) {
        return (
             <div className="flex h-full w-full items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
        )
    }
    return (
        <div className="space-y-8">
            <Card>
                <CardHeader>
                    <CardTitle>Profile</CardTitle>
                    <CardDescription>Update your personal information.</CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                    <div className="space-y-2">
                        <Label htmlFor="fullName">Full Name</Label>
                        <Input id="fullName" defaultValue={user?.displayName || ''} />
                    </div>
                     <div className="space-y-2">
                        <Label htmlFor="email">Email</Label>
                        <Input id="email" type="email" defaultValue={user?.email || ''} disabled />
                    </div>
                    <Button>Save changes</Button>
                </CardContent>
            </Card>

            <Card className="border-destructive/50">
                <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-destructive">
                        <AlertTriangle /> Delete Account
                    </CardTitle>
                     <CardDescription>
                        Permanently remove your account and all associated data. This action cannot be undone.
                    </CardDescription>
                </CardHeader>
                <CardContent>
                     <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between">
                        <p className="text-sm text-muted-foreground max-w-md mb-4 sm:mb-0">
                           By deleting your account, you will lose access to all of your ride history and earnings data. Are you sure you want to do this?
                        </p>
                        <Button variant="destructive">Delete account</Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}

function ChangePasswordTabContent() {
    return (
        <Card>
            <CardHeader>
                <CardTitle>Change password</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
                 <div className="space-y-2">
                    <Label htmlFor="current-password">Current password</Label>
                    <Input id="current-password" type="password" />
                </div>
                 <div className="space-y-2">
                    <Label htmlFor="new-password">New password</Label>
                    <Input id="new-password" type="password" />
                </div>
                 <div className="space-y-2">
                    <Label htmlFor="confirm-password">Confirm new password</Label>
                    <Input id="confirm-password" type="password" />
                </div>
                <div className="flex justify-between items-center">
                    <Button>Save new password</Button>
                    <Button variant="link">Forgot your password?</Button>
                </div>
            </CardContent>
        </Card>
    );
}

function BillingTabContent() {
    return (
        <Card>
            <CardHeader>
                <CardTitle>Billing</CardTitle>
                <CardDescription>Manage your payment methods and view invoices.</CardDescription>
            </CardHeader>
            <CardContent>
                <p className="text-muted-foreground">Billing details coming soon.</p>
            </CardContent>
        </Card>
    )
}

export default function RiderSettingsPage() {
    const [activeTab, setActiveTab] = useState('profile');
    
    const navItems = [
        { id: 'profile', label: 'Profile' },
        { id: 'password', label: 'Change password' },
        { id: 'billing', label: 'Billing' },
    ];

    return (
        <div className="space-y-8">
            <header>
                <h1 className="text-4xl font-bold font-headline">Settings</h1>
                <p className="text-muted-foreground mt-2 text-lg">Manage your account settings.</p>
            </header>
            
            <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                <div className="md:col-span-1">
                    <nav className="flex flex-col gap-1">
                        {navItems.map(item => (
                             <Button 
                                key={item.id}
                                variant="ghost" 
                                className={cn(
                                    "justify-start",
                                    activeTab === item.id && "bg-primary/10 text-primary"
                                )}
                                onClick={() => setActiveTab(item.id)}
                            >
                                {item.label}
                            </Button>
                        ))}
                    </nav>
                </div>
                <div className="md:col-span-3">
                   {activeTab === 'profile' && <ProfileTabContent />}
                   {activeTab === 'password' && <ChangePasswordTabContent />}
                   {activeTab === 'billing' && <BillingTabContent />}
                </div>
            </div>
        </div>
    )
}

    