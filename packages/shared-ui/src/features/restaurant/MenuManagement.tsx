// packages/shared-ui/src/features/restaurant/MenuManagement.tsx
'use client';

import { useState, useEffect } from 'react';
import { Button } from "../../components/ui/button";
import { PlusCircle, Edit, Trash2 } from "lucide-react";
import { AddMenuItemDialog } from '../../components/add-menu-item-dialog';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../../components/ui/card';
import Image from 'next/image';
import { Skeleton } from '../../components/ui/skeleton';


interface MenuItem {
    id: string;
    name: string;
    description: string;
    price: number;
    category: string;
    imageUrl?: string;
    available: boolean;
    restaurantId: string;
}

import { Switch } from '../../components/ui/switch';
import { Label } from '../../components/ui/label';
import { useToast } from '../../hooks/use-toast';
import { EditMenuItemDialog } from '../../components/edit-menu-item-dialog';
// Backend utility imports
import { getUrl } from '../../lib/storage';
import { getCurrentUser } from '../../lib/auth';


export default function MenuPage() {
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [selectedMenuItem, setSelectedMenuItem] = useState<MenuItem | null>(null);
    const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
    const [menuLoading, setMenuLoading] = useState(true);

    // Store restaurant ID and user ID for database queries
    const [restaurantId, setRestaurantId] = useState<string | null>(null);
    const [currentUserId, setCurrentUserId] = useState<string | null>(null);

    // Store signed S3 URLs for images (these expire, so we fetch them dynamically)
    const [imageUrls, setImageUrls] = useState<Record<string, string>>({});

    const { toast } = useToast();

    // Step 1: Get the current authenticated user when component mounts
    useEffect(() => {
        fetchCurrentUser();
    }, []);

    // Step 2: Once we have the user ID, fetch their restaurant
    useEffect(() => {
        if (currentUserId) {
            fetchRestaurantId();
        }
    }, [currentUserId]);

    useEffect(() => {
        if (restaurantId) {
            fetchMenuItems();

            // TODO: Implement WebSocket or polling for real-time menu updates
            // Subscription removed - implement alternative real-time solution
            // For now, menu will update on component mount and after CRUD operations
        }
    }, [restaurantId]);

    /**
     * Fetch the currently logged-in user from the backend
     */
    const fetchCurrentUser = async () => {
        try {
            const user = await getCurrentUser();
            setCurrentUserId(user.userId);
        } catch (error) {
            console.error('Error fetching current user:', error);
            toast({
                title: "Authentication Error",
                description: "Please sign in to manage your menu",
                variant: "destructive"
            });
            setMenuLoading(false);
        }
    };

    /**
     * Fetch the restaurant associated with the current user
     * Each restaurant owner should have exactly one restaurant
     */
    const fetchRestaurantId = async () => {
        if (!currentUserId) return;

        try {
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
            const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?ownerId=${currentUserId}`);

            if (restaurantsRes.ok) {
                const restaurants = await restaurantsRes.json();
                if (restaurants && restaurants.length > 0) {
                    setRestaurantId(restaurants[0].id);
                } else {
                    toast({
                        title: "No Restaurant Found",
                        description: "Please register your restaurant first before adding menu items",
                        variant: "destructive"
                    });
                    setMenuLoading(false);
                }
            } else {
                toast({
                    title: "Error",
                    description: "Failed to load restaurant information",
                    variant: "destructive"
                });
                setMenuLoading(false);
            }
        } catch (error) {
            console.error('Error fetching restaurant:', error);
            toast({
                title: "Error",
                description: "Failed to load restaurant information",
                variant: "destructive"
            });
            setMenuLoading(false);
        }
    };

    /**
     * Fetch all menu items for the current restaurant
     * This is called once on initial load, then real-time subscription takes over
     */
    const fetchMenuItems = async () => {
        if (!restaurantId) return;

        try {
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
            const itemsRes = await fetch(`${apiUrl}/api/menu-items?restaurantId=${restaurantId}`);

            if (!itemsRes.ok) throw new Error('Failed to fetch menu items');
            const items = await itemsRes.json();

            const menuItemsData = items as MenuItem[];
            setMenuItems(menuItemsData);

            // Generate signed URLs for all menu item images
            const urls: Record<string, string> = {};
            for (const item of menuItemsData) {
                if (item.imageUrl) {
                    try {
                        const result = await getUrl({ path: item.imageUrl });
                        urls[item.id] = result.url.toString();
                    } catch (error) {
                        console.error(`Error fetching image URL for ${item.id}:`, error);
                    }
                }
            }
            setImageUrls(urls);
            setMenuLoading(false);
        } catch (error) {
            console.error('Error fetching menu items:', error);
            toast({
                title: "Error",
                description: "Failed to load menu items",
                variant: "destructive"
            });
            setMenuLoading(false);
        }
    };

    /**
     * Open the edit dialog for a specific menu item
     */
    const handleEditClick = (item: MenuItem) => {
        setSelectedMenuItem(item);
        setIsEditDialogOpen(true);
    };

    /**
     * Toggle the availability status of a menu item
     * This allows restaurant owners to temporarily disable items without deleting them
     */
    const handleAvailabilityChange = async (itemId: string, newAvailability: boolean) => {
        try {
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
            const updateRes = await fetch(`${apiUrl}/api/menu-items/${itemId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ isAvailable: newAvailability })
            });

            if (!updateRes.ok) throw new Error('Failed to update availability');

            toast({
                title: "Success",
                description: `Item is now ${newAvailability ? 'available' : 'unavailable'}`,
            });

            // Refresh menu items
            await fetchMenuItems();
        } catch (error) {
            console.error('Error updating availability:', error);
            toast({
                title: "Error",
                description: "Failed to update availability",
                variant: "destructive"
            });
        }
    };

    /**
     * Delete a menu item permanently from the database
     */
    const handleDeleteItem = async (itemId: string) => {
        // Confirm before deleting
        if (!confirm('Are you sure you want to delete this menu item?')) {
            return;
        }

        try {
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';
            const deleteRes = await fetch(`${apiUrl}/api/menu-items/${itemId}`, {
                method: 'DELETE'
            });

            if (!deleteRes.ok) throw new Error('Failed to delete menu item');

            toast({
                title: "Success",
                description: "Menu item deleted successfully",
            });

            // Refresh menu items
            await fetchMenuItems();
        } catch (error) {
            console.error('Error deleting item:', error);
            toast({
                title: "Error",
                description: "Failed to delete menu item",
                variant: "destructive"
            });
        }
    };

    /**
     * Called when a new menu item is successfully added
     * Close the dialog - real-time subscription will automatically show the new item
     */
    const handleItemAdded = () => {
        setIsAddDialogOpen(false);
    };

    /**
     * Called when a menu item is successfully updated
     * Close the dialog - real-time subscription will automatically show the changes
     */
    const handleItemUpdated = () => {
        setIsEditDialogOpen(false);
    };

    return (
        <div>
            {/* Header section with title and "Add Menu Item" button */}
            <div className="flex justify-between items-center mb-8">
                <div>
                    <h1 className="text-4xl font-bold font-headline">Menu Management</h1>
                    <p className="text-muted-foreground mt-2 text-lg">Add, edit, and manage your menu items.</p>
                </div>
                <Button
                    onClick={() => setIsAddDialogOpen(true)}
                    disabled={!restaurantId} // Disable if no restaurant is found
                >
                    <PlusCircle className="mr-2" />
                    Add Menu Item
                </Button>
            </div>

            {/* Loading state - show skeleton cards while data is being fetched */}
            {menuLoading ? (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {Array.from({ length: 3 }).map((_, i) => (
                        <Card key={i}>
                            <CardHeader>
                                <Skeleton className="h-40 w-full rounded-t-lg" />
                                <Skeleton className="h-6 w-3/4 mt-4" />
                                <Skeleton className="h-4 w-1/4" />
                            </CardHeader>
                            <CardContent>
                                <Skeleton className="h-6 w-1/3 mb-2" />
                            </CardContent>
                            <CardFooter className="flex justify-between">
                                <div className="flex items-center space-x-2">
                                    <Skeleton className="h-5 w-10" />
                                    <Skeleton className="h-4 w-16" />
                                </div>
                                <div className="flex gap-2">
                                    <Skeleton className="h-8 w-8" />
                                    <Skeleton className="h-8 w-8" />
                                </div>
                            </CardFooter>
                        </Card>
                    ))}
                </div>
            ) : menuItems.length > 0 ? (
                /* Menu items grid - display all items for this restaurant */
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {menuItems.map((item) => (
                        <Card key={item.id} className="flex flex-col">
                            {/* Menu item image from S3 */}
                            <div className="relative aspect-video">
                                <Image
                                    src={imageUrls[item.id] || '/placeholder-food.jpg'} // Use signed URL or fallback
                                    alt={item.name}
                                    fill
                                    className="object-cover rounded-t-lg"
                                    data-ai-hint="restaurant food plate"
                                />
                            </div>
                            {/* Menu item details */}
                            <CardHeader className="pb-2">
                                <CardTitle className="font-headline">{item.name}</CardTitle>
                                <CardDescription>{item.category}</CardDescription>
                            </CardHeader>
                            <CardContent className="flex-grow">
                                <p className="text-lg font-semibold text-primary">${item.price.toFixed(2)}</p>
                                {item.description && (
                                    <p className="text-sm text-muted-foreground mt-2 line-clamp-2">
                                        {item.description}
                                    </p>
                                )}
                            </CardContent>
                            {/* Footer with availability toggle and action buttons */}
                            <CardFooter className="flex justify-between items-center bg-muted/50 p-3">
                                {/* Availability toggle switch */}
                                <div className="flex items-center space-x-2">
                                    <Switch
                                        id={`available-${item.id}`}
                                        checked={item.available ?? true}
                                        onCheckedChange={(checked) => handleAvailabilityChange(item.id, checked)}
                                    />
                                    <Label htmlFor={`available-${item.id}`} className="text-sm font-medium">
                                        {item.available ? 'Available' : 'Unavailable'}
                                    </Label>
                                </div>
                                {/* Edit and Delete buttons */}
                                <div className="flex items-center gap-2">
                                    <Button variant="outline" size="icon" onClick={() => handleEditClick(item)}>
                                        <Edit className="h-4 w-4" />
                                    </Button>
                                    <Button
                                        variant="destructive"
                                        size="icon"
                                        onClick={() => handleDeleteItem(item.id)}
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </Button>
                                </div>
                            </CardFooter>
                        </Card>
                    ))}
                </div>
            ) : (
                /* Empty state - show when no menu items exist */
                <div className="border-2 border-dashed rounded-lg p-12 text-center">
                    <p className="text-muted-foreground">
                        {!restaurantId
                            ? "Please register your restaurant first before adding menu items."
                            : "You haven't added any menu items yet. Click 'Add Menu Item' to get started."
                        }
                    </p>
                </div>
            )}

            {/* Add Menu Item Dialog - only render if we have restaurant and user data */}
            {restaurantId && currentUserId && (
                <AddMenuItemDialog
                    open={isAddDialogOpen}
                    onOpenChange={setIsAddDialogOpen}
                    onItemAdded={handleItemAdded}
                    restaurantId={restaurantId}
                    userId={currentUserId}
                />
            )}

            {/* Edit Menu Item Dialog - only render when an item is selected */}
            {selectedMenuItem && currentUserId && (
                <EditMenuItemDialog
                    key={selectedMenuItem.id} // Re-mount component when item changes
                    open={isEditDialogOpen}
                    onOpenChange={setIsEditDialogOpen}
                    item={selectedMenuItem as any}
                    onItemUpdated={handleItemUpdated}
                    userId={currentUserId}
                />
            )}
        </div>
    );
}
