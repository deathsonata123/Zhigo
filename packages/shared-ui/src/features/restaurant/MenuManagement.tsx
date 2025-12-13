// packages/shared-ui/src/features/restaurant/MenuManagement.tsx
'use client';

import { useState, useEffect } from 'react';
import { Button } from "../../components/ui/button";
import { PlusCircle, Edit, Trash2 } from "lucide-react";
import { AddMenuItemDialog } from '../../components/add-menu-item-dialog';
import type { MenuItem } from '@food-delivery/shared-utils';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../../components/ui/card';
import Image from 'next/image';
import { Skeleton } from '../../components/ui/skeleton';
import { Switch } from '../../components/ui/switch';
import { Label } from '../../components/ui/label';
import { useToast } from '../../hooks/use-toast';
import { EditMenuItemDialog } from '../../components/edit-menu-item-dialog';
// Amplify imports for database operations and authentication
import { getCurrentUser } from 'aws-amplify/auth';
import { getUrl } from 'aws-amplify/storage';

// Initialize Amplify client for database operations

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

    // Step 3: Once we have restaurant ID, fetch menu items and subscribe to real-time updates
    useEffect(() => {
        if (restaurantId) {
            fetchMenuItems();
            
            // Subscribe to real-time updates - any changes to menu items will automatically update the UI
            // This includes: additions, deletions, and updates from any source
            const subscription = client.models.MenuItem.observeQuery({
                filter: { restaurantId: { eq: restaurantId } } // Only get items for this restaurant
            }).subscribe({
                next: async ({ items }: any) => {
                    const menuItemsData = items as MenuItem[];
                    setMenuItems(menuItemsData);
                    
                    // Fetch signed URLs for all images from S3
                    // S3 URLs are temporary and must be regenerated each time
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
                },
                error: (error: any) => {
                    console.error('Subscription error:', error);
                    toast({
                        title: "Error",
                        description: "Failed to sync menu items",
                        variant: "destructive"
                    });
                }
            });

            // Cleanup: Unsubscribe when component unmounts or restaurantId changes
            return () => subscription.unsubscribe();
        }
    }, [restaurantId]);

    /**
     * Fetch the currently logged-in user from AWS Cognito
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
            // Query the Restaurant table for restaurants owned by this user
            const { data: restaurants } = await client.models.Restaurant.list({
                filter: { 
                    ownerId: { eq: currentUserId } // Match the ownerId field with current user
                }
            });

            if (restaurants && restaurants.length > 0) {
                // Use the first restaurant (assuming one restaurant per owner)
                setRestaurantId(restaurants[0].id);
            } else {
                // No restaurant found - user needs to register their restaurant first
                toast({
                    title: "No Restaurant Found",
                    description: "Please register your restaurant first before adding menu items",
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
            // Query MenuItem table filtered by restaurantId
            const { data: items } = await client.models.MenuItem.list({
                filter: { restaurantId: { eq: restaurantId } }
            });

            const menuItemsData = items as MenuItem[];
            setMenuItems(menuItemsData);

            // Generate signed URLs for all menu item images
            const urls: Record<string, string> = {};
            for (const item of menuItemsData) {
                if (item.imageUrl) {
                    try {
                        // getUrl generates a temporary signed URL for accessing S3 objects
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
            // Update only the isAvailable field in the database
            await client.models.MenuItem.update({
                id: itemId,
                isAvailable: newAvailability
            });

            toast({
                title: "Success",
                description: `Item is now ${newAvailability ? 'available' : 'unavailable'}`,
            });
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
            // Delete the menu item from the database
            await client.models.MenuItem.delete({ id: itemId });

            toast({
                title: "Success",
                description: "Menu item deleted successfully",
            });
            // Note: No need to manually update the UI - the real-time subscription will handle it
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
                                        checked={item.isAvailable ?? true}
                                        onCheckedChange={(checked) => handleAvailabilityChange(item.id, checked)}
                                    />
                                    <Label htmlFor={`available-${item.id}`} className="text-sm font-medium">
                                        {item.isAvailable ? 'Available' : 'Unavailable'}
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