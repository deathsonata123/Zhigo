// src/app/admin/riders/page.tsx
'use client';

import { useEffect, useState, useCallback } from 'react';
import { Button } from "../../components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../../components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "../../components/ui/table";
import { useToast } from '../../hooks/use-toast';
import { Badge } from '../../components/ui/badge';
import { Loader2, RefreshCw } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';

// Generate the Amplify Data client

type Rider = {
    id: string;
    fullName: string;
    email: string;
    phone: string;
    zone: string;
    userId: string;
    status: string;
    isOnline: boolean;
};

export default function RiderManagementPage() {
    // Single state for all riders
    const [riders, setRiders] = useState<Rider[]>([]);
    const [loading, setLoading] = useState(true);
    // Track which rider is being actioned (approve/reject)
    const [processingId, setProcessingId] = useState<string | null>(null);
    const { toast } = useToast();

    // Function to fetch rider applications from database
    const fetchApplications = useCallback(async () => {
        try {
            setLoading(true);
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
            const response = await fetch(`${apiUrl}/api/riders`);

            if (!response.ok) throw new Error('Failed to fetch riders');

            const ridersData = await response.json();

            if (ridersData) {
                const formattedRiders: Rider[] = ridersData.map((r: any) => ({
                    id: r.id,
                    fullName: r.fullName || 'Unknown',
                    email: r.email || 'N/A',
                    phone: r.phone || 'N/A',
                    zone: r.zone || 'N/A',
                    userId: r.userId || '',
                    status: r.status || 'pending',
                    isOnline: r.isOnline || false,
                }));

                setRiders(formattedRiders);

                const pending = formattedRiders.filter(r => r.status === 'pending').length;
                const approved = formattedRiders.filter(r => r.status === 'approved').length;
                console.log('Fetched riders:', { pending, approved, total: formattedRiders.length });
            }
        } catch (error) {
            console.error('Error fetching rider applications:', error);
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to load rider applications",
            });
        } finally {
            setLoading(false);
        }
    }, [toast]);

    // Fetch applications when component mounts
    useEffect(() => {
        fetchApplications();
    }, [fetchApplications]);

    // Function to approve a rider application
    const handleApprove = async (rider: Rider) => {
        // Prevent multiple simultaneous approvals
        if (processingId) return;

        setProcessingId(rider.id);

        try {
            console.log('Attempting to approve rider:', rider.id);

            // Update rider status via API
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
            const response = await fetch(`${apiUrl}/api/riders/${rider.id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: 'approved' })
            });

            const result = { data: response.ok, errors: response.ok ? [] : [{ message: 'Failed to update' }] };

            console.log('Update result:', result);

            if (result.data) {
                console.log('Rider approval successful:', result.data);

                toast({
                    title: "Rider Approved",
                    description: `${rider.fullName} is now a registered rider.`,
                });

                // Update local state immediately to reflect change
                setRiders(prev => prev.map(r =>
                    r.id === rider.id ? { ...r, status: 'approved' } : r
                ));
            } else if (result.errors && result.errors.length > 0) {
                console.error('Update errors:', result.errors);
                throw new Error(result.errors[0].message);
            }
        } catch (error: any) {
            console.error('Error approving rider:', error);
            toast({
                variant: "destructive",
                title: "Error",
                description: error.message || "Failed to approve rider. Check console for details.",
            });
        } finally {
            setProcessingId(null);
        }
    };

    // Function to reject a rider application
    const handleReject = async (riderId: string, riderName: string) => {
        // Prevent multiple simultaneous rejections
        if (processingId) return;

        setProcessingId(riderId);

        try {
            // Update rider status via API
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
            const response = await fetch(`${apiUrl}/api/riders/${riderId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: 'rejected' })
            });

            const result = { data: response.ok };

            if (result.data) {
                console.log('Rider rejection successful:', result.data);

                toast({
                    title: "Rider Rejected",
                    description: `${riderName}'s application has been rejected.`,
                });

                // Update local state immediately to reflect change
                setRiders(prev => prev.map(r =>
                    r.id === riderId ? { ...r, status: 'rejected' } : r
                ));
            }
        } catch (error) {
            console.error('Error rejecting rider:', error);
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to reject rider",
            });
        } finally {
            setProcessingId(null);
        }
    };

    // Filter riders by status
    const pendingApplications = riders.filter(r => r.status === 'pending');
    const approvedRiders = riders.filter(r => r.status === 'approved');

    return (
        <div className="space-y-8">
            {/* Page header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-4xl font-bold font-headline">Rider Management</h1>
                    <p className="text-muted-foreground mt-2 text-lg">
                        {pendingApplications.length} pending applications
                    </p>
                </div>
                <Button variant="outline" onClick={fetchApplications} disabled={loading}>
                    <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                    Refresh
                </Button>
            </div>

            {/* Tabs for pending and approved riders */}
            <Tabs defaultValue="pending">
                <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="pending">
                        Pending Applications ({pendingApplications.length})
                    </TabsTrigger>
                    <TabsTrigger value="approved">
                        Approved Riders ({approvedRiders.length})
                    </TabsTrigger>
                </TabsList>

                {/* Pending Applications Tab */}
                <TabsContent value="pending" className="mt-6">
                    <Card>
                        <CardHeader>
                            <CardTitle>Pending Applications</CardTitle>
                            <CardDescription>Review and approve new rider applications.</CardDescription>
                        </CardHeader>
                        <CardContent>
                            {loading ? (
                                <div className="flex justify-center py-10">
                                    <Loader2 className="h-8 w-8 animate-spin" />
                                </div>
                            ) : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>Full Name</TableHead>
                                            <TableHead>Email</TableHead>
                                            <TableHead>Phone</TableHead>
                                            <TableHead>Zone</TableHead>
                                            <TableHead className="text-right">Actions</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {pendingApplications.length > 0 ? (
                                            pendingApplications.map((app) => (
                                                <TableRow key={app.id}>
                                                    <TableCell className="font-medium">{app.fullName}</TableCell>
                                                    <TableCell>{app.email}</TableCell>
                                                    <TableCell>{app.phone}</TableCell>
                                                    <TableCell className="capitalize">{app.zone.replace('-', ' ')}</TableCell>
                                                    <TableCell className="text-right space-x-2">
                                                        <Button
                                                            variant="destructive"
                                                            size="sm"
                                                            onClick={() => handleReject(app.id, app.fullName)}
                                                            disabled={processingId === app.id}
                                                        >
                                                            {processingId === app.id && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                                            Reject
                                                        </Button>
                                                        <Button
                                                            size="sm"
                                                            onClick={() => handleApprove(app)}
                                                            disabled={processingId === app.id}
                                                        >
                                                            {processingId === app.id && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                                                            Approve
                                                        </Button>
                                                    </TableCell>
                                                </TableRow>
                                            ))
                                        ) : (
                                            <TableRow>
                                                <TableCell colSpan={5} className="h-24 text-center">
                                                    No pending applications at this time.
                                                </TableCell>
                                            </TableRow>
                                        )}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Approved Riders Tab */}
                <TabsContent value="approved" className="mt-6">
                    <Card>
                        <CardHeader>
                            <CardTitle>Approved Riders</CardTitle>
                            <CardDescription>List of all active riders on the platform.</CardDescription>
                        </CardHeader>
                        <CardContent>
                            {loading ? (
                                <div className="flex justify-center py-10">
                                    <Loader2 className="h-8 w-8 animate-spin" />
                                </div>
                            ) : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>Full Name</TableHead>
                                            <TableHead>Email</TableHead>
                                            <TableHead>Phone</TableHead>
                                            <TableHead>Zone</TableHead>
                                            <TableHead>Status</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {approvedRiders.length > 0 ? (
                                            approvedRiders.map((rider) => (
                                                <TableRow key={rider.id}>
                                                    <TableCell className="font-medium">{rider.fullName}</TableCell>
                                                    <TableCell>{rider.email}</TableCell>
                                                    <TableCell>{rider.phone}</TableCell>
                                                    <TableCell className="capitalize">{rider.zone.replace('-', ' ')}</TableCell>
                                                    <TableCell>
                                                        <Badge
                                                            variant={rider.isOnline ? 'default' : 'secondary'}
                                                            className={rider.isOnline ? 'bg-green-600 hover:bg-green-700' : ''}
                                                        >
                                                            {rider.isOnline ? 'Online' : 'Offline'}
                                                        </Badge>
                                                    </TableCell>
                                                </TableRow>
                                            ))
                                        ) : (
                                            <TableRow>
                                                <TableCell colSpan={5} className="h-24 text-center">
                                                    No approved riders yet.
                                                </TableCell>
                                            </TableRow>
                                        )}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </div>
    );
}