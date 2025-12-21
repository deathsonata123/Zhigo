import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapbox Map
          MapWidget(
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(90.4125, 23.8103)),  // Dhaka, Bangladesh
              zoom: 14.0,
            ),
            styleUri: 'mapbox://styles/mapbox/streets-v12',
            textureView: true,
            onMapCreated: (MapboxMap map) {
              mapboxMap = map;
            },
          ),
          
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          
          // Map Type - CircularButtons
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                _buildCircularButton(
                  icon: Icons.restaurant,
                  tooltip: 'Restaurants',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
                _buildCircularButton(
                  icon: Icons.map,
                  tooltip: 'Map View',
                  isActive: true,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildCircularButton(
                  icon: Icons.shopping_cart,
                  tooltip: 'Cart',
                  onTap: () {
                    // TODO: Navigate to cart
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            icon,
            color: isActive ? Colors.white : Colors.black87,
            size: 24,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
