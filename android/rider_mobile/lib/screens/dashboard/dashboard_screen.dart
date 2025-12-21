import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rider_provider.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<RiderProvider>().loadRiderData();
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
      body: Consumer<RiderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rider = provider.rider;
          if (rider == null) {
            return const Center(child: Text('No rider profile found'));
          }

          if (rider.status != 'approved') {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending, size: 64, color: Colors.orange[700]),
                      const SizedBox(height: 16),
                      const Text(
                        'Account Pending Approval',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your rider account is being reviewed.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome card
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(
                            rider.fullName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${rider.fullName}!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rider.zone != null)
                                Text(
                                  'Zone: ${rider.zone}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Online/Offline Toggle
                Card(
                  child: SwitchListTile(
                    title: const Text('Online Status'),
                    subtitle: Text(
                      rider.isOnline ? 'You are online and can receive deliveries' : 'Go online to receive deliveries',
                    ),
                    value: rider.isOnline,
                    onChanged: (value) async {
                      await provider.toggleOnlineStatus(value);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Stats
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _StatCard(
                      title: 'Total Deliveries',
                      value: '${rider.totalDeliveries}',
                      icon: Icons.delivery_dining,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Total Earnings',
                      value: CurrencyFormatter.formatWhole(rider.totalEarnings),
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Status',
                      value: rider.isOnline ? 'Online' : 'Offline',
                      icon: rider.isOnline ? Icons.check_circle : Icons.cancel,
                      color: rider.isOnline ? Colors.green : Colors.grey,
                    ),
                    _StatCard(
                      title: 'Account',
                      value: rider.status,
                      icon: Icons.verified_user,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current Delivery
                if (provider.currentOrder != null) ...[
                  Text(
                    'Current Delivery',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CurrentDeliveryCard(order: provider.currentOrder!),
                ] else if (rider.isOnline) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.delivery_dining, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No active delivery',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Waiting for new orders...',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Turn online to start receiving delivery requests'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentDeliveryCard extends StatelessWidget {
  final dynamic order;

  const _CurrentDeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.restaurantName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 8),
                Text(order.customerName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(order.customerAddress)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${CurrencyFormatter.format(order.total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final provider = context.read<RiderProvider>();
                    String nextStatus = '';
                    
                    if (order.status == 'assigned') {
nextStatus = 'at_restaurant';
                    } else if (order.status == 'at_restaurant') {
                      nextStatus = 'picked_up';
                    } else if (order.status == 'picked_up') {
                      nextStatus = 'delivering';
                    } else if (order.status == 'delivering') {
                      nextStatus = 'delivered';
                    }
                    
                    if (nextStatus.isNotEmpty) {
                      await provider.updateDeliveryStatus(order.id, nextStatus);
                    }
                  },
                  child: Text(_getNextActionText(order.status)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getNextActionText(String status) {
    switch (status) {
      case 'assigned':
        return 'At Restaurant';
      case 'at_restaurant':
        return 'Picked Up';
      case 'picked_up':
        return 'Delivering';
      case 'delivering':
        return 'Complete';
      default:
        return 'Update';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.blue;
      case 'at_restaurant':
      case 'picked_up':
        return Colors.orange;
      case 'delivering':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
