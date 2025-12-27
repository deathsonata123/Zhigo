import 'package:flutter/material.dart';

// Foodpanda colors
class _FoodpandaColors {
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFFFF5F2);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
  static const Color background = Color(0xFFF8F8F8);
}

/// Checkout Screen - Matches provided design
/// Shows order items, subtotal, fees, total, and Confirm button
class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final String restaurantName;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    this.restaurantName = 'Pizza Palace',
  });

  double get subtotal {
    return cartItems.fold(0, (sum, item) {
      final price = (item['totalPrice'] ?? item['price']) as num;
      final quantity = (item['quantity'] ?? 1) as int;
      return sum + price * quantity;
    });
  }

  double get deliveryFee => 3.00;
  double get taxesAndFees => subtotal * 0.084; // ~8.4% tax
  double get total => subtotal + deliveryFee + taxesAndFees;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Your Order Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Order',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Order items
                          ...cartItems.map((item) => _buildOrderItem(
                            item['name'] as String,
                            ((item['totalPrice'] ?? item['price']) as num).toDouble(),
                          )),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pricing Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Subtotal', subtotal),
                          const SizedBox(height: 12),
                          _buildPriceRow('Delivery Fee', deliveryFee),
                          const SizedBox(height: 12),
                          _buildPriceRow('Taxes & Fees', taxesAndFees),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildPriceRow('Total', total, isBold: true, isLarge: true),
                          const SizedBox(height: 16),
                          // Promo code link
                          GestureDetector(
                            onTap: () {
                              // TODO: Open promo code dialog
                            },
                            child: Text(
                              'Add promo code',
                              style: TextStyle(
                                color: _FoodpandaColors.grey600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Container(
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
              child: _HoverButton(
                text: 'Confirm and Pay',
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderConfirmedScreen(
                        restaurantName: restaurantName,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 20 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? _FoodpandaColors.grey900 : _FoodpandaColors.grey600,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isLarge ? 24 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Order Confirmed Screen - Shows success message
class OrderConfirmedScreen extends StatelessWidget {
  final String restaurantName;

  const OrderConfirmedScreen({
    super.key,
    this.restaurantName = 'The Corner Bistro',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Content - centered
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkmark icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _FoodpandaColors.coral,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 50,
                        color: _FoodpandaColors.coral,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Order Confirmed!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your order from $restaurantName is\nbeing prepared.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _FoodpandaColors.grey600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Button
            Container(
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
              child: _HoverButton(
                text: 'Track Your Order',
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OrderTrackingScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Tracking Screen - Shows delivery status with map
class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.grey100,
      body: Stack(
        children: [
          // Map background placeholder
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _FoodpandaColors.grey100,
                    _FoodpandaColors.grey200,
                  ],
                ),
              ),
              // Simple map-like pattern
              child: CustomPaint(
                painter: _MapPatternPainter(),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header card
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Status card at bottom
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Arriving in 12 min',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Status steps
                      _buildStatusStep('Confirmed', true, false),
                      _buildStatusStep('Preparing', true, false),
                      _buildStatusStep('On the way', true, true),
                      _buildStatusStep('Delivered', false, false),
                      
                      const SizedBox(height: 16),
                      
                      // Rider info
                      Text(
                        'Your rider, Alex, is on the way.',
                        style: TextStyle(
                          fontSize: 14,
                          color: _FoodpandaColors.grey600,
                        ),
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
  }

  Widget _buildStatusStep(String label, bool isCompleted, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (isCompleted && !isCurrent)
            Icon(
              Icons.check,
              size: 16,
              color: _FoodpandaColors.grey600,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCompleted || isCurrent 
                  ? _FoodpandaColors.grey900 
                  : _FoodpandaColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// Map pattern painter for background
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _FoodpandaColors.grey200.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some road-like lines
    final path = Path();
    path.moveTo(size.width * 0.7, 0);
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.3,
      size.width * 0.6, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.7,
      size.width * 0.5, size.height,
    );
    canvas.drawPath(path, paint);

    // Draw another road
    final path2 = Path();
    path2.moveTo(0, size.height * 0.3);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.35,
      size.width * 0.5, size.height * 0.5,
    );
    path2.quadraticBezierTo(
      size.width * 0.7, size.height * 0.65,
      size.width, size.height * 0.6,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            borderRadius: BorderRadius.circular(30),
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
