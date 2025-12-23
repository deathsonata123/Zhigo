import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../screens/map/simple_map_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import 'user_avatar.dart';

/// Floating Bottom Navigation with Avatar Dropdown
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

class _FloatingBottomNavState extends State<FloatingBottomNav> with TickerProviderStateMixin {
  bool _showDropdown = false;
  bool _showAvatarMenu = false;
  int? _hoveredIndex;
  int? _hoveredAvatarIndex;
  late AnimationController _dropdownController;
  late AnimationController _avatarMenuController;
  late AnimationController _arrowController;
  late Animation<double> _dropdownAnimation;
  late Animation<double> _avatarMenuAnimation;
  late Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _avatarMenuController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _dropdownAnimation = CurvedAnimation(
      parent: _dropdownController,
      curve: Curves.easeOut,
    );
    
    _avatarMenuAnimation = CurvedAnimation(
      parent: _avatarMenuController,
      curve: Curves.easeOut,
    );
    
    _arrowRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    _avatarMenuController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _showDropdown = !_showDropdown;
      if (_showDropdown) {
        _dropdownController.forward();
        _arrowController.forward();
      } else {
        _dropdownController.reverse();
        _arrowController.reverse();
      }
    });
  }

  void _toggleAvatarMenu() {
    setState(() {
      _showAvatarMenu = !_showAvatarMenu;
      if (_showAvatarMenu) {
        _avatarMenuController.forward();
      } else {
        _avatarMenuController.reverse();
      }
    });
  }

  void _showSignupModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SignupScreen(),
    );
  }

  void _showLoginModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Stack(
          children: [
            // Main Dropdown Menu (hover-enabled)
            if (_showDropdown)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _dropdownAnimation,
                    child: ScaleTransition(
                      scale: _dropdownAnimation,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDropdownIcon(Icons.map_outlined, 'Map', () {
                              _toggleDropdown();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const SimpleMapScreen()),
                              );
                            }),
                            _buildDropdownIcon(Icons.shopping_cart_outlined, 'Cart', () {
                              _toggleDropdown();
                            }),
                            _buildDropdownIcon(Icons.favorite_outline, 'Favorites', () {
                              _toggleDropdown();
                            }),
                            // Show signup icon ONLY when not logged in
                            if (!auth.isAuthenticated)
                              _buildDropdownIcon(Icons.people_outline, 'Sign Up', () {
                                _toggleDropdown();
                                _showSignupModal(context);
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Avatar Dropdown Menu (only when logged in)
            if (_showAvatarMenu && auth.isAuthenticated)
              Positioned(
                bottom: 80,
                right: 20,
                child: FadeTransition(
                  opacity: _avatarMenuAnimation,
                  child: ScaleTransition(
                    scale: _avatarMenuAnimation,
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatarMenuItem(Icons.person_outline, () {
                            _toggleAvatarMenu();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                            );
                          }, 0),
                          _buildAvatarMenuItem(Icons.settings_outlined, () {
                            _toggleAvatarMenu();
                            // TODO: Navigate to settings
                          }, 1),
                          _buildAvatarMenuItem(Icons.receipt_long_outlined, () {
                            _toggleAvatarMenu();
                            // TODO: Navigate to billings
                          }, 2),
                          _buildAvatarMenuItem(Icons.logout_outlined, () {
                            _toggleAvatarMenu();
                            auth.signOut();
                          }, 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Main Navigation Bar
            Positioned(
              bottom: AppSpacing.sm,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 8,
                  ),
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
                      // Home + Dropdown Arrow (hover to open)
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _hoveredIndex = -1;
                            _showDropdown = true;
                            _dropdownController.forward();
                            _arrowController.forward();
                          });
                        },
                        onExit: (_) {
                          setState(() => _hoveredIndex = null);
                        },
                        child: GestureDetector(
                          onTap: _toggleDropdown,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _hoveredIndex == -1
                                  ? AppColors.baseWhite.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  size: 24,
                                  color: widget.currentIndex == 0
                                      ? AppColors.accent
                                      : AppColors.baseWhite.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                RotationTransition(
                                  turns: _arrowRotation,
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: AppColors.baseWhite.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Cart Icon
                      _buildNavIcon(Icons.shopping_cart_outlined, 1),

                      const SizedBox(width: AppSpacing.sm),

                      // Avatar or Signup Icon
                      if (auth.isAuthenticated)
                        MouseRegion(
                          onEnter: (_) => setState(() => _hoveredIndex = 2),
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          child: GestureDetector(
                            onTap: _toggleAvatarMenu,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: _hoveredIndex == 2
                                    ? Border.all(color: AppColors.accent, width: 2)
                                    : null,
                              ),
                              child: UserAvatar(
                                name: auth.user?['fullName'] ?? auth.user?['email'],
                                imageUrl: auth.user?['avatarUrl'],
                                size: 32,
                              ),
                            ),
                          ),
                        )
                      else
                        _buildNavIcon(Icons.people_outline, 2, onTap: () => _showSignupModal(context)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {VoidCallback? onTap}) {
    final isActive = widget.currentIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap ?? () => widget.onTap(index),
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

  Widget _buildDropdownIcon(IconData icon, String label, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.baseWhite.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarMenuItem(IconData icon, VoidCallback onTap, int index) {
    final isHovered = _hoveredAvatarIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredAvatarIndex = index),
      onExit: (_) => setState(() => _hoveredAvatarIndex = null),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.baseWhite.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.baseWhite.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}
