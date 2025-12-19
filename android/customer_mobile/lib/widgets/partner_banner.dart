import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PartnerBanner extends StatefulWidget {
  const PartnerBanner({Key? key}) : super(key: key);

  @override
  State<PartnerBanner> createState() => _PartnerBannerState();
}

class _PartnerBannerState extends State<PartnerBanner> {
  bool _isVisible = true;
  bool _hasRestaurant = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkUserRestaurant();
  }

  Future<void> _checkUserRestaurant() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        setState(() {
          _isChecking = false;
        });
        return;
      }

      // Check if user has a restaurant
      final apiUrl = const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:3000',
      );
      
      // You'll need to implement this API call based on your backend
      // For now, we'll just set it to false
      setState(() {
        _hasRestaurant = false;
        _isChecking = false;
      });
    } catch (error) {
      print('User not authenticated or error checking restaurant: $error');
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide banner if:
    // - User dismissed it
    // - Still checking
    // - User already has a restaurant
    if (!_isVisible || _isChecking || _hasRestaurant) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/partner');
            },
            child: Text(
              'Become a Zhigo Partner',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isVisible = false;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
