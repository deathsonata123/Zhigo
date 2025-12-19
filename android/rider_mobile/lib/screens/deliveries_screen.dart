import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/delivery_provider.dart';
import '../models/order.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
      ),
      body: deliveryProvider.isLoading && deliveryProvider.deliveries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => deliveryProvider.fetchDeliveries(),
              child: deliveryProvider.deliveries.isEmpty
                  ? const Center(child: Text('No deliveries'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: deliveryProvider.deliveries.length,
                      itemBuilder: (context, index) {
                        return _DeliveryCard(delivery: deliveryProvider.deliveries[index]);
                      },
                    ),
            ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Order delivery;

  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.id?.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  label: Text(delivery.status.toUpperCase()),
                  backgroundColor: _getStatusColor(delivery.status).withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${delivery.items.length} items • \$${delivery.total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            if (delivery.status == 'ready')
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<DeliveryProvider>().updateStatus(delivery.id!, 'in_transit');
                      },
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Pick Up'),
                    ),
                  ),
                ],
              )
            else if (delivery.status == 'in_transit')
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<DeliveryProvider>().updateStatus(delivery.id!, 'delivered');
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Delivered'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ready':
        return Colors.blue;
      case 'in_transit':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
