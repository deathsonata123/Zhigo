import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'reset_password_screen.dart';

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

/// Welcome/Login Screen - Clean minimal design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number'),
          backgroundColor: _FoodpandaColors.coral,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Simulate login - replace with actual auth
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  void _handleGoogleLogin() {
    setState(() => _isLoading = true);
    
    // Simulate Google login
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  void _handleAppleLogin() {
    setState(() => _isLoading = true);
    
    // Simulate Apple login
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
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
                  // Welcome Text
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _FoodpandaColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in or create an account to get started.',
                    style: TextStyle(
                      fontSize: 16,
                      color: _FoodpandaColors.grey600,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Email/Phone Label
                  const Text(
                    'Email or Phone Number',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _FoodpandaColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Email Input
                  _InputField(
                    controller: _emailController,
                    hintText: 'Enter your email or phone number',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Continue Button
                  _PrimaryButton(
                    text: 'Continue',
                    onTap: _handleContinue,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Google Button
                  _OutlineButton(
                    text: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    iconColor: Colors.blue,
                    onTap: _handleGoogleLogin,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Apple Button
                  _OutlineButton(
                    text: 'Continue with Apple',
                    icon: Icons.apple,
                    iconColor: _FoodpandaColors.coral,
                    onTap: _handleAppleLogin,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Forgot Password
                  Center(
                    child: _ForgotPasswordLink(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Input Field Widget
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
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
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
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

// Primary Button Widget
class _PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
    this.isLoading = false,
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
        onTap: widget.isLoading ? null : widget.onTap,
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
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
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

// Outline Button Widget
class _OutlineButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
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
                ? _FoodpandaColors.coralLight
                : (_isHovered ? _FoodpandaColors.grey100 : Colors.white),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 24,
                color: widget.iconColor,
              ),
              const SizedBox(width: 12),
              Text(
                widget.text,
                style: TextStyle(
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

// Forgot Password Link
class _ForgotPasswordLink extends StatefulWidget {
  final VoidCallback onTap;

  const _ForgotPasswordLink({required this.onTap});

  @override
  State<_ForgotPasswordLink> createState() => _ForgotPasswordLinkState();
}

class _ForgotPasswordLinkState extends State<_ForgotPasswordLink> {
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
          'Forgot Password?',
          style: TextStyle(
            fontSize: 15,
            color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
