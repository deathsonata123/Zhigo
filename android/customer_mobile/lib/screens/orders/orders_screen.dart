import 'package:flutter/material.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../checkout/checkout_screen.dart';

// Foodpanda colors
class _FoodpandaColors {
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFFFF5F2);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
  static const Color background = Color(0xFFF8F8F8);
}

/// Orders/Cart Screen with empty and filled states
class OrdersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const OrdersScreen({
    super.key,
    this.cartItems = const [],
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.cartItems);
  }

  double get _total {
    return _items.fold(0, (sum, item) {
      final price = (item['totalPrice'] ?? item['price']) as num;
      final quantity = (item['quantity'] ?? 1) as int;
      return sum + price * quantity;
    });
  }

  void _incrementItem(int index) {
    setState(() {
      _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) + 1;
    });
  }

  void _decrementItem(int index) {
    setState(() {
      final qty = (_items[index]['quantity'] ?? 1) as int;
      if (qty > 1) {
        _items[index]['quantity'] = qty - 1;
      } else {
        _items.removeAt(index);
      }
    });
  }

  void _checkout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: _items,
          restaurantName: 'Your Order',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _FoodpandaColors.grey900,
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: _items.isEmpty
                  ? _buildEmptyState()
                  : _buildCartItems(),
            ),
            
            // Checkout button (only when items exist)
            if (_items.isNotEmpty)
              _buildCheckoutButton(),
              
            // Bottom Nav
            FloatingBottomNav(
              currentIndex: 2,
              onTap: (_) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: _FoodpandaColors.grey300,
          ),
          const SizedBox(height: 32),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Start adding items from a restaurant or store to place an order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _FoodpandaColors.grey600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _CartItemCard(
          name: item['name'] as String,
          restaurant: item['restaurant'] as String? ?? 'Restaurant',
          price: ((item['totalPrice'] ?? item['price']) as num).toDouble(),
          quantity: (item['quantity'] ?? 1) as int,
          imageUrl: item['imageUrl'] as String?,
          onIncrement: () => _incrementItem(index),
          onDecrement: () => _decrementItem(index),
        );
      },
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            text: 'Proceed to Checkout',
            onTap: _checkout,
          ),
        ],
      ),
    );
  }
}

// Cart Item Card
class _CartItemCard extends StatelessWidget {
  final String name;
  final String restaurant;
  final double price;
  final int quantity;
  final String? imageUrl;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _FoodpandaColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fastfood,
              color: _FoodpandaColors.grey400,
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  restaurant,
                  style: TextStyle(
                    fontSize: 13,
                    color: _FoodpandaColors.grey500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${(price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity controls
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: onDecrement,
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
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Quantity Button
class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _isHovered ? Colors.white : _FoodpandaColors.grey600,
          ),
        ),
      ),
    );
  }
}

// Primary Button
class _PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _isPressed
                ? _FoodpandaColors.coral.withOpacity(0.8)
                : (_isHovered
                    ? _FoodpandaColors.coral.withOpacity(0.9)
                    : _FoodpandaColors.coral),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _FoodpandaColors.coral.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
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
