import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import 'user_avatar.dart';

/// Clean Floating Bottom Navigation with hover effects on icons
class FloatingBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  int? _hoveredIndex;

  void _showLoginModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Positioned(
          bottom: AppSpacing.sm,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E).withOpacity(0.85),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Home icon
                  _buildNavIcon(
                    icon: Icons.home_rounded,
                    index: 0,
                    onTap: () => widget.onTap(0),
                  ),

                  const SizedBox(width: 16),

                  // Search icon
                  _buildNavIcon(
                    icon: Icons.search_outlined,
                    index: 1,
                    onTap: () => widget.onTap(1),
                  ),

                  const SizedBox(width: 16),

                  // Chat icon
                  _buildNavIcon(
                    icon: Icons.chat_bubble_outline,
                    index: 2,
                    onTap: () => widget.onTap(2),
                  ),

                  const SizedBox(width: 16),

                  // User avatar or login icon
                  if (auth.isAuthenticated)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => widget.onTap(3),
                        child: UserAvatar(
                          name: auth.user?['fullName'] ?? auth.user?['email'] ?? '?',
                          imageUrl: auth.user?['avatarUrl'],
                          size: 32,
                        ),
                      ),
                    )
                  else
                    _buildNavIcon(
                      icon: Icons.people_outline,
                      index: 3,
                      onTap: () => _showLoginModal(context),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = widget.currentIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.baseWhite.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isActive
                ? AppColors.accent
                : AppColors.baseWhite.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
