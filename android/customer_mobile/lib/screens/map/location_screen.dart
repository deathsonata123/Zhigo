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
}

/// Location Picker Screen - "Where to?" 
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    setState(() => _isLoading = true);
    
    // Simulate getting location
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _navigateToHome();
      }
    });
  }

  void _confirmAddress() {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an address or use current location'),
          backgroundColor: _FoodpandaColors.coral,
        ),
      );
      return;
    }
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Where to?',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _FoodpandaColors.grey900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'We need your address to show you restaurants and stores.',
                          style: TextStyle(
                            fontSize: 16,
                            color: _FoodpandaColors.grey600,
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Use Current Location Button
                        _LocationButton(
                          icon: Icons.my_location,
                          text: 'Use Current Location',
                          onTap: _useCurrentLocation,
                          isLoading: _isLoading,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Manual Address Input
                        _AddressInput(
                          controller: _addressController,
                          hintText: 'Enter your address manually',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Button
            _BottomButton(
              text: 'Confirm Address',
              onTap: _confirmAddress,
            ),
          ],
        ),
      ),
    );
  }
}

// Location Button Widget
class _LocationButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const _LocationButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<_LocationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? _FoodpandaColors.coralLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_FoodpandaColors.coral),
                  ),
                )
              else
                Icon(
                  widget.icon,
                  size: 20,
                  color: _FoodpandaColors.coral,
                ),
              const SizedBox(width: 12),
              Text(
                widget.text,
                style: const TextStyle(
                  color: _FoodpandaColors.coral,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Address Input Widget
class _AddressInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const _AddressInput({
    required this.controller,
    required this.hintText,
  });

  @override
  State<_AddressInput> createState() => _AddressInputState();
}

class _AddressInputState extends State<_AddressInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? _FoodpandaColors.coral : _FoodpandaColors.grey300,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(
            fontSize: 16,
            color: _FoodpandaColors.grey900,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: _FoodpandaColors.grey500,
              fontSize: 15,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// Bottom Button Widget
class _BottomButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _BottomButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_BottomButton> createState() => _BottomButtonState();
}

class _BottomButtonState extends State<_BottomButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
      child: MouseRegion(
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
      ),
    );
  }
}
