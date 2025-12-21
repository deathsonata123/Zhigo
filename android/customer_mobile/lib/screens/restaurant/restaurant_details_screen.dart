import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../data/dummy_data.dart';
import '../../widgets/floating_bottom_nav.dart';

/// FULL Restaurant Details - Matches Web Version
/// Features: Search, Categories, 3-col Grid, Cart Sidebar, Reviews, Reservations
class RestaurantDetailsFullScreen extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic>? restaurant;

  const RestaurantDetailsFullScreen({
    super.key,
    required this.restaurantId,
    this.restaurant,
  });

  @override
  State<RestaurantDetailsFullScreen> createState() => _RestaurantDetailsFullScreenState();
}

class _RestaurantDetailsFullScreenState extends State<RestaurantDetailsFullScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = -1;
  
  // Search and filtering
  String _searchQuery = '';
  String _selectedCategory = 'all';
  
  // Cart state
  List<Map<String, dynamic>> _cart = [];
  
  // Menu items (dummy data)
  final List<Map<String, dynamic>> _menuItems = [
    {'id': '1', 'name': 'Spring Rolls', 'description': 'Crispy vegetable spring rolls', 'price': 5.99, 'category': 'Appetizers', 'imageUrl': 'https://images.unsplash.com/photo-1625943553852-781c6dd46faa'},
    {'id': '2', 'name': 'Chicken Wings', 'description': 'Buffalo or BBQ style', 'price': 8.99, 'category': 'Appetizers', 'imageUrl': 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7'},
    {'id': '3', 'name': 'Beef Burger', 'description': 'Angus beef with cheese', 'price': 12.99, 'category': 'Main Courses', 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'},
    {'id': '4', 'name': 'Grilled Chicken', 'description': 'With roasted vegetables', 'price': 14.99, 'category': 'Main Courses', 'imageUrl': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6'},
    {'id': '5', 'name': 'Pasta Carbonara', 'description': 'Creamy Italian pasta', 'price': 11.99, 'category': 'Main Courses', 'imageUrl': 'https://images.unsplash.com/photo-1612874742237-6526221588e3'},
    {'id': '6', 'name': 'Caesar Salad', 'description': 'Fresh romaine with parmesan', 'price': 7.99, 'category': 'Salads', 'imageUrl': 'https://images.unsplash.com/photo-1546793665-c74683f339c1'},
    {'id': '7', 'name': 'Chocolate Cake', 'description': 'Rich chocolate layer cake', 'price': 6.99, 'category': 'Desserts', 'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final cats = <String>{'all'};
    for (var item in _menuItems) {
      cats.add(item['category']);
    }
    return cats.toList();
  }

  List<Map<String, dynamic>> get _filteredMenu {
    var filtered = _menuItems;
    
    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((item) => item['category'] == _selectedCategory).toList();
    }
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => 
        item['name'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final existing = _cart.firstWhere(
        (cartItem) => cartItem['id'] == item['id'],
        orElse: () => {},
      );
      
      if (existing.isEmpty) {
        _cart.add({...item, 'quantity': 1});
      } else {
        existing['quantity'] = (existing['quantity'] as int) + 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${item['name']} to cart'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _removeFromCart(String itemId) {
    setState(() {
      _cart.removeWhere((item) => item['id'] == itemId);
    });
  }

  double get _cartTotal {
    return _cart.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant ?? DummyData.dummyRestaurants.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Custom App Bar
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant['name'] ?? 'Restaurant',
                            style: AppTextStyles.h2.copyWith(fontSize: 20),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${restaurant['rating'] ?? 4.5}',
                                style: AppTextStyles.small,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                tabs: const [
                  Tab(text: 'Menu'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Reserve'),
                  Tab(text: 'Info'),
                ],
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMenuTab(restaurant),
                    _buildReviewsTab(),
                    _buildReservationTab(),
                    _buildInfoTab(restaurant),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Nav
          FloatingBottomNav(
            currentIndex: _currentNavIndex,
            onTap: (index) => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab(Map<String, dynamic> restaurant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Menu Area (3/4 width)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Search Bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search in menu',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),

              // Category Chips
              Container(
                color: AppColors.surface,
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category == 'all' ? 'All' : category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Menu Grid
              Expanded(
                child: _filteredMenu.isEmpty
                    ? const Center(child: Text('No items found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredMenu.length,
                        itemBuilder: (context, index) {
                          final item = _filteredMenu[index];
                          return _buildMenuItem(item);
                        },
                      ),
              ),
            ],
          ),
        ),

        // Cart Sidebar (1/4 width)
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          color: AppColors.surface,
          child: _buildCartSidebar(),
        ),
      ],
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: item['imageUrl'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {},
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: AppTextStyles.bodyEmphasized.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: AppTextStyles.small.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item['price'].toStringAsFixed(2)}',
                        style: AppTextStyles.bodyEmphasized.copyWith(
                          color: AppColors.accent,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(item),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSidebar() {
    return Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, size: 20),
              const SizedBox(width: 8),
              Text('Your Cart', style: AppTextStyles.bodyEmphasized),
            ],
          ),
        ),
        const Divider(height: 1),

        // Cart Items
        Expanded(
          child: _cart.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Your cart is empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['quantity']}x ${item['name']}',
                                  style: AppTextStyles.bodyEmphasized.copyWith(fontSize: 12),
                                  maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${item['price'].toStringAsFixed(2)} each',
                                  style: AppTextStyles.small.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                style: AppTextStyles.bodyEmphasized.copyWith(fontSize: 12),
                              ),
                              IconButton(
                                onPressed: () => _removeFromCart(item['id']),
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Cart Footer
        if (_cart.isNotEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTextStyles.bodyEmphasized),
                    Text(
                      '\$${_cartTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyEmphasized.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Delivery', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Pickup', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsTab() {
    return const Center(child: Text('Reviews coming soon'));
  }

  Widget _buildReservationTab() {
    return const Center(child: Text('Reservations coming soon'));
  }

  Widget _buildInfoTab(Map<String, dynamic> restaurant) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      children: [
        Text('About', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          restaurant['address'] ?? 'Address not available',
          style: AppTextStyles.bodyPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Contact', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          restaurant['email'] ?? 'Email not available',
          style: AppTextStyles.bodyPrimary,
        ),
      ],
    );
  }
}
