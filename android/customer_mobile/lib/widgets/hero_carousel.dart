import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HeroCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants;
  final Function(String) onRestaurantTap;

  const HeroCarousel({
    super.key,
    required this.restaurants,
    required this.onRestaurantTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show top 5 restaurants in carousel
    final heroRestaurants = restaurants.take(5).toList();

    if (heroRestaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 405,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        pauseAutoPlayOnTouch: true,
        enlargeCenterPage: false,
      ),
      items: heroRestaurants.map((restaurant) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => onRestaurantTap(restaurant['id'] ?? ''),
              child: Stack(
                children: [
                  // Restaurant Image
                  CachedNetworkImage(
                    imageUrl: restaurant['imageUrl'] ?? '',
                    width: double.infinity,
                    height: 405,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 50),
                    ),
                  ),
                  
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Restaurant Info
                  Positioned(
                    bottom: 48,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurant['address'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
