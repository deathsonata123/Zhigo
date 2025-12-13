'use client';

import Image from 'next/image';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from '../../components/ui/card';
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from '../../components/ui/carousel';
import { PlusCircle, Star, MapPin, Trash2, ShoppingCart, Info, Clock, Heart, Phone, MessageSquare, Search, ChevronRight } from 'lucide-react';
import { useEffect, useState, useMemo, useRef } from 'react';
import { Skeleton } from '../../components/ui/skeleton';
import { Separator } from '../../components/ui/separator';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';
import { Calendar } from "../../components/ui/calendar";
import { addDays, format } from "date-fns";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Input } from '../../components/ui/input';
import { Textarea } from '../../components/ui/textarea';
import { Label } from '../../components/ui/label';
import { RadioGroup, RadioGroupItem } from '../../components/ui/radio-group';
import { useToast } from '../../hooks/use-toast';
import Link from 'next/link';
import { getUrl } from 'aws-amplify/storage';
import { getCurrentUser } from 'aws-amplify/auth';
import { Avatar, AvatarFallback } from '../../components/ui/avatar';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../../components/ui/dialog';
import { FloatingChatbot } from '../../components/FloatingChatbot';

// FIX 1: Cast client to 'any' to fix build errors

type Restaurant = {
  id: string;
  name: string;
  address: string;
  imageUrl: string;
  email: string;
  phone: string;
  ownerId: string;
  status: string;
};

type MenuItem = {
  id: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: string;
  isAvailable: boolean;
};

type OpeningHour = {
  id: string;
  dayOfWeek: number;
  isOpen: boolean;
  openTime: string;
  closeTime: string;
};

type Review = {
  id: string;
  userName: string;
  rating: number;
  comment: string;
  orderType: string;
  createdAt: string;
};

type CartItem = MenuItem & { quantity: number };

const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

interface RestaurantDetailsProps {
  restaurantId: string;
}

export function RestaurantDetails({ restaurantId: id }: RestaurantDetailsProps) {
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
  const [imageUrls, setImageUrls] = useState<Record<string, string>>({});
  const [openingHours, setOpeningHours] = useState<OpeningHour[]>([]);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [averageRating, setAverageRating] = useState(0);
  const [loading, setLoading] = useState(true);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [date, setDate] = useState<Date | undefined>(new Date());
  const [partySize, setPartySize] = useState(2);
  const [hour, setHour] = useState<string | null>(null);
  const [minute, setMinute] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const categoriesContainerRef = useRef<HTMLDivElement>(null);
  const { toast } = useToast();

  const [reviewDialogOpen, setReviewDialogOpen] = useState(false);
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewComment, setReviewComment] = useState('');
  const [reviewOrderType, setReviewOrderType] = useState('delivery');
  const [submittingReview, setSubmittingReview] = useState(false);
  const [userAuthenticated, setUserAuthenticated] = useState(false);

  const hours = Array.from({ length: 5 }, (_, i) => 17 + i);
  const minutes = ['00', '15', '30', '45'];

  const formatTime = (time: string) => {
    const [hours, minutes] = time.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:${minutes} ${ampm}`;
  };

  const renderStars = (rating: number, interactive: boolean = false, onRatingChange?: (rating: number) => void) => {
    return (
      <div className="flex items-center gap-1">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            className={`h-5 w-5 ${interactive ? 'cursor-pointer hover:scale-110 transition-transform' : ''} ${i < rating ? 'fill-amber-400 text-amber-400' : 'text-gray-300'
              }`}
            onClick={() => interactive && onRatingChange && onRatingChange(i + 1)}
          />
        ))}
      </div>
    );
  };

  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
    }
    return name.slice(0, 2).toUpperCase();
  };

  useEffect(() => {
    const checkAuth = async () => {
      try {
        await getCurrentUser();
        setUserAuthenticated(true);
      } catch {
        setUserAuthenticated(false);
      }
    };
    checkAuth();
  }, []);

  useEffect(() => {
    const fetchRestaurantAndMenu = async () => {
      try {
        setLoading(true);

        const { data: restaurantData } = await client.models.Restaurant.get({ id });

        if (!restaurantData) {
          return;
        }

        let restaurantImageUrl = 'https://picsum.photos/seed/default/600/400';
        if (restaurantData.photoUrl) {
          try {
            if (restaurantData.photoUrl.startsWith('http')) {
              restaurantImageUrl = restaurantData.photoUrl;
            } else {
              const urlResult = await getUrl({ path: restaurantData.photoUrl });
              restaurantImageUrl = urlResult.url.toString();
            }
          } catch (error) {
            console.log('Error fetching restaurant image:', error);
          }
        }

        setRestaurant({
          id: restaurantData.id,
          name: restaurantData.name || '',
          address: restaurantData.address || '',
          imageUrl: restaurantImageUrl,
          email: restaurantData.email || '',
          phone: restaurantData.phone || '',
          ownerId: restaurantData.ownerId || '',
          status: restaurantData.status || '',
        });

        const { data: menuData } = await client.models.MenuItem.list({
          filter: { restaurantId: { eq: id } }
        });

        if (menuData && menuData.length > 0) {
          const urls: Record<string, string> = {};
          const items: MenuItem[] = [];

          for (const item of menuData) {
            let imageUrl = 'https://picsum.photos/seed/menu-default/600/400';

            if (item.imageUrl) {
              try {
                if (item.imageUrl.startsWith('http')) {
                  imageUrl = item.imageUrl;
                } else {
                  const result = await getUrl({ path: item.imageUrl });
                  imageUrl = result.url.toString();
                }
              } catch (error) {
                console.error(`Error fetching image for ${item.name}:`, error);
              }
            }

            urls[item.id] = imageUrl;
            items.push({
              id: item.id,
              name: item.name || '',
              description: item.description || '',
              price: item.price || 0,
              imageUrl: imageUrl,
              category: item.category || 'Other',
              isAvailable: item.isAvailable ?? true,
            });
          }

          setImageUrls(urls);
          setMenuItems(items);
        } else {
          setMenuItems([]);
        }

        const { data: hoursData } = await client.models.OpeningHours.list({
          filter: { restaurantId: { eq: id } }
        });

        if (hoursData && hoursData.length > 0) {
          // FIX 2: Explicit 'any' to fix implicit any error in sort
          const hours = hoursData.map((h: any) => ({
            id: h.id,
            dayOfWeek: h.dayOfWeek || 0,
            isOpen: h.isOpen ?? true,
            openTime: h.openTime || '09:00',
            closeTime: h.closeTime || '22:00',
          })).sort((a: any, b: any) => a.dayOfWeek - b.dayOfWeek);
          setOpeningHours(hours);
        } else {
          setOpeningHours([]);
        }

        const { data: reviewData } = await client.models.Review.list({
          filter: { restaurantId: { eq: id } }
        });

        if (reviewData && reviewData.length > 0) {
          // FIX 3: Explicit 'any' to fix implicit any error
          const mappedReviews = reviewData.map((r: any) => ({
            id: r.id,
            userName: r.userName || 'Anonymous',
            rating: r.rating || 0,
            comment: r.comment || '',
            orderType: r.orderType || 'delivery',
            createdAt: r.createdAt || new Date().toISOString(),
          }));

          // FIX 4: Explicit 'any' for sort parameters
          mappedReviews.sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

          setReviews(mappedReviews);

          // FIX 5: Explicit types for reduce parameters
          const totalRating = mappedReviews.reduce((sum: number, r: any) => sum + r.rating, 0);
          const avgRating = totalRating / mappedReviews.length;
          setAverageRating(Math.round(avgRating * 10) / 10);
        } else {
          setReviews([]);
          setAverageRating(0);
        }

      } catch (error) {
        console.error('❌ Error fetching restaurant data:', error);
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchRestaurantAndMenu();
    }
  }, [id]);

  const handleSubmitReview = async () => {
    if (!userAuthenticated) {
      toast({
        title: "Authentication Required",
        description: "Please sign in to leave a review.",
        variant: "destructive",
      });
      return;
    }

    try {
      setSubmittingReview(true);
      const user = await getCurrentUser();

      const userName = user.signInDetails?.loginId?.split('@')[0] || 'Customer';

      await client.models.Review.create({
        restaurantId: id,
        userId: user.userId,
        userName: userName,
        rating: reviewRating,
        comment: reviewComment,
        orderType: reviewOrderType,
      });

      toast({
        title: "Review Submitted",
        description: "Thank you for your feedback!",
      });

      setReviewDialogOpen(false);
      setReviewRating(5);
      setReviewComment('');
      setReviewOrderType('delivery');

      const { data: reviewData } = await client.models.Review.list({
        filter: { restaurantId: { eq: id } }
      });

      if (reviewData && reviewData.length > 0) {
        // Explicit typing fixes
        const mappedReviews = reviewData.map((r: any) => ({
          id: r.id,
          userName: r.userName || 'Anonymous',
          rating: r.rating || 0,
          comment: r.comment || '',
          orderType: r.orderType || 'delivery',
          createdAt: r.createdAt || new Date().toISOString(),
        }));

        mappedReviews.sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        setReviews(mappedReviews);

        const totalRating = mappedReviews.reduce((sum: number, r: any) => sum + r.rating, 0);
        const avgRating = totalRating / mappedReviews.length;
        setAverageRating(Math.round(avgRating * 10) / 10);
      }
    } catch (error) {
      console.error('Error submitting review:', error);
      toast({
        title: "Error",
        description: "Failed to submit review. Please try again.",
        variant: "destructive",
      });
    } finally {
      setSubmittingReview(false);
    }
  };

  const addToCart = (item: MenuItem) => {
    setCart((prevCart) => {
      const existingItem = prevCart.find((cartItem) => cartItem.id === item.id);
      if (existingItem) {
        return prevCart.map((cartItem) =>
          cartItem.id === item.id
            ? { ...cartItem, quantity: cartItem.quantity + 1 }
            : cartItem
        );
      } else {
        return [...prevCart, { ...item, quantity: 1 }];
      }
    });
  };

  const handleFavoriteClick = (itemName: string) => {
    toast({
      title: "Added to Favorites",
      description: `${itemName} has been saved to your favorites.`,
    });
  };

  const removeFromCart = (itemId: string) => {
    setCart((prevCart) => prevCart.filter((item) => item.id !== itemId));
  };

  const total = cart.reduce((acc, item) => acc + item.price * item.quantity, 0);

  const menuCategories = useMemo(() => {
    const categories = new Map<string, number>();
    const availableItems = menuItems.filter(item => item.isAvailable);
    categories.set('all', availableItems.length);
    availableItems.forEach(item => {
      categories.set(item.category, (categories.get(item.category) || 0) + 1);
    });
    return Array.from(categories.entries()).map(([name, count]) => ({ name, count }));
  }, [menuItems]);

  const filteredMenu = useMemo(() => {
    const availableMenu = menuItems.filter(item => item.isAvailable);
    const byCategory = selectedCategory === 'all'
      ? availableMenu
      : availableMenu.filter(item => item.category === selectedCategory);

    return byCategory.filter(item => item.name.toLowerCase().includes(searchQuery.toLowerCase()));
  }, [menuItems, selectedCategory, searchQuery]);

  const scrollCategories = (direction: 'left' | 'right') => {
    if (categoriesContainerRef.current) {
      const scrollAmount = direction === 'left' ? -200 : 200;
      categoriesContainerRef.current.scrollBy({ left: scrollAmount, behavior: 'smooth' });
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto py-12 px-4">
        <Skeleton className="h-10 w-full mb-8" />
        <div className="space-y-8">
          <div className="flex gap-8">
            <div className="w-1/2 space-y-4">
              <Skeleton className="h-12 w-3/4" />
              <Skeleton className="h-6 w-full" />
              <Skeleton className="h-6 w-2/3" />
            </div>
            <div className="w-1/2">
              <Skeleton className="h-64 w-full" />
            </div>
          </div>
          <Skeleton className="h-12 w-full" />
          <div className="flex gap-8">
            <div className="w-3/4 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <Skeleton className="h-48 w-full" />
                <Skeleton className="h-48 w-full" />
                <Skeleton className="h-48 w-full" />
              </div>
            </div>
            <div className="w-1/4 space-y-6">
              <Skeleton className="h-64 w-full" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!restaurant) {
    return <div className="p-8 text-center text-xl">Restaurant not found</div>;
  }

  const ContactCard = () => (
    <Card>
      <CardHeader>
        <CardTitle className="font-headline">Contact Us</CardTitle>
        <CardDescription>Have questions? Get in touch with the restaurant directly.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <Button asChild className="w-full">
          <a href={`tel:${restaurant.phone}`}>
            <Phone className="mr-2 h-4 w-4" /> Call {restaurant.phone}
          </a>
        </Button>
        <Button asChild variant="outline" className="w-full">
          <a href={`mailto:${restaurant.email}`}>
            <MessageSquare className="mr-2 h-4 w-4" /> Send a Message
          </a>
        </Button>
      </CardContent>
    </Card>
  );

  return (
    <div className="container mx-auto py-12 px-4">
      <Tabs defaultValue="menu" className="w-full">
        <div className="flex justify-center mb-12">
          <TabsList className="grid w-full max-w-2xl grid-cols-4 h-auto p-1">
            <TabsTrigger value="menu" className="py-3 px-6 text-sm font-medium">Menu</TabsTrigger>
            <TabsTrigger value="reservation" className="py-3 px-6 text-sm font-medium">Reservation</TabsTrigger>
            <TabsTrigger value="location" className="py-3 px-6 text-sm font-medium">Location</TabsTrigger>
            <TabsTrigger value="reviews" className="py-3 px-6 text-sm font-medium">Reviews</TabsTrigger>
          </TabsList>
        </div>

        <TabsContent value="menu">
          <div className="flex flex-col md:flex-row gap-8 items-start mb-8">
            <div className="w-full md:w-1/2">
              <header>
                <div className="flex items-center gap-4 mb-4">
                  <h1 className="text-5xl font-extrabold font-headline">{restaurant.name}</h1>
                  <Button variant="outline" size="icon" className="shrink-0" onClick={() => handleFavoriteClick(restaurant.name)}>
                    <Heart className="h-6 w-6" />
                  </Button>
                </div>
                <div className="flex flex-col gap-3 text-muted-foreground text-base">
                  <div className="flex items-center gap-2">
                    <Star className="w-4 h-4 text-amber-500 fill-amber-500" />
                    <span className="font-medium text-foreground">
                      {averageRating > 0 ? averageRating.toFixed(1) : '4.5'} ({reviews.length > 0 ? `${reviews.length}+ ratings` : '50+ ratings'})
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4" />
                    <span>{restaurant.address}</span>
                  </div>
                </div>
              </header>
            </div>
            <div className="w-full md:w-1/2">
              <Carousel opts={{ loop: true }} className="w-full max-w-lg mx-auto">
                <CarouselContent>
                  <CarouselItem>
                    <Image src={restaurant.imageUrl} alt={restaurant.name} width={600} height={400} className="rounded-lg object-cover aspect-[3/2]" unoptimized />
                  </CarouselItem>
                  <CarouselItem>
                    <Image src="https://picsum.photos/seed/dish/600/400" alt="Featured dish" width={600} height={400} className="rounded-lg object-cover aspect-[3/2]" />
                  </CarouselItem>
                </CarouselContent>
                <CarouselPrevious className="left-4" />
                <CarouselNext className="right-4" />
              </Carousel>
            </div>
          </div>

          <div className="sticky top-16 bg-background py-4 z-10 mb-8 border-b">
            <div className="flex items-center gap-4">
              <div className="relative flex-shrink-0 w-64">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search in menu"
                  className="pl-9"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
              <div ref={categoriesContainerRef} className="flex-grow flex items-center gap-4 overflow-x-auto pb-2 -mb-2 scrollbar-hide">
                {menuCategories.map(({ name, count }) => (
                  <Button
                    key={name}
                    variant={selectedCategory === name ? "default" : "ghost"}
                    onClick={() => setSelectedCategory(name)}
                    className="capitalize shrink-0"
                  >
                    {name === 'all' ? 'All' : name} ({count})
                  </Button>
                ))}
              </div>
              <Button variant="ghost" size="icon" className="shrink-0" onClick={() => scrollCategories('right')}>
                <ChevronRight className="h-5 w-5" />
              </Button>
            </div>
          </div>

          <div className="flex flex-col md:flex-row gap-8 items-start">
            <div className="w-full md:w-3/4">
              {menuItems.length === 0 ? (
                <Card>
                  <CardContent className="py-12 text-center">
                    <p className="text-muted-foreground text-lg">This restaurant hasn't added any menu items yet.</p>
                    <p className="text-sm text-muted-foreground mt-2">Check back soon!</p>
                  </CardContent>
                </Card>
              ) : filteredMenu.length === 0 ? (
                <p className="text-muted-foreground text-center py-12">No items found for this category or search query.</p>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {filteredMenu.map((item: MenuItem) => (
                    <Card key={item.id} className="flex flex-col overflow-hidden hover:shadow-md transition-shadow group">
                      <div className="relative aspect-video">
                        <Image
                          src={imageUrls[item.id] || item.imageUrl}
                          alt={item.name}
                          fill
                          className="object-cover"
                          unoptimized
                        />
                        <Button
                          variant="secondary"
                          size="icon"
                          className="absolute top-2 right-2 h-8 w-8 rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                          onClick={() => handleFavoriteClick(item.name)}
                        >
                          <Heart className="h-4 w-4 text-primary" />
                        </Button>
                      </div>
                      <CardHeader>
                        <h3 className="text-lg font-bold font-headline">{item.name}</h3>
                        <p className="text-sm text-muted-foreground line-clamp-2">{item.description}</p>
                      </CardHeader>
                      <CardContent className="flex-grow">
                        <p className="text-lg font-semibold text-primary">${item.price.toFixed(2)}</p>
                      </CardContent>
                      <CardFooter className="grid grid-cols-2 gap-2 p-2">
                        <Button variant="outline" size="sm">
                          <Info className="mr-2 h-4 w-4" /> More Info
                        </Button>
                        <Button size="sm" onClick={() => addToCart(item)}>
                          <PlusCircle className="mr-2 h-4 w-4" /> Add
                        </Button>
                      </CardFooter>
                    </Card>
                  ))}
                </div>
              )}
            </div>

            <aside className="w-full md:w-1/4 space-y-6 sticky top-24">
              <Card className="bg-secondary/50">
                <CardHeader>
                  <CardTitle className="font-headline">Offers & Discounts</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-sm text-muted-foreground">No offers available at the moment.</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="font-headline flex items-center gap-2">
                    <ShoppingCart className="h-5 w-5" /> Your Cart
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {cart.length > 0 ? (
                    cart.map(item => (
                      <div key={item.id} className="flex justify-between items-center text-sm">
                        <div>
                          <p className="font-medium">{item.quantity} x {item.name}</p>
                          <p className="text-muted-foreground">${item.price.toFixed(2)} each</p>
                        </div>
                        <div className="flex items-center gap-2">
                          <p className="font-semibold">${(item.price * item.quantity).toFixed(2)}</p>
                          <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => removeFromCart(item.id)}>
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </div>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-muted-foreground text-center py-4">Your cart is empty.</p>
                  )}

                  {cart.length > 0 && (
                    <>
                      <Separator />
                      <div className="flex justify-between font-semibold">
                        <span>Subtotal</span>
                        <span>${total.toFixed(2)}</span>
                      </div>
                    </>
                  )}
                </CardContent>
                <CardFooter className="flex-col gap-2 pt-4">
                  <div className="grid grid-cols-2 gap-2 w-full">
                    <Button variant="outline">Delivery</Button>
                    <Button variant="outline">Pickup</Button>
                  </div>
                  <Button asChild className="w-full" disabled={cart.length === 0}>
                    <Link href={{
                      pathname: '/checkout',
                      query: {
                        cart: JSON.stringify(cart),
                        restaurantName: restaurant.name,
                        restaurantId: restaurant.id,
                        restaurantImage: restaurant.imageUrl,
                      }
                    }}>
                      Review address and details
                    </Link>
                  </Button>
                </CardFooter>
              </Card>
            </aside>
          </div>
        </TabsContent>

        <TabsContent value="reservation">
          <div className="grid md:grid-cols-2 gap-8 items-start">
            <Card>
              <CardHeader>
                <CardTitle className="font-headline">Make a Reservation</CardTitle>
                <CardDescription>Select a date, time, and party size to book your table.</CardDescription>
              </CardHeader>
              <CardContent className="flex flex-col md:flex-row gap-8 items-start">
                <div className="flex justify-center md:justify-start w-full md:w-auto">
                  <Calendar
                    mode="single"
                    selected={date}
                    onSelect={setDate}
                    className="rounded-md border"
                    disabled={(date) => date < new Date(new Date().setHours(0, 0, 0, 0)) || date > addDays(new Date(), 60)}
                  />
                </div>

                <div className="space-y-6 w-full">
                  <div>
                    <h3 className="text-lg font-medium mb-2">Select Time</h3>
                    <div className="grid grid-cols-2 gap-4">
                      <Select value={hour ?? undefined} onValueChange={setHour}>
                        <SelectTrigger>
                          <SelectValue placeholder="Hour" />
                        </SelectTrigger>
                        <SelectContent>
                          {hours.map(h => <SelectItem key={h} value={String(h)}>{h > 12 ? h - 12 : h} {h >= 12 ? "PM" : "AM"}</SelectItem>)}
                        </SelectContent>
                      </Select>
                      <Select value={minute ?? undefined} onValueChange={setMinute}>
                        <SelectTrigger>
                          <SelectValue placeholder="Minute" />
                        </SelectTrigger>
                        <SelectContent>
                          {minutes.map(m => <SelectItem key={m} value={m}>{m}</SelectItem>)}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  <div>
                    <h3 className="text-lg font-medium mb-2">Party Size</h3>
                    <div className="flex items-center gap-4">
                      <Button variant="outline" size="icon" onClick={() => setPartySize(p => Math.max(1, p - 1))}>-</Button>
                      <span className="font-bold text-lg w-16 text-center">{partySize} people</span>
                      <Button variant="outline" size="icon" onClick={() => setPartySize(p => p + 1)}>+</Button>
                    </div>
                  </div>
                  <Button className="w-full" size="lg" disabled={!date || !hour || !minute}>
                    Reserve Table
                  </Button>
                </div>
              </CardContent>
            </Card>
            <ContactCard />
          </div>
        </TabsContent>

        <TabsContent value="location">
          <div className="grid md:grid-cols-2 gap-8">
            <Card>
              <CardHeader>
                <CardTitle className="font-headline">Location & Hours</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div>
                  <h3 className="text-lg font-medium flex items-center mb-2">
                    <MapPin className="mr-2 h-5 w-5" />
                    Address
                  </h3>
                  <p className="text-muted-foreground">{restaurant.address}</p>
                </div>
                <div>
                  <h3 className="text-lg font-medium flex items-center mb-3">
                    <Clock className="mr-2 h-5 w-5" />
                    Opening Hours
                  </h3>
                  {openingHours.length > 0 ? (
                    <div className="space-y-2">
                      {openingHours.map((hour) => (
                        <div key={hour.id} className="flex justify-between items-center py-2 border-b last:border-0">
                          <span className="font-medium text-sm">{DAYS[hour.dayOfWeek]}</span>
                          {hour.isOpen ? (
                            <span className="text-sm text-muted-foreground">
                              {formatTime(hour.openTime)} - {formatTime(hour.closeTime)}
                            </span>
                          ) : (
                            <span className="text-sm text-destructive font-medium">Closed</span>
                          )}
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-muted-foreground">
                      Opening hours not available
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
            <ContactCard />
          </div>
        </TabsContent>

        <TabsContent value="reviews">
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="font-headline">Customer Reviews</CardTitle>
                    <CardDescription>
                      {reviews.length > 0
                        ? `${reviews.length} ${reviews.length === 1 ? 'review' : 'reviews'} • Average rating: ${averageRating.toFixed(1)}/5`
                        : 'Be the first to review this restaurant'}
                    </CardDescription>
                  </div>
                  <Dialog open={reviewDialogOpen} onOpenChange={setReviewDialogOpen}>
                    <DialogTrigger asChild>
                      <Button>
                        <Star className="h-4 w-4 mr-2" />
                        Write a Review
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="sm:max-w-[500px]">
                      <DialogHeader>
                        <DialogTitle>Write a Review</DialogTitle>
                        <DialogDescription>
                          Share your experience with {restaurant?.name}
                        </DialogDescription>
                      </DialogHeader>
                      <div className="space-y-4 py-4">
                        <div className="space-y-2">
                          <Label>Your Rating</Label>
                          {renderStars(reviewRating, true, setReviewRating)}
                        </div>
                        <div className="space-y-2">
                          <Label>Order Type</Label>
                          <RadioGroup value={reviewOrderType} onValueChange={setReviewOrderType}>
                            <div className="flex items-center space-x-2">
                              <RadioGroupItem value="delivery" id="delivery" />
                              <Label htmlFor="delivery">Delivery</Label>
                            </div>
                            <div className="flex items-center space-x-2">
                              <RadioGroupItem value="dine-in" id="dine-in" />
                              <Label htmlFor="dine-in">Dine-in</Label>
                            </div>
                          </RadioGroup>
                        </div>
                        <div className="space-y-2">
                          <Label htmlFor="comment">Your Review (Optional)</Label>
                          <Textarea
                            id="comment"
                            placeholder="Tell us about your experience..."
                            value={reviewComment}
                            onChange={(e) => setReviewComment(e.target.value)}
                            rows={4}
                          />
                        </div>
                      </div>
                      <DialogFooter>
                        <Button variant="outline" onClick={() => setReviewDialogOpen(false)}>
                          Cancel
                        </Button>
                        <Button onClick={handleSubmitReview} disabled={submittingReview}>
                          {submittingReview ? 'Submitting...' : 'Submit Review'}
                        </Button>
                      </DialogFooter>
                    </DialogContent>
                  </Dialog>
                </div>
              </CardHeader>
              <CardContent>
                {reviews.length === 0 ? (
                  <div className="text-center py-12">
                    <MessageSquare className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                    <p className="text-lg font-medium">No reviews yet</p>
                    <p className="text-sm text-muted-foreground mt-2">
                      Be the first to share your experience!
                    </p>
                  </div>
                ) : (
                  <div className="space-y-6">
                    <div className="flex items-center gap-6 p-6 bg-muted/50 rounded-lg">
                      <div className="text-center">
                        <div className="text-5xl font-bold">{averageRating.toFixed(1)}</div>
                        <div className="mt-2">{renderStars(Math.round(averageRating))}</div>
                        <p className="text-sm text-muted-foreground mt-1">
                          {reviews.length} {reviews.length === 1 ? 'review' : 'reviews'}
                        </p>
                      </div>
                      <Separator orientation="vertical" className="h-24" />
                      <div className="flex-grow space-y-2">
                        {[5, 4, 3, 2, 1].map((rating) => {
                          const count = reviews.filter(r => r.rating === rating).length;
                          const percentage = (count / reviews.length) * 100;
                          return (
                            <div key={rating} className="flex items-center gap-3">
                              <span className="text-sm w-8">{rating}★</span>
                              <div className="flex-grow h-2 bg-secondary rounded-full overflow-hidden">
                                <div
                                  className="h-full bg-amber-400 transition-all"
                                  style={{ width: `${percentage}%` }}
                                />
                              </div>
                              <span className="text-sm text-muted-foreground w-12 text-right">
                                {count}
                              </span>
                            </div>
                          );
                        })}
                      </div>
                    </div>

                    <Separator />

                    <div className="space-y-6">
                      {reviews.map((review) => (
                        <div key={review.id} className="flex gap-4">
                          <Avatar className="h-10 w-10">
                            <AvatarFallback>{getInitials(review.userName)}</AvatarFallback>
                          </Avatar>
                          <div className="flex-grow space-y-2">
                            <div className="flex items-start justify-between">
                              <div>
                                <p className="font-medium">{review.userName}</p>
                                <div className="flex items-center gap-2 mt-1">
                                  {renderStars(review.rating)}
                                  <span className="text-xs text-muted-foreground">•</span>
                                  <span className="text-xs text-muted-foreground capitalize">
                                    {review.orderType}
                                  </span>
                                </div>
                              </div>
                              <span className="text-sm text-muted-foreground">
                                {format(new Date(review.createdAt), 'MMM d, yyyy')}
                              </span>
                            </div>
                            {review.comment && (
                              <p className="text-sm text-muted-foreground">{review.comment}</p>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>

      <FloatingChatbot
        restaurantId={id}
        restaurantName={restaurant?.name}
        context={{
          menuItems: menuItems.filter(item => item.isAvailable).map(item => ({
            name: item.name,
            price: item.price,
            category: item.category
          })),
          openingHours: openingHours,
        }}
      />
    </div>
  );
}