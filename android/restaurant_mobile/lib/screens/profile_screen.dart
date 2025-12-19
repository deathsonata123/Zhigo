import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please login to view profile'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      // TODO: Navigate to login screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login screen not implemented yet')),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Text(user.name?.substring(0, 1).toUpperCase() ?? 'U'),
                    ),
                    title: Text(user.name ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(user.email),
                  ),
                  const Divider(height: 32),

                  // Menu Items
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Order History'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to order history
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Addresses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),
                  const Spacer(),

                  // Logout Button
                  FilledButton(
                    onPressed: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
