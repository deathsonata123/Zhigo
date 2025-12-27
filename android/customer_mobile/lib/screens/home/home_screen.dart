import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/minimalist_restaurant_card.dart';
import '../../widgets/hero_carousel.dart';
import '../../widgets/partner_banner.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../restaurant/restaurant_details_screen.dart';
import '../search/search_modal.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../profile/user_profile_screen.dart';

// Foodpanda-inspired color scheme
class FoodpandaColors {
  static const Color coral = Color(0xFFE8734A); // Orange-coral for buttons
  static const Color coralLight = Color(0xFFFFF5F2); // Light coral for backgrounds
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'Food';

  // Recently ordered items (mock data for now)
  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': '1',
      'name': 'Margherita Pizza',
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
      'lastOrdered': '2 days ago',
    },
    {
      'id': '2',
      'name': 'Caesar Salad',
      'imageUrl': 'https://images.unsplash.com/photo-1546793665-c74683f339c1',
      'lastOrdered': '5 days ago',
    },
    {
      'id': '3',
      'name': 'Groceries',
      'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      'lastOrdered': '1 week ago',
    },
  ];

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
    
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchModal(),
            fullscreenDialog: true,
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AIChatScreen(),
          ),
        );
        break;
      case 3:
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Consumer<RestaurantProvider>(
            builder: (context, restaurantProvider, _) {
              if (restaurantProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: FoodpandaColors.coral),
                );
              }
              
              if (restaurantProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${restaurantProvider.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => restaurantProvider.fetchRestaurants(),
                        style: ElevatedButton.styleFrom(backgroundColor: FoodpandaColors.coral),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              
              final restaurants = restaurantProvider.restaurants;

              return RefreshIndicator(
                onRefresh: () => restaurantProvider.fetchRestaurants(),
                color: FoodpandaColors.coral,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Safe area padding
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      
                      // Partner Banner at top
                      const PartnerBanner(),
                      
                      const SizedBox(height: 16),
                      
                      // Hero Carousel
                      if (restaurants.isNotEmpty)
                        HeroCarousel(
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
                      
                      const SizedBox(height: 20),
                      
                      // Categories (below carousel)
                      _buildCategories(),
                      
                      const SizedBox(height: 24),
                      
                      // Recently Ordered
                      _buildRecentlyOrdered(),
                      
                      const SizedBox(height: 24),
                      
                      // All Restaurants Section
                      if (restaurants.isNotEmpty) ...[
                        _buildSectionTitle('All Restaurants'),
                        const SizedBox(height: 16),
                        _buildRestaurantsList(restaurants),
                      ],
                      
                      // Bottom padding for floating nav
                      const SizedBox(height: 120),
                    ],
                  ),
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

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Hello, Zhigo!',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: FoodpandaColors.grey900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SearchModal(),
              fullscreenDialog: true,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: FoodpandaColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: FoodpandaColors.grey600, size: 22),
              const SizedBox(width: 12),
              Text(
                'Search for restaurants or items...',
                style: TextStyle(
                  color: FoodpandaColors.grey600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Food', 'Grocery', 'Medicine'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CategoryPill(
                  label: category,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyOrdered() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently Ordered',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 16),
          ..._recentOrders.map((order) => _RecentOrderCard(order: order)).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: FoodpandaColors.grey900,
        ),
      ),
    );
  }

  Widget _buildRestaurantsList(List<Map<String, dynamic>> restaurants) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: restaurants.map((restaurant) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _RestaurantListCard(
              restaurant: restaurant,
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
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Category Pill Widget
class _CategoryPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected ? FoodpandaColors.coral : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.isSelected 
                  ? FoodpandaColors.coral 
                  : (_isHovered ? FoodpandaColors.coral : FoodpandaColors.grey200),
              width: 1.5,
            ),
            boxShadow: widget.isSelected || _isHovered ? [
              BoxShadow(
                color: FoodpandaColors.coral.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : FoodpandaColors.grey900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// Recent Order Card Widget
class _RecentOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;

  const _RecentOrderCard({required this.order});

  @override
  State<_RecentOrderCard> createState() => _RecentOrderCardState();
}

class _RecentOrderCardState extends State<_RecentOrderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FoodpandaColors.grey200),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // Food Image with colored background
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: FoodpandaColors.coralLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.order['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.fastfood,
                    color: FoodpandaColors.coral,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FoodpandaColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last ordered: ${widget.order['lastOrdered']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: FoodpandaColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            // Re-order Button
            _ReorderButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// Re-order Button Widget
class _ReorderButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ReorderButton({required this.onTap});

  @override
  State<_ReorderButton> createState() => _ReorderButtonState();
}

class _ReorderButtonState extends State<_ReorderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? FoodpandaColors.coral : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FoodpandaColors.coral, width: 1.5),
          ),
          child: Text(
            'Re-order',
            style: TextStyle(
              color: _isHovered ? Colors.white : FoodpandaColors.coral,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// Restaurant List Card Widget
class _RestaurantListCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;

  const _RestaurantListCard({
    required this.restaurant,
    required this.onTap,
  });

  @override
  State<_RestaurantListCard> createState() => _RestaurantListCardState();
}

class _RestaurantListCardState extends State<_RestaurantListCard> {
  bool _isHovered = false;

  String? get _imageUrl {
    return widget.restaurant['imageUrl'] ?? 
           widget.restaurant['photo_url'] ?? 
           widget.restaurant['image_url'];
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FoodpandaColors.grey200),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
          transformAlignment: Alignment.center,
          child: Row(
            children: [
              // Restaurant Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FoodpandaColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imageUrl != null && _imageUrl!.startsWith('http')
                      ? Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(width: 16),
              // Restaurant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant['name'] ?? 'Restaurant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FoodpandaColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.restaurant['business_type'] ?? 'Restaurant',
                      style: TextStyle(
                        fontSize: 13,
                        color: FoodpandaColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.restaurant['rating'] ?? 4.5}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FoodpandaColors.grey900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: FoodpandaColors.grey600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.restaurant['city'] ?? 'Nearby',
                          style: TextStyle(
                            fontSize: 13,
                            color: FoodpandaColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isHovered ? 1.0 : 0.5,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: FoodpandaColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: FoodpandaColors.grey100,
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: FoodpandaColors.grey600,
          size: 32,
        ),
      ),
    );
  }
}
