import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/review.dart';
import '../../services/restaurant_service.dart';
import '../../utils/date_formatter.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  int? _filterRating;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<RestaurantProvider>();
    if (provider.restaurant == null) {
      await provider.loadRestaurant();
    }
    
    if (provider.restaurant != null) {
      try {
        _reviews = await _restaurantService.getReviews(provider.restaurant!.id);
      } catch (e) {
        // Handle error
      }
    }
    
    setState(() => _isLoading = false);
  }

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<double>(0, (sum, r) => sum + r.rating) / _reviews.length;
  }

  Map<int, int> get ratingDistribution {
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in _reviews) {
      dist[review.rating] = (dist[review.rating] ?? 0) + 1;
    }
    return dist;
  }

  List<Review> get filteredReviews {
    if (_filterRating == null) return _reviews;
    return _reviews.where((r) => r.rating == _filterRating).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReviews,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Rating summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Icon(
                                index < averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_reviews.length} reviews',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          // Rating distribution bars
                          ...List.generate(5, (index) {
                            final rating = 5 - index;
                            final count = ratingDistribution[rating] ?? 0;
                            final percentage = _reviews.isEmpty
                                ? 0.0
                                : count / _reviews.length;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text('$rating'),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: Colors.grey[200],
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$count'),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterRating == null,
                          onSelected: (selected) {
                            setState(() => _filterRating = null);
                          },
                        ),
                        ...List.generate(5, (index) {
                          final rating = 5 - index;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('$rating'),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star, size: 16),
                                ],
                              ),
                              selected: _filterRating == rating,
                              onSelected: (selected) {
                                setState(() => _filterRating = selected ? rating : null);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reviews list
                  if (filteredReviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...filteredReviews.map((review) => _ReviewCard(review: review)),
                ],
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(review.userName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormatter.formatRelativeTime(review.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment),
            ],
          ],
        ),
      ),
    );
  }
}
