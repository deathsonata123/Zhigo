'use client';

import { Card } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import { Search } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { useState, useEffect, useMemo } from 'react';
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from '../../components/ui/carousel';
import Autoplay from "embla-carousel-autoplay";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Skeleton } from '../../components/ui/skeleton';
import { cn } from '../../lib/utils';
import { DataClient } from '@food-delivery/shared-utils';

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

const featuredDishes = [
  { name: 'Gourmet Pizza', description: 'Freshly baked with premium ingredients', imageUrl: 'https://picsum.photos/seed/dish1/800/600' },
  { name: 'Spicy Tacos', description: 'A fiesta of flavors in every bite', imageUrl: 'https://picsum.photos/seed/dish2/800/600' },
  { name: 'Fresh Sushi Rolls', description: 'Authentic Japanese delight', imageUrl: 'https://picsum.photos/seed/dish3/800/600' },
  { name: 'Juicy Burgers', description: 'Classic American comfort food', imageUrl: 'https://picsum.photos/seed/dish4/800/600' },
  { name: 'Creamy Pasta', description: 'An Italian masterpiece', imageUrl: 'https://picsum.photos/seed/dish5/800/600' },
];

export function RestaurantListing() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPrice, setSelectedPrice] = useState<string>('all');
  const [minRating, setMinRating] = useState(0);

  useEffect(() => {
    fetchRestaurants();
  }, []);

  const fetchRestaurants = async () => {
    try {
      setLoading(true);

      // Use new DataClient instead of Amplify
      const restaurantData = await DataClient.restaurants.list();

      if (restaurantData) {
        const restaurantsWithImages = restaurantData.map((restaurant: any) => {
          let imageUrl = 'https://picsum.photos/seed/default/600/400';

          if (restaurant.photo_url) {
            // Use photo_url directly if it's a full URL
            if (restaurant.photo_url.startsWith('http')) {
              imageUrl = restaurant.photo_url;
            }
          }

          return {
            id: restaurant.id,
            name: restaurant.name || '',
            address: restaurant.address || '',
            imageUrl: imageUrl,
            email: restaurant.email || '',
            phone: restaurant.phone || '',
            ownerId: restaurant.owner_id || '',
            status: restaurant.status || '',
          };
        });

        const approvedRestaurants = restaurantsWithImages.filter(
          (restaurant: any) => restaurant.status === 'approved'
        );

        setRestaurants(approvedRestaurants);
      }
    } catch (error) {
      console.error('❌ Error fetching restaurants:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredRestaurants = restaurants.filter(restaurant => {
    const matchesSearch = restaurant.name.toLowerCase().includes(searchQuery.toLowerCase());

    const averagePrice = 15;
    const matchesPrice = selectedPrice === 'all' ||
      (selectedPrice === '$' && averagePrice < 10) ||
      (selectedPrice === '$$' && averagePrice >= 10 && averagePrice < 20) ||
      (selectedPrice === '$$$' && averagePrice >= 20);

    const rating = 4.5;
    const matchesRating = rating >= minRating;

    return matchesSearch && matchesPrice && matchesRating;
  });

  const bentoClasses = useMemo(() => [
    "sm:col-span-2 sm:row-span-2",
    "sm:col-span-1 sm:row-span-1",
    "sm:col-span-1 sm:row-span-1",
    "sm:col-span-1 sm:row-span-1",
    "sm:col-span-1 sm:row-span-1",
    "sm:col-span-2 sm:row-span-1",
    "sm:col-span-1 sm:row-span-1",
    "sm:col-span-1 sm:row-span-2",
    "sm:col-span-2 sm:row-span-1",
  ], []);

  const randomBentoClass = () => {
    const options = [
      "sm:col-span-1 sm:row-span-1",
      "sm:col-span-1 sm:row-span-1",
      "sm:col-span-1 sm:row-span-1",
      "sm:col-span-2 sm:row-span-1",
    ];
    return options[Math.floor(Math.random() * options.length)];
  };

  return (
    <div className="relative pb-24">
      <div className="relative">
        <Carousel
          opts={{ loop: true }}
          plugins={[Autoplay({ delay: 5000 })]}
          className="w-full -mt-px"
        >
          <CarouselContent>
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <CarouselItem key={i}>
                  <div className="relative h-56 md:h-[405px] w-full overflow-hidden">
                    <Skeleton className="h-full w-full" />
                    <div className="absolute bottom-0 left-0 p-6 md:p-12">
                      <Skeleton className="h-12 w-3/4 mb-2" />
                      <Skeleton className="h-8 w-1/2" />
                    </div>
                  </div>
                </CarouselItem>
              ))
            ) : (
              filteredRestaurants.slice(0, 5).map((restaurant) => (
                <CarouselItem key={restaurant.id}>
                  <Link href={`/restaurant?id=${restaurant.id}`}>
                    <div className="relative h-56 md:h-[405px] w-full overflow-hidden">
                      <Image
                        src={restaurant.imageUrl}
                        alt={restaurant.name}
                        fill
                        className="object-cover"
                        unoptimized
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                      <div className="absolute bottom-0 left-0 p-6 md:p-12 text-white">
                        <h2 className="text-3xl md:text-5xl font-bold font-headline">{restaurant.name}</h2>
                        <p className="text-lg md:text-xl">{restaurant.address}</p>
                      </div>
                    </div>
                  </Link>
                </CarouselItem>
              ))
            )}
          </CarouselContent>
          <CarouselPrevious className="left-4" />
          <CarouselNext className="right-4" />
        </Carousel>

        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 translate-y-1/2 w-full max-w-4xl px-4 z-10">
          <Card className="p-4 shadow-lg">
            <div className="flex flex-col md:flex-row gap-3">
              <div className="relative flex-grow">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                <Input
                  placeholder="Search restaurants..."
                  className="pl-10 h-12 text-base"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <Select onValueChange={setSelectedPrice} value={selectedPrice}>
                  <SelectTrigger className="h-12 w-full text-base">
                    <SelectValue placeholder="Price" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Any Price</SelectItem>
                    <SelectItem value="$">$ (Under $10)</SelectItem>
                    <SelectItem value="$$">$$ ($10 - $20)</SelectItem>
                    <SelectItem value="$$$">$$$ (Over $20)</SelectItem>
                  </SelectContent>
                </Select>
                <Select onValueChange={(value) => setMinRating(Number(value))} value={String(minRating)}>
                  <SelectTrigger className="h-12 w-full text-base">
                    <SelectValue placeholder="Rating" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">Any Rating</SelectItem>
                    <SelectItem value="4.5">4.5+ Stars</SelectItem>
                    <SelectItem value="4">4.0+ Stars</SelectItem>
                    <SelectItem value="3.5">3.5+ Stars</SelectItem>
                    <SelectItem value="3">3.0+ Stars</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </Card>
        </div>
      </div>

      <div className="container mx-auto py-12 px-4">
        <div className="mb-12 pt-12">
          <h2 className="text-2xl font-bold font-headline text-center mb-2">What are you craving?</h2>
          <p className="text-muted-foreground text-center mb-6">Explore dishes from our top-rated restaurants.</p>
          <Carousel
            opts={{ align: "start", loop: true }}
            plugins={[Autoplay({ delay: 3000, stopOnInteraction: false })]}
            className="w-full"
          >
            <CarouselContent className="-ml-4">
              {featuredDishes.map((dish, index) => (
                <CarouselItem key={index} className="basis-full sm:basis-1/2 md:basis-1/3 lg:basis-1/4 pl-4">
                  <div className="group relative overflow-hidden rounded-lg">
                    <Image
                      src={dish.imageUrl}
                      alt={dish.name}
                      width={400}
                      height={300}
                      className="object-cover w-full h-64 transition-transform duration-300 group-hover:scale-105"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                    <div className="absolute bottom-0 left-0 p-4 text-white">
                      <h3 className="font-bold text-lg font-headline drop-shadow-md">{dish.name}</h3>
                      <p className="text-sm text-white/90 drop-shadow-sm">{dish.description}</p>
                    </div>
                  </div>
                </CarouselItem>
              ))}
            </CarouselContent>
            <CarouselPrevious className="left-4 hidden sm:flex" />
            <CarouselNext className="right-4 hidden sm:flex" />
          </Carousel>
        </div>
      </div>

      <div className="container mx-auto pb-12 px-4">
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[250px]">
            {Array.from({ length: 8 }).map((_, i) => (
              <Card key={i} className={cn(
                "overflow-hidden rounded-lg",
                i === 0 && "sm:col-span-2 sm:row-span-2",
                i === 3 && "sm:col-span-2",
              )}>
                <Skeleton className="h-full w-full" />
              </Card>
            ))}
          </div>
        ) : filteredRestaurants.length === 0 ? (
          <div className="text-center py-12">
            <h3 className="text-2xl font-bold mb-2">No restaurants found</h3>
            <p className="text-muted-foreground">Try adjusting your search or filters</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[250px]">
            {filteredRestaurants.map((restaurant, index) => (
              <Link
                href={`/restaurant?id=${restaurant.id}`}
                key={restaurant.id}
                className={cn(
                  "group relative block",
                  index < bentoClasses.length ? bentoClasses[index] : randomBentoClass(),
                  "hover:-translate-y-1 transition-transform duration-300"
                )}
              >
                <Card className="overflow-hidden shadow-md hover:shadow-xl transition-shadow duration-300 h-full flex flex-col rounded-lg">
                  <div className="flex-grow relative">
                    <Image
                      src={restaurant.imageUrl}
                      alt={restaurant.name}
                      fill
                      className="object-cover group-hover:scale-105 transition-transform duration-300"
                      unoptimized
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/30 to-transparent" />
                  </div>
                  <div className="p-4 absolute bottom-0 left-0 right-0 text-white z-10">
                    <h3 className="text-lg font-bold font-headline mb-1 drop-shadow-md">{restaurant.name}</h3>
                    <p className="text-sm text-white/90 drop-shadow-sm line-clamp-1">{restaurant.address}</p>
                    <div className="flex items-center mt-2">
                      <div className="flex items-center gap-1 text-sm text-amber-400">
                        {'★'.repeat(4)}{'☆'}
                      </div>
                      <span className="ml-2 text-sm text-white/90">4.5</span>
                    </div>
                  </div>
                </Card>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}