"use client";

import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import Image from "next/image";
import { Upload, Loader2, Plus } from "lucide-react";

import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogTrigger,
} from "./ui/dialog";
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "./ui/form";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Button } from "./ui/button";

import { uploadData } from "aws-amplify/storage";

const menuCategories = ["Appetizer", "Main Course", "Dessert", "Beverage", "Other"];

const formSchema = z.object({
  name: z.string().min(1, "Name is required"),
  description: z.string().min(1, "Description is required"),
  price: z.coerce.number().min(0, "Price must be positive"),
  category: z.string().min(1, "Category is required"),
  photo: z.any().optional(),
});

type FormValues = z.infer<typeof formSchema>;

// FIXED: Added missing props to interface
interface AddMenuItemDialogProps {
  open: boolean;                              // ← ADD THIS
  onOpenChange: (open: boolean) => void;      // ← ADD THIS
  restaurantId: string;
  userId: string;                             // ← ADD THIS
  onItemAdded?: () => void;                   // ← RENAMED from onSuccess
}

export function AddMenuItemDialog({
  open,
  onOpenChange,
  restaurantId,
  userId,
  onItemAdded,
}: AddMenuItemDialogProps): React.ReactElement {
  const [formSubmitting, setFormSubmitting] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      name: "",
      description: "",
      price: 0,
      category: "",
      photo: undefined,
    },
  });

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      form.setValue("photo", file);
      const reader = new FileReader();
      reader.onloadend = () => setPreview(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  async function onSubmit(values: FormValues) {
    setFormSubmitting(true);
    try {
      let imageUrl = "https://images.unsplash.com/photo-1546069901-ba9599a7e63c";

      const file = values.photo as File;

      if (file instanceof File) {
        const timestamp = Date.now();
        const fileName = `${timestamp}-${file.name.replace(/[^a-zA-Z0-9.-]/g, "_")}`;

        const uploadResult = await uploadData({
          path: ({ identityId }) => `menu-images/${identityId}/${fileName}`,
          data: file,
          options: { contentType: file.type },
        }).result;

        imageUrl = uploadResult.path;
        console.log('✅ Image uploaded successfully:', imageUrl);
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/menu-items`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          restaurantId,
          name: values.name,
          description: values.description,
          price: values.price,
          category: values.category,
          imageUrl: imageUrl,
          isAvailable: true,
        })
      });

      if (!response.ok) throw new Error('Failed to create menu item');

      console.log('✅ Menu item created successfully');

      form.reset();
      setPreview(null);
      onOpenChange(false);  // ← FIXED: Use onOpenChange instead of setOpen
      onItemAdded?.();      // ← FIXED: Use onItemAdded instead of onSuccess
    } catch (error) {
      console.error("❌ Error adding menu item:", error);
      alert("Failed to add menu item. Please try again.");
    } finally {
      setFormSubmitting(false);
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[480px]">
        <DialogHeader>
          <DialogTitle className="text-2xl font-headline">Add New Menu Item</DialogTitle>
          <DialogDescription>
            Fill in the details below to add a new item to your menu.
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 pt-4">
            <FormField
              control={form.control}
              name="photo"
              render={() => (
                <FormItem>
                  <FormLabel>Item Photo</FormLabel>
                  <FormControl>
                    <div className="flex items-center justify-center w-full">
                      <label
                        htmlFor="photo-upload-dialog"
                        className="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed rounded-lg cursor-pointer hover:bg-muted"
                      >
                        {preview ? (
                          <Image
                            src={preview}
                            alt="Item preview"
                            width={100}
                            height={100}
                            className="h-28 w-auto object-contain rounded-md p-1"
                            unoptimized
                          />
                        ) : (
                          <div className="flex flex-col items-center justify-center pt-5 pb-6">
                            <Upload className="w-8 h-8 mb-2 text-muted-foreground" />
                            <p className="mb-2 text-sm text-muted-foreground">
                              <span className="font-semibold">Click to upload</span>
                            </p>
                          </div>
                        )}
                        <Input
                          id="photo-upload-dialog"
                          type="file"
                          className="sr-only"
                          onChange={handleFileChange}
                          accept="image/*"
                        />
                      </label>
                    </div>
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Item Name</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Spaghetti Carbonara" {...field} />
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
                    <Textarea placeholder="A brief description of the menu item..." {...field} />
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
                      <Input type="number" step="0.01" placeholder="12.99" {...field} />
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
                Add Item
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}