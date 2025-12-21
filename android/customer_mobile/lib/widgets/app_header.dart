import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// App Header - Main navigation header
/// Features: Logo, nav links, cart, profile/auth buttons
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onSignupTap;
  final bool isAuthenticated;

  const AppHeader({
    super.key,
    this.cartCount = 0,
    this.onCartTap,
    this.onProfileTap,
    this.onLoginTap,
    this.onSignupTap,
    this.isAuthenticated = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMarginHorizontal,
      ),
      child: Row(
        children: [
          // Logo
          _buildLogo(context),
          
          const SizedBox(width: AppSpacing.lg),
          
          // Navigation Links (Desktop)
          if (MediaQuery.of(context).size.width > 768) ...[
            _buildNavLink(context, 'Restaurants', '/restaurants'),
            const SizedBox(width: AppSpacing.md),
            _buildNavLink(context, 'Map', '/map'),
          ],
          
          const Spacer(),
          
          // Cart Button
          _buildCartButton(),
          
          const SizedBox(width: AppSpacing.sm),
          
          // Auth/Profile Section
          if (isAuthenticated)
            _buildProfileButton()
          else
            _buildAuthButtons(),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.restaurant,
          color: AppColors.accent,
          size: 28,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Zhigo',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink(BuildContext context, String label, String route) {
    return TextButton(
      onPressed: () {
        // Navigator.pushNamed(context, route);
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyEmphasized.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onCartTap,
          icon: const Icon(Icons.shopping_cart_outlined),
          color: AppColors.textPrimary,
        ),
        if (cartCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                cartCount > 9 ? '9+' : cartCount.toString(),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.baseWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return IconButton(
      onPressed: onProfileTap,
      icon: const Icon(Icons.person_outline),
      color: AppColors.textPrimary,
    );
  }

  Widget _buildAuthButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: onLoginTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),
          child: Text('Login', style: AppTextStyles.button),
        ),
        const SizedBox(width: AppSpacing.xs),
        ElevatedButton(
          onPressed: onSignupTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),
          child: Text('Sign Up', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
