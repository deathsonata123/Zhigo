'use client';

import React, { useState, useEffect } from 'react'; // FIXED: Added React import
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Loader2, PlusCircle, Upload } from 'lucide-react';
import Image from 'next/image';

import { Button } from './ui/button';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from './ui/form';
import { Input } from './ui/input';
import { Textarea } from './ui/textarea';
import { useToast } from '../hooks/use-toast';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';

import { uploadData } from '../lib/storage';
import { getUrl } from '../lib/storage';

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

const menuCategories = ["Appetizer", "Main Course", "Dessert", "Beverage", "Other"];

interface EditMenuItemDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  item: MenuItem;
  onItemUpdated: () => void;
  userId: string;
}

const formSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters."),
  description: z.string().min(10, "Description must be at least 10 characters."),
  price: z.coerce.number().min(0, "Price must be a positive number."),
  category: z.string().min(1, "Please select a category."),
  photo: z.any().optional(),
});

export function EditMenuItemDialog({ open, onOpenChange, item, onItemUpdated, userId }: EditMenuItemDialogProps) {
  const { toast } = useToast();
  const [formSubmitting, setFormSubmitting] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);
  const [currentImageUrl, setCurrentImageUrl] = useState<string | null>(null);
  const [newImageFile, setNewImageFile] = useState<File | null>(null);

  const form = useForm<z.infer<typeof formSchema>>({
    // FIXED: Cast resolver to any
    resolver: zodResolver(formSchema) as any,
    defaultValues: {
      name: item.name,
      description: item.description || '',
      price: item.price,
      category: item.category,
    },
  });

  useEffect(() => {
    form.reset({
      name: item.name,
      description: item.description || '',
      price: item.price,
      category: item.category,
    });

    setPreview(null);
    setNewImageFile(null);

    const fetchImageUrl = async () => {
      if (item.imageUrl) {
        try {
          if (item.imageUrl.startsWith('http')) {
            setCurrentImageUrl(item.imageUrl);
          } else {
            const result = await getUrl({ path: item.imageUrl });
            setCurrentImageUrl(result.url.toString());
          }
        } catch (error) {
          console.error('Error fetching image URL:', error);
        }
      }
    };

    fetchImageUrl();
  }, [item, form]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setNewImageFile(file);

      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  async function onSubmit(values: z.infer<typeof formSchema>) {
    setFormSubmitting(true);
    try {
      let imageUrl = item.imageUrl;

      if (newImageFile) {
        const timestamp = Date.now();
        const fileName = `${timestamp}-${newImageFile.name.replace(/[^a-zA-Z0-9.-]/g, '_')}`;


        await uploadData({
          path: `menu-images/${fileName}`,
          data: newImageFile,
          options: {
            contentType: newImageFile.type,
          }
        });

        imageUrl = `menu-images/${fileName}`;
        console.log('✅ New image uploaded:', imageUrl);
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/menu-items/${item.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: values.name,
          description: values.description,
          price: values.price,
          category: values.category,
          imageUrl: imageUrl,
        })
      });

      if (!response.ok) throw new Error('Failed to update menu item');

      console.log('✅ Menu item updated successfully');

      toast({
        title: "Success",
        description: "Menu item updated successfully.",
      });

      onItemUpdated();
      onOpenChange(false);

    } catch (error) {
      console.error('❌ Error updating menu item:', error);
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to update menu item.",
      });
    } finally {
      setFormSubmitting(false);
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle className="text-2xl font-headline">Edit: {item.name}</DialogTitle>
          <DialogDescription>
            Modify details, manage add-ons, or schedule availability.
          </DialogDescription>
        </DialogHeader>

        <Tabs defaultValue="details">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="details">Details</TabsTrigger>
            <TabsTrigger value="addons">Add-ons</TabsTrigger>
            <TabsTrigger value="scheduling">Scheduling</TabsTrigger>
          </TabsList>

          <TabsContent value="details">
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 pt-4">
                <div className="space-y-2">
                  <FormLabel>Item Photo</FormLabel>

                  {preview ? (
                    <div className="relative w-full h-48 rounded-lg overflow-hidden">
                      <Image src={preview} alt="New preview" fill className="object-cover" />
                      <p className="absolute bottom-2 left-2 bg-black/70 text-white text-xs px-2 py-1 rounded">
                        New image (not saved yet)
                      </p>
                    </div>
                  ) : currentImageUrl ? (
                    <div className="relative w-full h-48 rounded-lg overflow-hidden">
                      <Image src={currentImageUrl} alt={item.name} fill className="object-cover" />
                    </div>
                  ) : null}

                  <div className="flex items-center justify-center w-full">
                    <label htmlFor="photo-upload-edit" className="flex flex-col items-center justify-center w-full h-20 border-2 border-dashed rounded-lg cursor-pointer hover:bg-muted">
                      <div className="flex items-center gap-2">
                        <Upload className="w-5 h-5 text-muted-foreground" />
                        <span className="text-sm text-muted-foreground font-semibold">
                          {preview || currentImageUrl ? 'Change Image' : 'Upload Image'}
                        </span>
                      </div>
                      <Input
                        id="photo-upload-edit"
                        type="file"
                        className="sr-only"
                        onChange={handleFileChange}
                        accept="image/*"
                      />
                    </label>
                  </div>
                </div>

                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Item Name</FormLabel>
                      <FormControl>
                        <Input {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="description"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Description</FormLabel>
                      <FormControl>
                        <Textarea {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    control={form.control}
                    name="price"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Price ($)</FormLabel>
                        <FormControl>
                          <Input type="number" step="0.01" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="category"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Category</FormLabel>
                        <Select onValueChange={field.onChange} value={field.value}>
                          <FormControl>
                            <SelectTrigger>
                              <SelectValue placeholder="Select" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            {menuCategories.map((category) => (
                              <SelectItem key={category} value={category}>
                                {category}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <DialogFooter className="pt-4">
                  <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
                    Cancel
                  </Button>
                  <Button type="submit" disabled={formSubmitting}>
                    {formSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                    Save Changes
                  </Button>
                </DialogFooter>
              </form>
            </Form>
          </TabsContent>

          <TabsContent value="addons">
            <Card>
              <CardHeader>
                <CardTitle>Add-on Groups</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-muted-foreground text-sm">
                  Add-on management coming soon! This will allow you to add extras like:
                </p>
                <ul className="text-sm text-muted-foreground list-disc list-inside space-y-1">
                  <li>Extra cheese, toppings, or sides</li>
                  <li>Drink options</li>
                  <li>Size variations</li>
                  <li>Customization options</li>
                </ul>
                <Button variant="outline" disabled>
                  <PlusCircle className="mr-2" />
                  Add Group
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="scheduling">
            <Card>
              <CardHeader>
                <CardTitle>Availability Rules</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-muted-foreground text-sm">
                  Schedule availability coming soon! This will allow you to:
                </p>
                <ul className="text-sm text-muted-foreground list-disc list-inside space-y-1">
                  <li>Set specific hours when items are available</li>
                  <li>Create day-of-week schedules (e.g., breakfast items)</li>
                  <li>Set temporary unavailability</li>
                  <li>Manage seasonal items</li>
                </ul>
                <Button variant="outline" disabled>
                  <PlusCircle className="mr-2" />
                  Add Rule
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

      </DialogContent>
    </Dialog>
  );
}
