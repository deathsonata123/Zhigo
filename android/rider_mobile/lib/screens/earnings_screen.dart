import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/delivery_provider.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = 'this-month';

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final earnings = deliveryProvider.earnings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _period = value;
              });
              context.read<DeliveryProvider>().fetchEarnings(period: value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'this-week', child: Text('This Week')),
              const PopupMenuItem(value: 'this-month', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Total Earnings',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${(earnings['total'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _EarningCard(
                  title: 'Today',
                  amount: '\$${(earnings['today'] ?? 0).toStringAsFixed(2)}',
                  color: Colors.blue,
                ),
                _EarningCard(
                  title: 'This Week',
                  amount: '\$${(earnings['week'] ?? 0).toStringAsFixed(2)}',
                  color: Colors.purple,
                ),
                _EarningCard(
                  title: 'This Month',
                  amount: '\$${(earnings['month'] ?? 0).toStringAsFixed(2)}',
                  color: Colors.orange,
                ),
                _EarningCard(
                  title: 'Deliveries',
                  amount: '${earnings['deliveries'] ?? 0}',
                  color: Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Payouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No payouts yet')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _EarningCard({
    required this.title,
    required this.amount,
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
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              amount,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
