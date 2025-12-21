import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/floating_bottom_nav.dart';

/// User Profile Page with tabs (Profile, Addresses, Security)
/// Simplified version of web profile
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
              // Profile Header
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('John Doe', style: AppTextStyles.h2),
                          const SizedBox(height: 4),
                          Text('john@example.com', style: AppTextStyles.small),
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
                    _buildProfileTab(),
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
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      children: [
        _buildTextField('Full Name', 'John Doe'),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('Email', 'john@example.com', enabled: false),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('Phone', '+880 1234567890'),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
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
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildAddressCard('Home', '123 Main St, Dhaka', isDefault: true),
        _buildAddressCard('Work', '456 Office Ave, Dhaka'),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      children: [
        Text('Change Password', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        _buildTextField('Current Password', '', isPassword: true),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('New Password', '', isPassword: true),
        const SizedBox(height: AppSpacing.sm),
        _buildTextField('Confirm Password', '', isPassword: true),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text('Update Password', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {bool enabled = true, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyEmphasized),
        const SizedBox(height: 4),
        TextField(
          enabled: enabled,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: !enabled,
            fillColor: enabled ? null : AppColors.baseOffWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(String label, String address, {bool isDefault = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDefault ? AppColors.accent.withOpacity(0.1) : AppColors.surface,
        border: Border.all(color: isDefault ? AppColors.accent : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: isDefault ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTextStyles.bodyEmphasized),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: AppTextStyles.small),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
