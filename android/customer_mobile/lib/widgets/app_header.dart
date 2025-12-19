import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/login_dialog.dart';
import '../widgets/partner_banner.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;
  final bool showProfile;
  final List<Widget>? actions;
  final bool showPartnerBanner;

  const AppHeader({
    super.key,
    required this.title,
    this.showCart = true,
    this.showProfile = true,
    this.actions,
    this.showPartnerBanner = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (showPartnerBanner ? 48 : 0),
  );

  String _getInitial(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) return 'G';
    final userName = authProvider.user?.name;
    if (userName == null || userName.isEmpty) return 'U';
    return userName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();

    final appBar = AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        if (actions != null) ...actions!,
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              // Badge for notifications (placeholder)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        // Cart
        if (showCart)
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              if (cartProvider.itemCount > 0) {
                Navigator.pushNamed(context, '/checkout');
              }
            },
          ),
        // Profile
        if (showProfile)
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _getInitial(authProvider),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'login':
                  showDialog(
                    context: context,
                    builder: (context) => const LoginDialog(),
                  );
                  break;
                case 'logout':
                  authProvider.signOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (authProvider.isAuthenticated) ...[
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Text(authProvider.user?.name ?? 'Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ] else
                const PopupMenuItem(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text('Login'),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );

    if (showPartnerBanner) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PartnerBanner(),
          appBar,
        ],
      );
    }

    return appBar;
  }
}
