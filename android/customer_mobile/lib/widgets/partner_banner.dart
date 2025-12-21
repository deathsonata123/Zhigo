import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../screens/partner/partner_onboarding_screen.dart';

/// Partner Banner - "Become a Zhigo Partner"
/// Dismissible banner at top of screen
class PartnerBanner extends StatefulWidget {
  const PartnerBanner({super.key});

  @override
  State<PartnerBanner> createState() => _PartnerBannerState();
}

class _PartnerBannerState extends State<PartnerBanner> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenMarginHorizontal,
        vertical: 6, // Minimal padding
      ),
      color: Colors.transparent, // Transparent background
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered text
          Center(
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
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          // Close button (positioned right)
          Positioned(
            right: 0,
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
        ],
      ),
    );
  }
}
