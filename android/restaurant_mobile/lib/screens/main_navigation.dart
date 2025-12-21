import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'orders/orders_screen.dart';
import 'menu/menu_management_screen.dart';
import 'analytics/analytics_screen.dart';
import 'reviews/reviews_screen.dart';
import 'hours/hours_management_screen.dart';
import 'marketing/marketing_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _screens = [
    {'title': 'Dashboard', 'icon': Icons.dashboard, 'screen': const DashboardScreen()},
    {'title': 'Orders', 'icon': Icons.receipt_long, 'screen': const OrdersScreen()},
    {'title': 'Menu', 'icon': Icons.restaurant_menu, 'screen': const MenuManagementScreen()},
    {'title': 'Analytics', 'icon': Icons.analytics, 'screen': const AnalyticsScreen()},
    {'title': 'Reviews', 'icon': Icons.star, 'screen': const ReviewsScreen()},
    {'title': 'Hours', 'icon': Icons.access_time, 'screen': const HoursManagementScreen()},
    {'title': 'Marketing', 'icon': Icons.campaign, 'screen': const MarketingScreen()},
    {'title': 'Settings', 'icon': Icons.settings, 'screen': const SettingsScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screens[_currentIndex]['title']),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Restaurant Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(_screens.length, (index) {
              final screen = _screens[index];
              return ListTile(
                leading: Icon(screen['icon'] as IconData),
                title: Text(screen['title']),
                selected: _currentIndex == index,
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
      body: _screens[_currentIndex]['screen'] as Widget,
    );
  }
}
