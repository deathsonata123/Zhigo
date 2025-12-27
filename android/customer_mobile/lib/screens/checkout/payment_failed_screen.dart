import 'package:flutter/material.dart';

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
}

/// Payment Failed Modal/Screen
class PaymentFailedScreen extends StatelessWidget {
  final String paymentMethod;
  final String lastFour;
  final VoidCallback onTryAnotherMethod;
  final VoidCallback onTryAgain;

  const PaymentFailedScreen({
    super.key,
    required this.paymentMethod,
    required this.lastFour,
    required this.onTryAnotherMethod,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: _FoodpandaColors.grey300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Error Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _FoodpandaColors.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          size: 32,
                          color: _FoodpandaColors.grey500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    const Text(
                      'Payment Failed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _FoodpandaColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Message
                    Text(
                      'Your payment with $paymentMethod •••• $lastFour could not be processed. Please try again or use a different method.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: _FoodpandaColors.grey600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Buttons
                    _PrimaryButton(
                      text: 'Try Another Method',
                      onTap: onTryAnotherMethod,
                    ),
                    const SizedBox(height: 12),
                    _OutlineButton(
                      text: 'Try Again',
                      onTap: onTryAgain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show Payment Failed as a bottom sheet
void showPaymentFailedSheet(
  BuildContext context, {
  required String paymentMethod,
  required String lastFour,
  required VoidCallback onTryAnotherMethod,
  required VoidCallback onTryAgain,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
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
              height: 5,
              decoration: BoxDecoration(
                color: _FoodpandaColors.grey300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.fromLTRB(
                32, 24, 32, MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                children: [
                  // Error Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _FoodpandaColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 32,
                        color: _FoodpandaColors.grey500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  const Text(
                    'Payment Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _FoodpandaColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Message
                  Text(
                    'Your payment with $paymentMethod •••• $lastFour could not be processed. Please try again or use a different method.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _FoodpandaColors.grey600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Buttons
                  _PrimaryButton(
                    text: 'Try Another Method',
                    onTap: () {
                      Navigator.of(context).pop();
                      onTryAnotherMethod();
                    },
                  ),
                  const SizedBox(height: 12),
                  _OutlineButton(
                    text: 'Try Again',
                    onTap: () {
                      Navigator.of(context).pop();
                      onTryAgain();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
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

// Outline Button
class _OutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.coralLight : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _FoodpandaColors.coral,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: _FoodpandaColors.coral,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
