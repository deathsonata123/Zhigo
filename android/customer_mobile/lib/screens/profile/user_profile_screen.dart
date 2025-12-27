import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

// Foodpanda colors
class _FoodpandaColors {
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFFFF5F2);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey900 = Color(0xFF212121);
  static const Color background = Color(0xFFF8F8F8);
}

/// Profile Screen - Clean minimal design
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
              ),
              
              // User Card
              _UserInfoCard(
                name: 'Jane',
                email: 'jane.doe@email.com',
                onEdit: () {
                  // TODO: Navigate to edit profile
                },
              ),
              
              const SizedBox(height: 16),
              
              // Menu Items Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _MenuItem(
                      title: 'Past Orders',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PastOrdersScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _MenuItem(
                      title: 'Payment Methods',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PaymentMethodsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _MenuItem(
                      title: 'Saved Addresses',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SavedAddressesScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _MenuItem(
                      title: 'Help Center',
                      onTap: () {
                        // TODO: Navigate to help center
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Log Out
              Center(
                child: _LogoutButton(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// User Info Card
class _UserInfoCard extends StatefulWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;

  const _UserInfoCard({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  @override
  State<_UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.name}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 15,
                    color: _FoodpandaColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onEdit,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 15,
                  color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
                  fontWeight: FontWeight.w500,
                ),
                child: const Text('Edit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Menu Item
class _MenuItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          color: _isHovered ? _FoodpandaColors.grey100 : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _FoodpandaColors.grey900,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _FoodpandaColors.grey500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Logout Button
class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 16,
            color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
            fontWeight: FontWeight.w500,
          ),
          child: const Text('Log Out'),
        ),
      ),
    );
  }
}

// ==================== Past Orders Screen ====================

class PastOrdersScreen extends StatelessWidget {
  const PastOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'restaurant': 'Pizza Palace',
        'date': 'Nov 10, 2025',
        'price': 28.98,
        'items': 'Margherita Pizza, Caesar Salad, and 2 more items...',
      },
      {
        'restaurant': 'The Corner Grocery',
        'date': 'Nov 8, 2025',
        'price': 72.15,
        'items': 'Organic Avocados, Sourdough Bread, and 5 more items...',
      },
      {
        'restaurant': 'Sushi Station',
        'date': 'Nov 5, 2025',
        'price': 45.50,
        'items': 'Spicy Tuna Roll, Salmon Nigiri, and 1 more item...',
      },
    ];

    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _ScreenHeader(
              title: 'Past Orders',
              onBack: () => Navigator.of(context).pop(),
            ),
            
            // Orders List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderCard(
                    restaurant: order['restaurant'] as String,
                    date: order['date'] as String,
                    price: order['price'] as double,
                    items: order['items'] as String,
                    onReorder: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reordering from ${order['restaurant']}...'),
                          backgroundColor: _FoodpandaColors.coral,
                        ),
                      );
                    },
                    onViewReceipt: () {
                      // TODO: Show receipt
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String restaurant;
  final String date;
  final double price;
  final String items;
  final VoidCallback onReorder;
  final VoidCallback onViewReceipt;

  const _OrderCard({
    required this.restaurant,
    required this.date,
    required this.price,
    required this.items,
    required this.onReorder,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$date • \$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: _FoodpandaColors.grey500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            items,
            style: TextStyle(
              fontSize: 14,
              color: _FoodpandaColors.grey600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SmallButton(
                text: 'Re-order',
                filled: true,
                onTap: onReorder,
              ),
              const SizedBox(width: 16),
              _SmallButton(
                text: 'View Receipt',
                filled: false,
                onTap: onViewReceipt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Payment Methods Screen ====================

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _methods = [
    {'type': 'visa', 'display': 'Visa •••• 4242', 'icon': Icons.credit_card},
    {'type': 'bkash', 'display': 'bKash', 'subtitle': '017...123', 'icon': Icons.phone_android},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _ScreenHeader(
              title: 'Payment Methods',
              onBack: () => Navigator.of(context).pop(),
            ),
            
            // Methods Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved Methods',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _FoodpandaColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._methods.asMap().entries.map((entry) {
                        final index = entry.key;
                        final method = entry.value;
                        return Column(
                          children: [
                            _PaymentMethodItem(
                              icon: method['icon'] as IconData,
                              title: method['display'] as String,
                              subtitle: method['subtitle'] as String?,
                              onRemove: () {
                                setState(() {
                                  _methods.removeAt(index);
                                });
                              },
                            ),
                            if (index < _methods.length - 1)
                              const Divider(height: 24),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Add Button
            _BottomButton(
              text: 'Add New Method',
              onTap: () {
                // TODO: Add new payment method
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onRemove;

  const _PaymentMethodItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onRemove,
  });

  @override
  State<_PaymentMethodItem> createState() => _PaymentMethodItemState();
}

class _PaymentMethodItemState extends State<_PaymentMethodItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 32,
          decoration: BoxDecoration(
            color: _FoodpandaColors.grey100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 20, color: _FoodpandaColors.grey600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _FoodpandaColors.grey900,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _FoodpandaColors.grey500,
                  ),
                ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Text(
              'Remove',
              style: TextStyle(
                fontSize: 14,
                color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Saved Addresses Screen ====================

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {'type': 'Home', 'address': '123 Main Street, Dhaka', 'icon': Icons.home_outlined},
    {'type': 'Work', 'address': '456 Office Ave, Gulshan', 'icon': Icons.work_outline},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FoodpandaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _ScreenHeader(
              title: 'Saved Addresses',
              onBack: () => Navigator.of(context).pop(),
            ),
            
            // Addresses Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Addresses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _FoodpandaColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._addresses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addr = entry.value;
                        return Column(
                          children: [
                            _AddressItem(
                              icon: addr['icon'] as IconData,
                              type: addr['type'] as String,
                              address: addr['address'] as String,
                              onRemove: () {
                                setState(() {
                                  _addresses.removeAt(index);
                                });
                              },
                            ),
                            if (index < _addresses.length - 1)
                              const Divider(height: 24),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Add Button
            _BottomButton(
              text: 'Add New Address',
              onTap: () {
                // TODO: Add new address
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressItem extends StatefulWidget {
  final IconData icon;
  final String type;
  final String address;
  final VoidCallback onRemove;

  const _AddressItem({
    required this.icon,
    required this.type,
    required this.address,
    required this.onRemove,
  });

  @override
  State<_AddressItem> createState() => _AddressItemState();
}

class _AddressItemState extends State<_AddressItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _FoodpandaColors.grey100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 22, color: _FoodpandaColors.grey600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _FoodpandaColors.grey900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.address,
                style: TextStyle(
                  fontSize: 14,
                  color: _FoodpandaColors.grey600,
                ),
              ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Text(
              'Remove',
              style: TextStyle(
                fontSize: 14,
                color: _isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Shared Widgets ====================

class _ScreenHeader extends StatefulWidget {
  final String title;
  final VoidCallback onBack;

  const _ScreenHeader({
    required this.title,
    required this.onBack,
  });

  @override
  State<_ScreenHeader> createState() => _ScreenHeaderState();
}

class _ScreenHeaderState extends State<_ScreenHeader> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered ? _FoodpandaColors.grey100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _FoodpandaColors.grey900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _SmallButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_isHovered ? _FoodpandaColors.coral : _FoodpandaColors.coralLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: widget.filled
                ? null
                : Border.all(color: Colors.transparent),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.filled
                  ? (_isHovered ? Colors.white : _FoodpandaColors.coral)
                  : (_isHovered ? _FoodpandaColors.coral : _FoodpandaColors.grey900),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _BottomButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_BottomButton> createState() => _BottomButtonState();
}

class _BottomButtonState extends State<_BottomButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _isPressed
                  ? _FoodpandaColors.coral.withOpacity(0.8)
                  : (_isHovered
                      ? _FoodpandaColors.coral.withOpacity(0.9)
                      : _FoodpandaColors.coral),
              borderRadius: BorderRadius.circular(30),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: _FoodpandaColors.coral.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
