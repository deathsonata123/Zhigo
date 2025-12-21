import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rider_provider.dart';
import '../../models/delivery_order.dart';
import '../../utils/date_formatter.dart';
import '../../utils/currency_formatter.dart';
import 'dart:convert';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    await context.read<RiderProvider>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Consumer<RiderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeOrders = provider.orders.where((o) =>
            ['assigned', 'at_restaurant', 'picked_up', 'delivering'].contains(o.status)
          ).toList();

          final completedOrders = provider.orders.where((o) =>
            o.status == 'delivered'
          ).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _OrderList(orders: activeOrders, type: 'active'),
              _OrderList(orders: completedOrders, type: 'completed'),
            ],
          );
        },
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<DeliveryOrder> orders;
  final String type;

  const _OrderList({required this.orders, required this.type});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No $type deliveries',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RiderProvider>().loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliveryOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatRelativeTime(order.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant
                Row(
                  children: [
                    const Icon(Icons.store, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customer
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deliver to', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(order.customerAddress, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      CurrencyFormatter.format(order.total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                if (order.tip > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tip',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        CurrencyFormatter.format(order.tip),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
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
