import 'package:flutter/material.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  final List<Map<String, String>> _campaigns = [
    {
      'name': 'Free Delivery Bonanza',
      'description': 'Attract more customers by offering free delivery on all orders.',
      'cost': '5% commission on campaign orders',
    },
    {
      'name': '20% Off Weekend Special',
      'description': 'Boost your weekend sales with a flat 20% discount.',
      'cost': 'Funded by you',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketing & Promotions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Platform campaigns
          Text(
            'Available Campaigns',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...(_campaigns.map((campaign) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          campaign['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(campaign['description']!),
                  const SizedBox(height: 8),
                  Text(
                    'Cost: ${campaign['cost']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Joined ${campaign['name']}')),
                      );
                    },
                    child: const Text('Join Campaign'),
                  ),
                ],
              ),
            ),
          ))),
          
          const SizedBox(height: 24),
          
          // Create custom promotion
          Text(
            'Create Custom Promotion',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Promotion Name',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Lunch Deal',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Discount Type',
                            border: OutlineInputBorder(),
                            hintText: 'Percentage',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Value',
                            border: OutlineInputBorder(),
                            hintText: '15',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Minimum Order Value (Optional)',
                      border: OutlineInputBorder(),
                      hintText: '500',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Activate Promotion'),
                    subtitle: const Text('Make this promotion visible to customers'),
                    value: false,
                    onChanged: (value) {
                      // Handle toggle
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Promotion created successfully')),
                      );
                    },
                    child: const Text('Create Promotion'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Performance stats
          Text(
            'Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatRow(
                    label: 'Orders from Promotions',
                    value: '124',
                  ),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: 'Sales from Promotions',
                    value: '\$2,480.00',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
