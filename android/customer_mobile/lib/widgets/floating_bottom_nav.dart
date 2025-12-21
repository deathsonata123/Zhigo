import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../screens/map/simple_map_screen.dart';
import '../screens/profile/user_profile_screen.dart';

/// Floating Bottom Navigation with Dropdown
/// Hover effects, unified home+arrow, icon-only dropdown, cart button
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
  int? _hoveredIndex;
  late AnimationController _dropdownController;
  late AnimationController _arrowController;
  late Animation<double> _dropdownAnimation;
  late Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    
    _dropdownController = AnimationController(
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
    
    _arrowRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dropdownController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dropdown Menu (icon-only with hover)
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
                    child: Row(
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
                          // TODO: Navigate to cart
                        }),
                        _buildDropdownIcon(Icons.person_outline, 'Profile', () {
                          _toggleDropdown();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                          );
                        }),
                        _buildDropdownIcon(Icons.favorite_outline, 'Favorites', () {
                          _toggleDropdown();
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Main Navigation Bar (reduced height, more transparent)
        Positioned(
          bottom: AppSpacing.sm,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 8, // Reduced from AppSpacing.xs
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E).withOpacity(0.85), // More transparent
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
                  // Home + Dropdown Arrow (UNIFIED - no gap)
                  GestureDetector(
                    onTap: _toggleDropdown,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = -1),
                      onExit: (_) => setState(() => _hoveredIndex = null),
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
                            // Arrow right next to home (no gap)
                            RotationTransition(
                              turns: _arrowRotation,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.baseWhite.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppSpacing.md),
                  
                  _buildNavItem(
                    icon: Icons.search_rounded,
                    index: 1,
                    label: 'Search',
                  ),
                  
                  const SizedBox(width: AppSpacing.md),
                  
                  _buildAINavItem(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Builder(
          builder: (context) {
            bool isHovered = false;
            return StatefulBuilder(
              builder: (context, setState) {
                return MouseRegion(
                  onEnter: (_) => setState(() => isHovered = true),
                  onExit: (_) => setState(() => isHovered = false),
                  child: GestureDetector(
                    onTap: onTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isHovered 
                            ? AppColors.accent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isHovered 
                            ? AppColors.accent
                            : AppColors.baseWhite.withOpacity(0.8),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isActive = widget.currentIndex == index;
    final isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 6,
          ),
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
                : (isHovered 
                    ? AppColors.baseWhite.withOpacity(0.9)
                    : AppColors.baseWhite.withOpacity(0.6)),
          ),
        ),
      ),
    );
  }

  Widget _buildAINavItem() {
    final isActive = widget.currentIndex == 2;
    final isHovered = _hoveredIndex == 2;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = 2),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => widget.onTap(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Always glowing, MORE when active or hovered
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(
                  isActive ? 0.7 : (isHovered ? 0.5 : 0.4)
                ),
                blurRadius: isActive ? 24 : (isHovered ? 20 : 16),
                spreadRadius: isActive ? 6 : (isHovered ? 4 : 2),
              ),
            ],
            gradient: RadialGradient(
              colors: [
                AppColors.accent.withOpacity(
                  isActive ? 0.4 : (isHovered ? 0.3 : 0.2)
                ),
                Colors.transparent,
              ],
            ),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 24,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
