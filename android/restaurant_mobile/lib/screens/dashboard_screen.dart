import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/menu_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _period = 'this-month';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        // In real app, get restaurant ID from user's restaurants
        context.read<OrderProvider>().setRestaurantId('1'); // TODO: Dynamic
        context.read<MenuProvider>().setRestaurantId('1');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final menuProvider = context.watch<MenuProvider>();
    final stats = orderProvider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _period = value;
              });
              context.read<OrderProvider>().fetchStats(period: value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'this-week', child: Text('This Week')),
              const PopupMenuItem(value: 'this-month', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: orderProvider.isLoading && stats.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  orderProvider.fetchOrders(),
                  orderProvider.fetchStats(period: _period),
                  menuProvider.fetchMenuItems(),
                ]);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Total Orders',
                          value: '${stats['totalOrders'] ?? orderProvider.orders.length}',
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Revenue',
                          value: '\$${(stats['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Pending',
                          value: '${orderProvider.pendingOrders.length}',
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Menu Items',
                          value: '${menuProvider.menuItems.length}',
                          icon: Icons.restaurant_menu,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Orders
                    const Text(
                      'Recent Orders',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (orderProvider.orders.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No orders yet')),
                        ),
                      )
                    else
                      ...orderProvider.orders.take(5).map((order) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(order.status),
           child: Icon(
                                _getStatusIcon(order.status),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text('Order #${order.id?.substring(0, 8)}'),
                            subtitle: Text(
                              '${order.items.length} items • \$${order.total.toStringAsFixed(2)}',
                            ),
                            trailing: Chip(
                              label: Text(
                                order.status.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: _getStatusColor(order.status).withOpacity(0.2),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'preparing':
        return Icons.restaurant;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
