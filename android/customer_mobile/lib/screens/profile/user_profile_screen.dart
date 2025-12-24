import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/user_avatar.dart';

/// User Profile Page with tabs (Profile, Addresses, Security)
/// Now fully dynamic with AuthProvider data
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final fullName = user?['fullName'] ?? 'User';
        final email = user?['email'] ?? 'Not available';
        final phone = user?['phone'] ?? '';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: AppColors.surface,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Profile Header with  Avatar
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        UserAvatar(
                          name: fullName,
                          imageUrl: user?['avatarUrl'],
                          size: 80,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName, style: AppTextStyles.h2),
                              const SizedBox(height: 4),
                              Text(email, style: AppTextStyles.small),
                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(phone, style: AppTextStyles.small),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accent,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Addresses'),
                      Tab(text: 'Security'),
                    ],
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileTab(fullName, email, phone),
                        _buildAddressesTab(),
                        _buildSecurityTab(),
                      ],
                    ),
                  ),
                ],
              ),

              FloatingBottomNav(
                currentIndex: _currentNavIndex,
                onTap: (index) => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(String fullName, String email, String phone) {
    final nameController = TextEditingController(text: fullName);
    final phoneController = TextEditingController(text: phone);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      children: [
        _buildTextField('Full Name', nameController),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('Email', TextEditingController(text: email), enabled: false),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('Phone', phoneController),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement save changes
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Save functionality coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildAddressesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      children: [
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add address functionality coming soon!')),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add New Address'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Icon(Icons.location_on_outlined, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No saved addresses yet',
                  style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      children: [
        Text('Change Password', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        _buildTextField('Current Password', TextEditingController(), isPassword: true),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('New Password', TextEditingController(), isPassword: true),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('Confirm Password', TextEditingController(), isPassword: true),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change password functionality coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Update Password', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyEmphasized),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: !enabled,
            fillColor: enabled ? null : AppColors.baseOffWhite,
          ),
        ),
      ],
    );
  }
}
