import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../screens/partner/partner_onboarding_screen.dart';

/// App Footer - Main footer with company info and links
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.screenMarginHorizontal,
        right: AppSpacing.screenMarginHorizontal,
        top: AppSpacing.sectionSpacing,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _buildDesktopFooter(context);
          } else {
            return _buildMobileFooter(context);
          }
        },
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Tagline
            Expanded(
              child: _buildLogoSection(),
            ),
            
            // Company
            Expanded(
              child: _buildLinkSection(context, 'Company', [
                {'label': 'About Us', 'route': '/about'},
                {'label': 'Careers', 'route': '/careers'},
                {'label': 'Press', 'route': '/press'},
              ]),
            ),
            
            // Partnerships (removed "Become a Developer")
            Expanded(
              child: _buildLinkSection(context, 'Partnerships', [
                {'label': 'Become a Zhigo Partner', 'route': '/partner'},
                {'label': 'Become a Rider', 'route': '/rider-signup'},
              ]),
            ),
            
            // Help
            Expanded(
              child: _buildLinkSection(context, 'Help', [
                {'label': 'Contact Us', 'route': '/contact'},
                {'label': 'FAQs', 'route': '/faqs'},
              ]),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionSpacing),
        const Divider(color: AppColors.border),
        const SizedBox(height: AppSpacing.sm),
        _buildCopyright(),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogoSection(),
        const SizedBox(height: AppSpacing.md),
        _buildLinkSection(context, 'Company', [
          {'label': 'About Us', 'route': '/about'},
          {'label': 'Careers', 'route': '/careers'},
          {'label': 'Press', 'route': '/press'},
        ]),
        const SizedBox(height: AppSpacing.md),
        // Removed "Become a Developer"
        _buildLinkSection(context, 'Partnerships', [
          {'label': 'Become a Zhigo Partner', 'route': '/partner'},
          {'label': 'Become a Rider', 'route': '/rider-signup'},
        ]),
        const SizedBox(height: AppSpacing.md),
        _buildLinkSection(context, 'Help', [
          {'label': 'Contact Us', 'route': '/contact'},
          {'label': 'FAQs', 'route': '/faqs'},
        ]),
        const SizedBox(height: AppSpacing.md),
        const Divider(color: AppColors.border),
        const SizedBox(height: AppSpacing.sm),
        _buildCopyright(),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Zhigo',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your favorite food, delivered.',
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkSection(BuildContext context, String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyEmphasized.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // Handle partner link specially
                if (link['route'] == '/partner') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PartnerOnboardingScreen(),
                    ),
                  );
                }
                // Other routes can be added as needed
              },
              child: Text(
                link['label']!,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCopyright() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} Zhigo. All rights reserved.',
        style: AppTextStyles.small.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
