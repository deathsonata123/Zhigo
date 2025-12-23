// src/app/dashboard/reviews/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card';
import { Avatar, AvatarFallback } from '../../components/ui/avatar';
import { Badge } from '../../components/ui/badge';
import { Separator } from '../../components/ui/separator';
import { Star, TrendingUp, MessageSquare, Calendar, Loader2 } from 'lucide-react';
import { getCurrentUser } from '../../lib/auth';
import { format } from 'date-fns';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';


type Review = {
  id: string;
  userName: string;
  rating: number;
  comment: string;
  orderType: string;
  createdAt: string;
};

type RatingStats = {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: { [key: number]: number };
};

export default function ReviewsPage() {
  const [loading, setLoading] = useState(true);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [filteredReviews, setFilteredReviews] = useState<Review[]>([]);
  const [stats, setStats] = useState<RatingStats>({
    averageRating: 0,
    totalReviews: 0,
    ratingDistribution: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 },
  });
  const [selectedFilter, setSelectedFilter] = useState<string>('all');

  useEffect(() => {
    fetchReviews();
  }, []);

  useEffect(() => {
    filterReviews();
  }, [selectedFilter, reviews]);

  const fetchReviews = async () => {
    try {
      setLoading(true);
      const user = await getCurrentUser();

      // Get restaurant owned by current user
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';

      const restaurantsRes = await fetch(`${apiUrl}/api/restaurants?ownerId=${user.userId}`);
      if (!restaurantsRes.ok) throw new Error('Failed to fetch restaurants');
      const restaurants = await restaurantsRes.json();

      if (restaurants && restaurants.length > 0) {
        const restaurantId = restaurants[0].id;

        // Fetch all reviews for this restaurant
        const reviewsRes = await fetch(`${apiUrl}/api/reviews?restaurantId=${restaurantId}`);
        if (!reviewsRes.ok) throw new Error('Failed to fetch reviews');
        const reviewData = await reviewsRes.json();

        if (reviewData && reviewData.length > 0) {
          const mappedReviews = reviewData.map((r: any) => ({
            id: r.id,
            userName: r.userName || 'Anonymous',
            rating: r.rating || 0,
            comment: r.comment || '',
            orderType: r.orderType || 'delivery',
            createdAt: r.createdAt || new Date().toISOString(),
          }));

          // Sort by most recent first
          mappedReviews.sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

          setReviews(mappedReviews);
          calculateStats(mappedReviews);
        }
      }
    } catch (error) {
      console.error('Error fetching reviews:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateStats = (reviewList: Review[]) => {
    if (reviewList.length === 0) {
      setStats({
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 },
      });
      return;
    }

    const totalRating = reviewList.reduce((sum, review) => sum + review.rating, 0);
    const averageRating = totalRating / reviewList.length;

    const distribution = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
    reviewList.forEach((review) => {
      distribution[review.rating as keyof typeof distribution]++;
    });

    setStats({
      averageRating: Math.round(averageRating * 10) / 10,
      totalReviews: reviewList.length,
      ratingDistribution: distribution,
    });
  };

  const filterReviews = () => {
    if (selectedFilter === 'all') {
      setFilteredReviews(reviews);
    } else {
      const rating = parseInt(selectedFilter);
      setFilteredReviews(reviews.filter((r) => r.rating === rating));
    }
  };

  const renderStars = (rating: number, size: 'sm' | 'lg' = 'sm') => {
    const sizeClass = size === 'lg' ? 'h-6 w-6' : 'h-4 w-4';
    return (
      <div className="flex items-center gap-1">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            className={`${sizeClass} ${i < rating ? 'fill-amber-400 text-amber-400' : 'text-gray-300'
              }`}
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

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-4xl font-bold font-headline">Ratings and Reviews</h1>
        <p className="text-muted-foreground mt-2 text-lg">
          See what customers are saying about your restaurant
        </p>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Average Rating
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-3">
              <div className="text-4xl font-bold">{stats.averageRating.toFixed(1)}</div>
              {renderStars(Math.round(stats.averageRating), 'lg')}
            </div>
            <p className="text-sm text-muted-foreground mt-2">
              Based on {stats.totalReviews} {stats.totalReviews === 1 ? 'review' : 'reviews'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total Reviews
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-3">
              <MessageSquare className="h-8 w-8 text-primary" />
              <div className="text-4xl font-bold">{stats.totalReviews}</div>
            </div>
            <p className="text-sm text-muted-foreground mt-2">Customer feedback received</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              5-Star Reviews
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-3">
              <TrendingUp className="h-8 w-8 text-amber-500" />
              <div className="text-4xl font-bold">{stats.ratingDistribution[5]}</div>
            </div>
            <p className="text-sm text-muted-foreground mt-2">
              {stats.totalReviews > 0
                ? `${Math.round((stats.ratingDistribution[5] / stats.totalReviews) * 100)}% of total`
                : 'No reviews yet'}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Rating Distribution */}
      <Card>
        <CardHeader>
          <CardTitle>Rating Distribution</CardTitle>
          <CardDescription>Breakdown of ratings by star level</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {[5, 4, 3, 2, 1].map((rating) => {
            const count = stats.ratingDistribution[rating as keyof typeof stats.ratingDistribution];
            const percentage = stats.totalReviews > 0 ? (count / stats.totalReviews) * 100 : 0;

            return (
              <div key={rating} className="flex items-center gap-4">
                <div className="flex items-center gap-1 w-20">
                  <span className="text-sm font-medium">{rating}</span>
                  <Star className="h-4 w-4 fill-amber-400 text-amber-400" />
                </div>
                <div className="flex-grow">
                  <div className="h-2 bg-secondary rounded-full overflow-hidden">
                    <div
                      className="h-full bg-amber-400 transition-all"
                      style={{ width: `${percentage}%` }}
                    />
                  </div>
                </div>
                <div className="text-sm text-muted-foreground w-16 text-right">
                  {count} ({Math.round(percentage)}%)
                </div>
              </div>
            );
          })}
        </CardContent>
      </Card>

      {/* Reviews List */}
      <Card>
        <CardHeader>
          <CardTitle>Customer Reviews</CardTitle>
          <CardDescription>Read what your customers have to say</CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs value={selectedFilter} onValueChange={setSelectedFilter}>
            <TabsList className="mb-6">
              <TabsTrigger value="all">All ({reviews.length})</TabsTrigger>
              <TabsTrigger value="5">5 Stars ({stats.ratingDistribution[5]})</TabsTrigger>
              <TabsTrigger value="4">4 Stars ({stats.ratingDistribution[4]})</TabsTrigger>
              <TabsTrigger value="3">3 Stars ({stats.ratingDistribution[3]})</TabsTrigger>
              <TabsTrigger value="2">2 Stars ({stats.ratingDistribution[2]})</TabsTrigger>
              <TabsTrigger value="1">1 Star ({stats.ratingDistribution[1]})</TabsTrigger>
            </TabsList>

            <TabsContent value={selectedFilter} className="space-y-4">
              {filteredReviews.length === 0 ? (
                <div className="text-center py-12">
                  <MessageSquare className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                  <p className="text-lg font-medium">No reviews yet</p>
                  <p className="text-sm text-muted-foreground mt-2">
                    {selectedFilter === 'all'
                      ? 'Your customers will be able to leave reviews after their orders.'
                      : `No ${selectedFilter}-star reviews found.`}
                  </p>
                </div>
              ) : (
                filteredReviews.map((review, index) => (
                  <div key={review.id}>
                    <div className="flex gap-4 py-4">
                      <Avatar className="h-10 w-10">
                        <AvatarFallback>{getInitials(review.userName)}</AvatarFallback>
                      </Avatar>
                      <div className="flex-grow space-y-2">
                        <div className="flex items-start justify-between">
                          <div>
                            <p className="font-medium">{review.userName}</p>
                            <div className="flex items-center gap-2 mt-1">
                              {renderStars(review.rating)}
                              <Badge variant="outline" className="capitalize">
                                {review.orderType}
                              </Badge>
                            </div>
                          </div>
                          <div className="flex items-center gap-1 text-sm text-muted-foreground">
                            <Calendar className="h-4 w-4" />
                            {format(new Date(review.createdAt), 'MMM d, yyyy')}
                          </div>
                        </div>
                        {review.comment && (
                          <p className="text-sm text-muted-foreground mt-2">{review.comment}</p>
                        )}
                      </div>
                    </div>
                    {index < filteredReviews.length - 1 && <Separator />}
                  </div>
                ))
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}
