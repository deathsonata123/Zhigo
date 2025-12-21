import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/dashboard_stats.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../services/restaurant_service.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  DashboardStats _stats = DashboardStats.empty();
  List<TopMenuItem> _topItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<RestaurantProvider>();
    await provider.loadRestaurant();
    await provider.loadOrders();
    
    if (provider.restaurant != null) {
      await _calculateStats(provider);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _calculateStats(RestaurantProvider provider) async {
    final orders = provider.orders;
    final restaurantId = provider.restaurant!.id;
    
    // Get additional data
    final reviews = await _restaurantService.getReviews(restaurantId);
    final riders = await _restaurantService.getRiders(status: 'approved');
    final menuItems = await _restaurantService.getMenuItems(restaurantId);
    
    // Calculate stats
    final totalRevenue = orders.fold<double>(0, (sum, o) => sum + o.total);
    final commission = totalRevenue * 0.15;
    final netRevenue = totalRevenue - commission;
    
    final pending = orders.where((o) => o.status == 'pending').length;
    final preparing = orders.where((o) => 
      ['accepted', 'preparing', 'ready'].contains(o.status)).length;
    final delivered = orders.where((o) => o.status == 'delivered').length;
    final cancelled = orders.where((o) => 
      ['rejected', 'cancelled'].contains(o.status)).length;
    
    final avgRating = reviews.isNotEmpty
        ? reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length
        : 0.0;
    
    final acceptanceRate = orders.isNotEmpty
        ? ((orders.length - cancelled) / orders.length * 100).round()
        : 0;

    // Calculate top items
    final itemMap = <String, TopMenuItem>{};
    for (final order in orders) {
      try {
        final items = jsonDecode(order.items) as List;
        for (final item in items) {
          final name = item['name'] as String;
          final quantity = item['quantity'] as int? ?? 1;
          final price = (item['price'] as num).toDouble();
          final revenue = price * quantity;
          
          if (itemMap.containsKey(name)) {
            final existing = itemMap[name]!;
            itemMap[name] = TopMenuItem(
              name: name,
              quantity: existing.quantity + quantity,
              revenue: existing.revenue + revenue,
            );
          } else {
            itemMap[name] = TopMenuItem(
              name: name,
              quantity: quantity,
              revenue: revenue,
            );
          }
        }
      } catch (e) {
        // Skip if JSON parsing fails
      }
    }
    
    setState(() {
      _stats = DashboardStats(
        totalOrders: orders.length,
        totalRevenue: totalRevenue,
        pendingOrders: pending,
        preparingOrders: preparing,
        deliveredOrders: delivered,
        cancelledOrders: cancelled,
        avgDeliveryTime: 35, // Placeholder
        acceptanceRate: acceptanceRate,
        avgRating: avgRating,
        commission: commission,
        netRevenue: netRevenue,
        activeRiders: riders.length,
        totalMenuItems: menuItems.length,
        availableMenuItems: menuItems.where((m) => m.isAvailable).length,
      );
      
      _topItems = itemMap.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
      if (_topItems.length > 5) {
        _topItems = _topItems.sublist(0, 5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _StatCard(
                        title: 'Total Orders',
                        value: '${_stats.totalOrders}',
                        subtitle: '${_stats.deliveredOrders} delivered',
                        icon: Icons.shopping_bag,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        title: 'Revenue',
                        value: CurrencyFormatter.formatWhole(_stats.totalRevenue),
                        subtitle: 'Net: ${CurrencyFormatter.formatWhole(_stats.netRevenue)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      _StatCard(
                        title: 'Active Riders',
                        value: '${_stats.activeRiders}',
                        subtitle: 'Online now',
                        icon: Icons.delivery_dining,
                        color: Colors.orange,
                      ),
                      _StatCard(
                        title: 'Rating',
                        value: _stats.avgRating > 0 ? '${_stats.avgRating.toStringAsFixed(1)}/5' : 'N/A',
                        subtitle: '${_stats.acceptanceRate}% acceptance',
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Pending Orders
                  if (_stats.pendingOrders > 0) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.pending_actions, color: Colors.orange),
                        title: const Text('Pending Orders'),
                        subtitle: Text('${_stats.pendingOrders} orders awaiting action'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to orders tab
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Top Selling Items
                  Text(
                    'Top Selling Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_topItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No sales data available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    )
                  else
                    ...(_topItems.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            '${_topItems.indexOf(item) + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} sold'),
                        trailing: Text(
                          CurrencyFormatter.format(item.revenue),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ))),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
