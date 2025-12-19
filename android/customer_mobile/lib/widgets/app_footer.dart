import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Partner Banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Restaurant Owner?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Join thousands of partners growing with Zhigo',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/partner-onboarding');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange,
                  ),
                  child: const Text('Become a Partner'),
                ),
              ],
            ),
          ),
          // Links
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Navigate to About page
                },
                child: const Text('About Us'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Terms page
                },
                child: const Text('Terms of Service'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Privacy page
                },
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Contact page
                },
                child: const Text('Contact Us'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Social Media Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.facebook),
                onPressed: () {
                  // TODO: Open Facebook
                },
                tooltip: 'Facebook',
              ),
              IconButton(
                icon: const Icon(Icons.email),
                onPressed: () {
                  // TODO: Open Twitter
                },
                tooltip: 'Twitter',
              ),
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // TODO: Open Instagram
                },
                tooltip: 'Instagram',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Copyright
          Text(
            '© ${DateTime.now().year} Zhigo. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
