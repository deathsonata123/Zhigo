import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/menu_item.dart';
import '../../services/restaurant_service.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Appetizers',
    'Main Course',
    'Desserts',
    'Beverages',
    'Sides',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<RestaurantProvider>();
    if (provider.restaurant == null) {
      await provider.loadRestaurant();
    }
    
    if (provider.restaurant != null) {
      try {
        _menuItems = await _restaurantService.getMenuItems(provider.restaurant!.id);
      } catch (e) {
        // Handle error
      }
    }
    
    setState(() => _isLoading = false);
  }

  List<MenuItem> get filteredItems {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category filter
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category || 
                          (category == 'All' && _selectedCategory == null);
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Menu items list
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No menu items',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMenuItems,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return _MenuItemCard(
                                item: filteredItems[index],
                                onAvailabilityChanged: (value) async {
                                  // Update availability
                                  setState(() {
                                    filteredItems[index] = filteredItems[index].copyWith(
                                      isAvailable: value,
                                    );
                                  });
                                },
                                onDelete: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Item'),
                                      content: const Text('Are you sure you want to delete this menu item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirmed == true) {
                                    setState(() {
                                      _menuItems.remove(filteredItems[index]);
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new item dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add menu item functionality would be here')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final Function(bool) onAvailabilityChanged;
  final VoidCallback onDelete;

  const _MenuItemCard({
    required this.item,
    required this.onAvailabilityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.restaurant, size: 40, color: Colors.grey[400]);
                        },
                      ),
                    )
                  : Icon(Icons.restaurant, size: 40, color: Colors.grey[400]),
            ),
            const SizedBox(width: 12),
            
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                Switch(
                  value: item.isAvailable,
                  onChanged: onAvailabilityChanged,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
