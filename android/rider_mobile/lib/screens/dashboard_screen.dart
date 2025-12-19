import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/delivery_provider.dart';
import '../providers/auth_provider.dart';
import '../models/delivery_request.dart';
import '../widgets/delivery_request_dialog.dart';
import 'active_delivery_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOnline = false;
  Position? _currentPosition;
  List<DeliveryRequest> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadRiderStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<DeliveryProvider>().setRiderId('1'); // TODO: Dynamic from user
        _startPollingForRequests();
      }
    });
  }

  Future<void> _loadRiderStatus() async {
    // Load saved online/offline status
    setState(() {
      _isOnline = false; // Default offline
    });
  }

  Future<void> _toggleOnlineStatus() async {
    if (!_isOnline) {
      // Going online - request location permission
      final permission = await Permission.locationWhenInUse.request();
      if (permission.isGranted) {
        await _startLocationTracking();
        setState(() => _isOnline = true);
        _showSnackBar('You are now online', Colors.green);
      } else {
        _showSnackBar('Location permission required', Colors.red);
        return;
      }
    } else {
      // Going offline
      setState(() => _isOnline = false);
      _showSnackBar('You are now offline', Colors.orange);
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      // Start watching position
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
        });
        // TODO: Send location to backend
        print('Location updated: ${position.latitude}, ${position.longitude}');
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startPollingForRequests() {
    // Poll for new delivery requests every 5 seconds when online
    Future.doWhile(() async {
      if (!mounted) return false;
      
      if (_isOnline) {
        await _checkForNewRequests();
      }
      
      await Future.delayed(const Duration(seconds: 5));
      return mounted;
    });
  }

  Future<void> _checkForNewRequests() async {
    // TODO: Call API to check for new delivery requests
    // For now, simulate with empty list
    final newRequests = <DeliveryRequest>[];
    
    if (newRequests.isNotEmpty && newRequests.length > _pendingRequests.length) {
      setState(() {
        _pendingRequests = newRequests;
      });
      // Show popup for newest request
      _showDeliveryRequestDialog(newRequests.first);
    }
  }

  void _showDeliveryRequestDialog(DeliveryRequest request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeliveryRequestDialog(
        request: request,
        onAccept: _acceptDeliveryRequest,
        onDecline: _declineDeliveryRequest,
      ),
    );
  }

  Future<void> _acceptDeliveryRequest(DeliveryRequest request) async {
    // TODO: Call API to accept delivery
    _showSnackBar('Delivery accepted!', Colors.green);
    // Refresh deliveries
    await context.read<DeliveryProvider>().fetchDeliveries();
  }

  Future<void> _declineDeliveryRequest(DeliveryRequest request) async {
    // TODO: Call API to decline delivery
    _showSnackBar('Delivery declined', Colors.orange);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final earnings = deliveryProvider.earnings;
    final activeDelivery = deliveryProvider.activeDeliveries.isNotEmpty
        ? deliveryProvider.activeDeliveries.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        actions: [
          // Online/Offline Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isOnline,
                  onChanged: (_) => _toggleOnlineStatus(),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: activeDelivery != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveDeliveryMapScreen(
                      delivery: activeDelivery,
                      onArrivedAtRestaurant: () async {
                        // TODO: Update status
                        await deliveryProvider.fetchDeliveries();
                        if (mounted) Navigator.pop(context);
                      },
                      onConfirmPickup: () async {
                        await deliveryProvider.fetchDeliveries();
                        if (mounted) Navigator.pop(context);
                      },
                      onArrivedAtCustomer: () async {
                        await deliveryProvider.fetchDeliveries();
                        if (mounted) Navigator.pop(context);
                      },
                      onCompleteDelivery: () async {
                        await deliveryProvider.fetchDeliveries();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('View Active Delivery'),
              backgroundColor: Colors.cyan,
            )
          : null,
      body: deliveryProvider.isLoading && deliveryProvider.deliveries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  deliveryProvider.fetchDeliveries(),
                  deliveryProvider.fetchEarnings(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Online Status Card
                    if (_isOnline)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'You\'re online!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Live tracking active${_currentPosition != null ? " • ${_pendingRequests.length} pending requests" : ""}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Turn online to receive delivery requests',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Active',
                          value: '${deliveryProvider.activeDeliveries.length}',
                          icon: Icons.delivery_dining,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Completed',
                          value: '${deliveryProvider.completedDeliveries.length}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Today Earnings',
                          value: 'Tk ${(earnings['today'] ?? 0).toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Total Earnings',
                          value: 'Tk ${(earnings['total'] ?? 0).toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Active or Pending Deliveries
                    if (activeDelivery != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Delivery',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: Colors.blue),
                                SizedBox(width: 4),
                                Text(
                                  'In Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delivery_dining, color: Colors.blue),
                          ),
                          title: Text('Order #${activeDelivery.id?.substring(0, 8)}'),
                          subtitle: Text('Tk ${activeDelivery.total.toStringAsFixed(2)}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActiveDeliveryMapScreen(
                                  delivery: activeDelivery,
                                  onArrivedAtRestaurant: () async {
                                    await deliveryProvider.fetchDeliveries();
                                    if (mounted) Navigator.pop(context);
                                  },
                                  onConfirmPickup: () async {
                                    await deliveryProvider.fetchDeliveries();
                                    if (mounted) Navigator.pop(context);
                                  },
                                  onArrivedAtCustomer: () async {
                                    await deliveryProvider.fetchDeliveries();
                                    if (mounted) Navigator.pop(context);
                                  },
                                  onCompleteDelivery: () async {
                                    await deliveryProvider.fetchDeliveries();
                                    if (mounted) Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else if (_isOnline && _pendingRequests.isEmpty) ...[
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.delivery_dining, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No delivery requests',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Popup will appear when a new order arrives',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
