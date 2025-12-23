import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/minimalist_restaurant_card.dart';
import '../../widgets/hero_carousel.dart';
import '../../widgets/featured_dishes_carousel.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/partner_banner.dart';
import '../../data/dummy_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../restaurant/restaurant_details_screen.dart';
import '../search/search_modal.dart';
import '../map/simple_map_screen.dart';
import '../map/simple_map_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../auth/login_screen.dart';
import '../profile/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    
    // Handle navigation
    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // Search
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchModal(),
            fullscreenDialog: true,
          ),
        );
        break;
      case 2: // AI Chat
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AIChatScreen(),
          ),
        );
        break;
      case 3: // Profile (only when authenticated)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserProfileScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive columns: 2 for mobile, 4 for tablet, 5+ for desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 1200 ? 4 : 5);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Content
          Consumer<RestaurantProvider>(
            builder: (context, restaurantProvider, _) {
              // Use dummy data if API hasn't loaded yet or failed
              final restaurants = restaurantProvider.restaurants.isEmpty
                  ? DummyData.dummyRestaurants
                  : restaurantProvider.restaurants;

              return RefreshIndicator(
                onRefresh: () => restaurantProvider.fetchRestaurants(),
                color: AppColors.accent,
                child: CustomScrollView(
                  slivers: [
                    // Top Padding (safe area)
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.top),
                    ),

                    // Partner Banner
                    const SliverToBoxAdapter(
                      child: PartnerBanner(),
                    ),

                    // Hero Carousel (removed gap)
                    SliverToBoxAdapter(
                      child: HeroCarousel(
                        restaurants: restaurants,
                        onRestaurantTap: (restaurantId) {
                          final restaurant = restaurants.firstWhere(
                            (r) => r['id'].toString() == restaurantId,
                            orElse: () => restaurants.first,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailsFullScreen(
                                restaurantId: restaurantId,
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                    // Featured Dishes Carousel
                    const SliverToBoxAdapter(
                      child: FeaturedDishesCarousel(),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                    // Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenMarginHorizontal,
                        ),
                        child: Text(
                          'All Restaurants',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                    // Restaurant Grid - TRUE BENTO RANDOMNESS
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenMarginHorizontal,
                      ),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childCount: restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];
                          
                          // RANDOM SIZES - Like Apple's bento grids
                          // Pattern: 1x1 (square), 2x1 (wide), 1x2 (tall), etc.
                          final sizePatterns = [
                            0.75,  // Portrait (3:4)
                            1.0,   // Square (1:1)
                            1.33,  // Landscape (4:3)
                            0.6,   // Tall portrait (3:5)
                            1.5,   // Wide landscape (3:2)
                          ];
                          
                          // Assign aspect ratio based on index pattern for variety
                          final aspectRatio = sizePatterns[index % sizePatterns.length];
                          
                          return MinimalistRestaurantCard(
                            restaurant: restaurant,
                            aspectRatio: aspectRatio,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RestaurantDetailsFullScreen(
                                    restaurantId: restaurant['id'].toString(),
                                    restaurant: restaurant,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Footer (no extra padding)
                    const SliverToBoxAdapter(
                      child: AppFooter(),
                    ),
                  ],
                ),
              );
            },
          ),

          // Floating Bottom Navigation
          FloatingBottomNav(
            currentIndex: _currentNavIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}
