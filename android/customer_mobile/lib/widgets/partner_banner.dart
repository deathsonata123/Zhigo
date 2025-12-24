import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../screens/partner/partner_onboarding_screen.dart';
import '../providers/auth_provider.dart';

/// Partner Banner - "Become a Zhigo Partner"
/// Dismissible banner at top of screen
/// Hidden if user is already a partner
class PartnerBanner extends StatefulWidget {
  const PartnerBanner({super.key});

  @override
  State<PartnerBanner> createState() => _PartnerBannerState();
}

class _PartnerBannerState extends State<PartnerBanner> {
  bool _isVisible = true;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Hide banner if user is a partner (role == 'partner' or has a restaurant)
        final userRole = auth.user?['role'] as String?;
        if (userRole == 'partner' || userRole == 'restaurant_owner') {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMarginHorizontal,
            vertical: 6,
          ),
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Centered text with cursor effect
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PartnerOnboardingScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Become a Zhigo Partner',
                      style: TextStyle(
                        color: _isHovered ? AppColors.accent.withOpacity(0.8) : AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                right: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.accent.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
