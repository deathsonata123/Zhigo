import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rider_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: Consumer<RiderProvider>(
        builder: (context, provider, _) {
          final rider = provider.rider;
          final completedOrders = provider.orders.where((o) => o.status == 'delivered').toList();

          final totalEarnings = completedOrders.fold<double>(
            0,
            (sum, order) => sum + (order.total * 0.1) + order.tip, // 10% base fee + tip
          );

          final totalTips = completedOrders.fold<double>(
            0,
            (sum, order) => sum + order.tip,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total Earnings Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(rider?.totalEarnings ?? 0),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Deliveries',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${rider?.totalDeliveries ?? 0}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Tips',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(totalTips),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (completedOrders.isNotEmpty) ...[
                Text(
                  'Recent Completions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...completedOrders.take(10).map((order) {
                  final earning = (order.total * 0.1) + order.tip;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.check, color: Colors.green),
                      ),
                      title: Text(order.restaurantName),
                      subtitle: Text(DateFormatter.formatRelativeTime(order.deliveredAt!)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(earning),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (order.tip > 0)
                            Text(
                              '+${CurrencyFormatter.format(order.tip)} tip',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.attach_money, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No earnings yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete deliveries to start earning',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
