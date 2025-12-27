import 'package:flutter/material.dart';
import '../home/home_screen.dart';

// Foodpanda colors
class _FoodpandaColors {
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFFFF5F2);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
  static const Color background = Color(0xFFF8F8F8);
  static const Color starFilled = Color(0xFFE8734A);
  static const Color starEmpty = Color(0xFFE0E0E0);
}

/// Order Feedback Screen - Rate experience and add tip
class OrderFeedbackScreen extends StatefulWidget {
  final String restaurantName;
  final String orderId;

  const OrderFeedbackScreen({
    super.key,
    required this.restaurantName,
    this.orderId = '',
  });

  @override
  State<OrderFeedbackScreen> createState() => _OrderFeedbackScreenState();
}

class _OrderFeedbackScreenState extends State<OrderFeedbackScreen> {
  int _rating = 4; // 1-5 stars
  String _selectedTip = '15%';
  final List<String> _tipOptions = ['10%', '15%', '20%', 'Custom'];

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: _FoodpandaColors.coral,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _skip() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How was your order?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _FoodpandaColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your feedback for ${widget.restaurantName} helps us improve.',
                    style: TextStyle(
                      fontSize: 15,
                      color: _FoodpandaColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Rating Card
                    _buildRatingCard(),
                    const SizedBox(height: 16),
                    // Tip Card
                    _buildTipCard(),
                  ],
                ),
              ),
            ),
            
            // Bottom Buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate your experience',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    size: 44,
                    color: starIndex <= _rating
                        ? _FoodpandaColors.starFilled
                        : _FoodpandaColors.starEmpty,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a tip',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: _tipOptions.map((tip) {
              final isSelected = _selectedTip == tip;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _TipButton(
                  text: tip,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedTip = tip),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
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
          _PrimaryButton(
            text: 'Submit Feedback',
            onTap: _submitFeedback,
          ),
          const SizedBox(height: 12),
          _SkipButton(onTap: _skip),
        ],
      ),
    );
  }
}

// Tip Button
class _TipButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TipButton> createState() => _TipButtonState();
}

class _TipButtonState extends State<_TipButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected ? _FoodpandaColors.coral : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected
                  ? _FoodpandaColors.coral
                  : (_isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey300),
              width: 1.5,
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: widget.isSelected ? Colors.white : _FoodpandaColors.grey900,
            ),
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

// Skip Button
class _SkipButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SkipButton({required this.onTap});

  @override
  State<_SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<_SkipButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          'Skip',
          style: TextStyle(
            fontSize: 16,
            color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
