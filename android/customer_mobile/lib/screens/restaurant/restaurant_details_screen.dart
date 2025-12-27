import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../checkout/checkout_screen.dart';

// Foodpanda colors
class _FoodpandaColors {
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFFFF5F2);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
}

/// Restaurant Details Screen - Matches Foodpanda UI
/// Features: Hero image, menu list, bottom sheet popup on food tap, cart panel
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

class _RestaurantDetailsFullScreenState extends State<RestaurantDetailsFullScreen> 
    with TickerProviderStateMixin {
  int _currentNavIndex = -1;
  Map<String, dynamic>? _selectedFood;
  bool _showCart = false;
  bool _showCustomizeSheet = false; // Two-step flow: false = food detail, true = size/addons
  
  // Food popup state
  String _selectedSize = 'medium';
  int _foodQuantity = 1;
  Set<String> _selectedAddons = {};
  
  // Cart state
  List<Map<String, dynamic>> _cart = [];
  
  // Animation controllers
  late AnimationController _overlayController;
  late AnimationController _sheetController;
  late Animation<double> _overlayAnimation;
  late Animation<Offset> _sheetSlideAnimation;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _overlayAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeOut),
    );
    _sheetSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _sheetController.dispose();
    super.dispose();
  }
  
  // Menu items grouped by category
  final Map<String, List<Map<String, dynamic>>> _menuByCategory = {
    'Appetizers': [
      {
        'id': '1',
        'name': 'Garlic Bread with Mozzarella',
        'description': 'Toasted bread with garlic butter, topped with melted mozzarella cheese.',
        'price': 8.50,
        'imageUrl': 'https://images.unsplash.com/photo-1619535860434-ba1d8fa12536',
      },
      {
        'id': '2',
        'name': 'Bruschetta al Pomodoro',
        'description': 'Grilled bread rubbed with garlic and topped with fresh tomatoes, basil, and olive oil.',
        'price': 9.00,
        'imageUrl': 'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f',
      },
    ],
    'Pizza': [
      {
        'id': '3',
        'name': 'Margherita',
        'description': 'A true Neapolitan classic. Our Margherita is crafted with the finest ingredients: hand-crushed San Marzano tomatoes for a sweet and tangy base, creamy fresh mozzarella, fragrant basil leaves, and a generous drizzle of extra virgin olive oil. All baked to perfection in our wood-fired oven for a soft, chewy crust with a slight char.',
        'price': 18.00,
        'imageUrl': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
      },
      {
        'id': '4',
        'name': 'Pepperoni',
        'description': 'Classic pepperoni pizza with mozzarella cheese and our signature tomato sauce.',
        'price': 20.00,
        'imageUrl': 'https://images.unsplash.com/photo-1628840042765-356cda07504e',
      },
      {
        'id': '5',
        'name': 'Quattro Formaggi',
        'description': 'Four cheese pizza with mozzarella, gorgonzola, parmesan, and fontina.',
        'price': 22.00,
        'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      },
    ],
    'Pasta': [
      {
        'id': '6',
        'name': 'Spaghetti Carbonara',
        'description': 'Creamy pasta with pancetta, egg, and parmesan cheese.',
        'price': 16.00,
        'imageUrl': 'https://images.unsplash.com/photo-1612874742237-6526221588e3',
      },
      {
        'id': '7',
        'name': 'Penne Arrabbiata',
        'description': 'Spicy tomato sauce with garlic and red chili flakes.',
        'price': 14.00,
        'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9',
      },
    ],
  };

  void _showFoodDetails(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _showCart = false;
      _showCustomizeSheet = false; // Start with food detail view
      // Reset popup state
      _selectedSize = 'medium';
      _foodQuantity = 1;
      _selectedAddons = {};
    });
    _overlayController.forward();
    _sheetController.forward();
  }

  void _showCustomize() {
    // Transition to customize sheet (size/addons)
    _sheetController.reverse().then((_) {
      setState(() {
        _showCustomizeSheet = true;
      });
      _sheetController.forward();
    });
  }

  void _closeFoodDetails() {
    _overlayController.reverse();
    _sheetController.reverse().then((_) {
      setState(() {
        _selectedFood = null;
        _showCustomizeSheet = false;
      });
    });
  }

  void _addToCart(Map<String, dynamic> food) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item['id'] == food['id']);
      if (existingIndex == -1) {
        _cart.add({...food, 'quantity': 1});
      } else {
        _cart[existingIndex]['quantity'] = (_cart[existingIndex]['quantity'] as int) + 1;
      }
      _selectedFood = null;
      _showCart = true;
    });
    // Reset animation for cart
    _sheetController.reset();
    _sheetController.forward();
  }

  void _closeCart() {
    _overlayController.reverse();
    _sheetController.reverse().then((_) {
      setState(() {
        _showCart = false;
      });
    });
  }

  void _updateQuantity(String id, int delta) {
    setState(() {
      final index = _cart.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _cart[index]['quantity'] = (_cart[index]['quantity'] as int) + delta;
        if (_cart[index]['quantity'] <= 0) {
          _cart.removeAt(index);
          if (_cart.isEmpty) {
            _closeCart();
          }
        }
      }
    });
  }

  double get _cartTotal {
    return _cart.fold(0, (sum, item) => sum + (item['price'] as num) * (item['quantity'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant ?? {
      'name': 'Pizza Palace',
      'rating': 4.9,
      'business_type': 'Italian',
      'deliveryTime': '30-40 min',
      'imageUrl': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                leading: _HoverIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  restaurant['name'] ?? 'Restaurant',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: restaurant['imageUrl'] ?? restaurant['photo_url'] ?? 
                      'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: _FoodpandaColors.grey100),
                    errorWidget: (_, __, ___) => Container(
                      color: _FoodpandaColors.grey100,
                      child: const Icon(Icons.restaurant, size: 60),
                    ),
                  ),
                ),
              ),
              
              // Restaurant Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant['name'] ?? 'Restaurant',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant['rating'] ?? 4.5}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ' • ${restaurant['business_type'] ?? 'Restaurant'}',
                            style: TextStyle(color: _FoodpandaColors.grey600),
                          ),
                          Text(
                            ' • ${restaurant['deliveryTime'] ?? '30-40 min'}',
                            style: TextStyle(color: _FoodpandaColors.grey600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Menu by Category
              ..._menuByCategory.entries.expand((entry) => [
                // Category Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Category Items
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = entry.value[index];
                      return _MenuItemCard(
                        item: item,
                        onTap: () => _showFoodDetails(item),
                      );
                    },
                    childCount: entry.value.length,
                  ),
                ),
              ]).toList(),
              
              // Bottom padding for nav
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
          
          // Dark Overlay
          if (_selectedFood != null || _showCart)
            FadeTransition(
              opacity: _overlayAnimation,
              child: GestureDetector(
                onTap: _selectedFood != null ? _closeFoodDetails : _closeCart,
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
          
          // Bottom Sheet for Food Details (two-step flow)
          if (_selectedFood != null)
            SlideTransition(
              position: _sheetSlideAnimation,
              child: _showCustomizeSheet 
                  ? _buildCustomizeSheet(_selectedFood!)
                  : _buildFoodDetailSheet(_selectedFood!),
            ),
          
          // Bottom Sheet for Cart
          if (_showCart && _cart.isNotEmpty)
            SlideTransition(
              position: _sheetSlideAnimation,
              child: _buildCartSheet(),
            ),

          // Floating Bottom Nav (hide when sheets are open)
          if (_selectedFood == null && !_showCart)
            FloatingBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (index) => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  // First popup - Simple food detail view
  Widget _buildFoodDetailSheet(Map<String, dynamic> food) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: CachedNetworkImage(
                  imageUrl: food['imageUrl'],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 220,
                    color: _FoodpandaColors.grey100,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 220,
                    color: _FoodpandaColors.grey100,
                    child: const Icon(Icons.fastfood, size: 60),
                  ),
                ),
              ),
              
              // Food Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            food['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '\$${(food['price'] as num).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      food['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: _FoodpandaColors.grey600,
                        height: 1.6,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Add to Cart Button (goes to customize sheet)
                    _HoverButton(
                      text: 'Add to Cart',
                      onTap: _showCustomize,
                    ),
                    
                    // Bottom padding for safe area
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Second popup - Size/Addons customization
  Widget _buildCustomizeSheet(Map<String, dynamic> food) {
    // Size options with prices
    final sizeOptions = {
      'medium': {'label': 'Medium (12-inch)', 'price': food['price'] as num},
      'large': {'label': 'Large (16-inch)', 'price': (food['price'] as num) + 4.0},
    };
    
    // Add-on options
    final addonOptions = [
      {'id': 'cheese', 'name': 'Extra Cheese', 'price': 2.00},
      {'id': 'pepperoni', 'name': 'Pepperoni', 'price': 3.00},
      {'id': 'mushrooms', 'name': 'Mushrooms', 'price': 1.50},
      {'id': 'olives', 'name': 'Black Olives', 'price': 1.50},
    ];
    
    // Calculate total price
    final basePrice = sizeOptions[_selectedSize]!['price'] as num;
    final addonTotal = _selectedAddons.fold<double>(0, (sum, addonId) {
      final addon = addonOptions.firstWhere((a) => a['id'] == addonId, orElse: () => {'price': 0});
      return sum + (addon['price'] as num);
    });
    final totalPrice = (basePrice + addonTotal) * _foodQuantity;
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: CachedNetworkImage(
                        imageUrl: food['imageUrl'],
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 220,
                          color: _FoodpandaColors.grey100,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 220,
                          color: _FoodpandaColors.grey100,
                          child: const Icon(Icons.fastfood, size: 60),
                        ),
                      ),
                    ),
                    
                    // Food Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            food['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Description
                          Text(
                            food['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: _FoodpandaColors.grey600,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Size Selection
                          Text(
                            'Choose a size',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Required • Choose 1',
                            style: TextStyle(
                              fontSize: 13,
                              color: _FoodpandaColors.coral,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Size Options
                          ...sizeOptions.entries.map((entry) {
                            final isSelected = _selectedSize == entry.key;
                            return _SizeOptionTile(
                              label: entry.value['label'] as String,
                              price: entry.value['price'] as num,
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedSize = entry.key),
                            );
                          }).toList(),
                          
                          const SizedBox(height: 24),
                          
                          // Add-ons
                          Text(
                            'Add-ons',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 13,
                              color: _FoodpandaColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Addon Options
                          ...addonOptions.map((addon) {
                            final isSelected = _selectedAddons.contains(addon['id']);
                            return _AddonOptionTile(
                              name: addon['name'] as String,
                              price: addon['price'] as num,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedAddons.remove(addon['id']);
                                  } else {
                                    _selectedAddons.add(addon['id'] as String);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Fixed Bottom Bar with Quantity and Add to Cart
            Container(
              padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      color: _FoodpandaColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_foodQuantity > 1) {
                              setState(() => _foodQuantity--);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_foodQuantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _foodQuantity++),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Add to Cart Button with Price
                  Expanded(
                    child: _HoverButton(
                      text: 'Add to Cart - \$${totalPrice.toStringAsFixed(2)}',
                      onTap: () {
                        // Add to cart with selected options
                        setState(() {
                          final cartItem = {
                            ...food,
                            'selectedSize': _selectedSize,
                            'selectedAddons': _selectedAddons.toList(),
                            'quantity': _foodQuantity,
                            'totalPrice': totalPrice,
                          };
                          _cart.add(cartItem);
                          _selectedFood = null;
                          _showCustomizeSheet = false;
                          _showCart = true;
                        });
                        _sheetController.reset();
                        _sheetController.forward();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _FoodpandaColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Cart Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_cart.length} items',
                    style: TextStyle(
                      color: _FoodpandaColors.grey600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Cart Items
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  final item = _cart[index];
                  return _CartItemCard(
                    item: item,
                    onIncrement: () => _updateQuantity(item['id'], 1),
                    onDecrement: () => _updateQuantity(item['id'], -1),
                  );
                },
              ),
            ),
            
            // Cart Total and Checkout
            Container(
              padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${_cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _HoverButton(
                    text: 'Checkout',
                    onTap: () {
                      _closeCart();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            cartItems: _cart,
                            restaurantName: widget.restaurant?['name'] ?? 'Restaurant',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hover Icon Button Widget
class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HoverIconButton({required this.icon, required this.onTap});

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
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
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.grey100 : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: _isHovered ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Icon(widget.icon, size: 20),
        ),
      ),
    );
  }
}

// Hover Button Widget
class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HoverButton({required this.text, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isPressed 
                ? _FoodpandaColors.coral.withOpacity(0.8)
                : (_isHovered ? _FoodpandaColors.coral.withOpacity(0.9) : _FoodpandaColors.coral),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: _FoodpandaColors.coral.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Menu Item Card Widget
class _MenuItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _MenuItemCard({required this.item, required this.onTap});

  @override
  State<_MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<_MenuItemCard> {
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.grey100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? _FoodpandaColors.coral.withOpacity(0.3) : _FoodpandaColors.grey200,
            ),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
          transformAlignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: _FoodpandaColors.grey600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Price
              Text(
                '\$${(widget.item['price'] as num).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cart Item Card Widget
class _CartItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  @override
  Widget build(BuildContext context) {
    final quantity = widget.item['quantity'] as int;
    final price = widget.item['price'] as num;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _FoodpandaColors.grey200),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: widget.item['imageUrl'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 60,
                height: 60,
                color: _FoodpandaColors.grey100,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: _FoodpandaColors.grey100,
                child: const Icon(Icons.fastfood),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(price * quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _FoodpandaColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: widget.onDecrement,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: widget.onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Quantity Button Widget
class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.coral : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: _isHovered ? Colors.white : _FoodpandaColors.grey900,
          ),
        ),
      ),
    );
  }
}

// Size Option Tile Widget
class _SizeOptionTile extends StatefulWidget {
  final String label;
  final num price;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeOptionTile({
    required this.label,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SizeOptionTile> createState() => _SizeOptionTileState();
}

class _SizeOptionTileState extends State<_SizeOptionTile> {
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
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? _FoodpandaColors.coralLight 
                : (_isHovered ? _FoodpandaColors.grey100 : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? _FoodpandaColors.coral : _FoodpandaColors.grey200,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio Circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _FoodpandaColors.coral,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Label
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
              ),
              // Price
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _FoodpandaColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Addon Option Tile Widget
class _AddonOptionTile extends StatefulWidget {
  final String name;
  final num price;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddonOptionTile({
    required this.name,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AddonOptionTile> createState() => _AddonOptionTileState();
}

class _AddonOptionTileState extends State<_AddonOptionTile> {
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
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? _FoodpandaColors.coralLight 
                : (_isHovered ? _FoodpandaColors.grey100 : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? _FoodpandaColors.coral : _FoodpandaColors.grey200,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.isSelected ? _FoodpandaColors.coral : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isSelected ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              // Name
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
              ),
              // Price
              Text(
                '+\$${widget.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  color: _FoodpandaColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
