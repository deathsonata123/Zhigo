import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/order.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final restaurantProvider = context.read<RestaurantProvider>();
    if (restaurantProvider.restaurant == null) {
      await restaurantProvider.loadRestaurant();
    }
    
    if (restaurantProvider.restaurant != null) {
      await context.read<OrderProvider>().loadOrders(
        restaurantProvider.restaurant!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _OrderList(
                orders: orderProvider.pendingOrders,
                type: OrderListType.pending,
              ),
              _OrderList(
                orders: orderProvider.activeOrders,
                type: OrderListType.active,
              ),
              _OrderList(
                orders: orderProvider.completedOrders,
                type: OrderListType.completed,
              ),
              _OrderList(
                orders: orderProvider.cancelledOrders,
                type: OrderListType.cancelled,
              ),
            ],
          );
        },
      ),
    );
  }
}

enum OrderListType { pending, active, completed, cancelled }

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final OrderListType type;

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
              'No orders',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final restaurantId = await context.read<RestaurantProvider>().restaurant?.id;
        if (restaurantId != null) {
          await context.read<OrderProvider>().loadOrders(restaurantId);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _OrderCard(order: orders[index], type: type);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final OrderListType type;

  const _OrderCard({required this.order, required this.type});

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
              color: _getStatusColor(order.status).withOpacity(0.1),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatRelativeTime(order.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(order.customerPhone),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.customerAddress)),
                  ],
                ),
                
                const Divider(height: 24),
                
                // Items
                _buildItems(),
                
                const Divider(height: 24),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                
                // Actions
                if (type == OrderListType.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectOrder(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _acceptOrder(context),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ] else if (type == OrderListType.active) ...[
                  const SizedBox(height: 16),
                  if (order.status == 'accepted')
                    FilledButton(
                      onPressed: () => _markPreparing(context),
                      child: const Text('Mark as Preparing'),
                    )
                  else if (order.status == 'preparing')
                    FilledButton(
                      onPressed: () => _markReady(context),
                      child: const Text('Mark as Ready'),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    try {
      final items = jsonDecode(order.items) as List;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item['quantity']}x ${item['name']}'),
                Text(CurrencyFormatter.format((item['price'] as num).toDouble())),
              ],
            ),
          )),
        ],
      );
    } catch (e) {
      return const Text('Items: N/A');
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _acceptOrder(BuildContext context) async {
    final prepTime = await showDialog<int>(
      context: context,
      builder: (context) => _PrepTimeDialog(),
    );
    
    if (prepTime != null && context.mounted) {
      final orderProvider = context.read<OrderProvider>();
      final success = await orderProvider.acceptOrder(order.id, prepTime);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Order accepted' : 'Failed to accept order')),
        );
      }
    }
  }

  Future<void> _rejectOrder(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectReasonDialog(),
    );
    
    if (reason != null && context.mounted) {
      final orderProvider = context.read<OrderProvider>();
      final success = await orderProvider.rejectOrder(order.id, reason);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Order rejected' : 'Failed to reject order')),
        );
      }
    }
  }

  Future<void> _markPreparing(BuildContext context) async {
    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.markPreparing(order.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Order marked as preparing' : 'Failed to update order')),
      );
    }
  }

  Future<void> _markReady(BuildContext context) async {
    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.markReady(order.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Order marked as ready' : 'Failed to update order')),
      );
    }
  }
}

class _PrepTimeDialog extends StatefulWidget {
  @override
  State<_PrepTimeDialog> createState() => _PrepTimeDialogState();
}

class _PrepTimeDialogState extends State<_PrepTimeDialog> {
  int _prepTime = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accept Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Estimated preparation time:'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setState(() => _prepTime = (_prepTime - 5).clamp(10, 120)),
              ),
              Text(
                '$_prepTime minutes',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _prepTime = (_prepTime + 5).clamp(10, 120)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _prepTime),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  String? _selectedReason;
  final List<String> _reasons = [
    'Restaurant is too busy',
    'Item unavailable',
    'Delivery area too far',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select a reason:'),
          const SizedBox(height: 16),
          ..._reasons.map((reason) => RadioListTile<String>(
            title: Text(reason),
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) => setState(() => _selectedReason = value),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () => Navigator.pop(context, _selectedReason),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
