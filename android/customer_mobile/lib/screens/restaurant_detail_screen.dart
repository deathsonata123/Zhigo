import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/restaurant_provider.dart';
import '../providers/cart_provider.dart';
import '../models/menu_item.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final restaurantId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<RestaurantProvider>().selectRestaurant(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = context.watch<RestaurantProvider>();
    final cartProvider = context.watch<CartProvider>();
    final restaurant = restaurantProvider.selectedRestaurant;
    final menuByCategory = restaurantProvider.menuItemsByCategory;

    if (restaurantProvider.isLoading || restaurant == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [
          if (cartProvider.itemCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.pushNamed(context, '/checkout'),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Header Image
            CachedNetworkImage(
              imageUrl: restaurant.photoUrl ?? 'https://picsum.photos/800/400',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(restaurant.address)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Menu Items by Category
            ...menuByCategory.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...entry.value.map((menuItem) => _MenuItemTile(
                    menuItem: menuItem,
                    restaurantId: restaurant.id,
                    restaurantName: restaurant.name,
                  )),
                  const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
      floatingActionButton: cartProvider.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              icon: const Icon(Icons.shopping_cart),
              label: Text('View Cart (${cartProvider.itemCount})'),
            )
          : null,
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItem menuItem;
  final String restaurantId;
  final String restaurantName;

  const _MenuItemTile({
    required this.menuItem,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: menuItem.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: menuItem.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          : null,
      title: Text(menuItem.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (menuItem.description != null) Text(menuItem.description!),
          const SizedBox(height: 4),
          Text(
            '\$${menuItem.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
      trailing: IconButton.filled(
        icon: const Icon(Icons.add),
        onPressed: () {
          context.read<CartProvider>().addItem(menuItem, restaurantId, restaurantName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${menuItem.name} added to cart')),
          );
        },
      ),
    );
  }
}
