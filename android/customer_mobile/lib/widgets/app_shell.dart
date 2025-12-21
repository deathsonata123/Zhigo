import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_header.dart';
import 'app_footer.dart';

/// AppShell - Main app wrapper with header, content, and footer
/// Provides consistent structure across all pages
class AppShell extends StatelessWidget {
  final Widget child;
  final int cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onSignupTap;
  final bool isAuthenticated;
  final bool showFooter;

  const AppShell({
    super.key,
    required this.child,
    this.cartCount = 0,
    this.onCartTap,
    this.onProfileTap,
    this.onLoginTap,
    this.onSignupTap,
    this.isAuthenticated = false,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          AppHeader(
            cartCount: cartCount,
            onCartTap: onCartTap,
            onProfileTap: onProfileTap,
            onLoginTap: onLoginTap,
            onSignupTap: onSignupTap,
            isAuthenticated: isAuthenticated,
          ),
          
          // Main Content
          Expanded(
            child: child,
          ),
          
          // Footer
          if (showFooter) const AppFooter(),
        ],
      ),
    );
  }
}
