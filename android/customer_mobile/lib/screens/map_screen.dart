import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// Mapbox Access Token
const String mapboxAccessToken = 'pk.eyJ1IjoiemhpZ28xdXNlciIsImEiOiJjbWY0MDR6ZnMwMGJ0MmlxdmQxczhoeHZyIn0.7v1KgJkk2S-R--wSL5_ReQ';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapbox Map
          MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(90.4125, 23.8103)),
              zoom: 16.0,
              pitch: 70.0,
              bearing: -17.6,
            ),
            styleUri: MapboxStyles.STANDARD,
            textureView: true,
            onMapCreated: _onMapCreated,
          ),

          // Right sidebar with action buttons
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.5 - 200,
            child: _buildSidebar(),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _configureMap();
  }

  Future<void> _configureMap() async {
    if (_mapboxMap == null) return;

    try {
      // Enable 3D terrain
      await _mapboxMap!.style.setStyleTerrain(
        {
          "source": "mapbox-dem",
          "exaggeration": 1.5,
        },
      );

      // Add terrain source
      await _mapboxMap!.style.addSource(
        "mapbox-dem",
        {
          "type": "raster-dem",
          "url": "mapbox://mapbox.mapbox-terrain-dem-v1",
          "tileSize": 512,
          "maxzoom": 14,
        },
      );
    } catch (e) {
      print('Error configuring map: $e');
    }
  }

  Widget _buildSidebar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Restaurants button
        _buildActionButton(
          icon: Icons.restaurant,
          label: 'Restaurants',
          onPressed: () {
            Navigator.pushNamed(context, '/restaurants');
          },
        ),
        const SizedBox(height: 12),

        // Map button (current page)
        _buildActionButton(
          icon: Icons.map,
          label: 'Map',
          onPressed: () {
            // Already on map page
          },
          isActive: true,
        ),
        const SizedBox(height: 12),

        // Time of day selector
        _buildActionButton(
          icon: Icons.wb_sunny,
          label: 'Time',
          onPressed: () {
            _showTimeOfDaySelector();
          },
        ),
        const SizedBox(height: 12),

        // Shopping cart button
        _buildActionButton(
          icon: Icons.shopping_cart,
          label: 'Cart',
          onPressed: () {
            Navigator.pushNamed(context, '/checkout');
          },
        ),
        const SizedBox(height: 12),

        // User profile button
        _buildActionButton(
          icon: Icons.person,
          label: 'Profile',
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _showTimeOfDaySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Time of Day',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Day'),
              onTap: () {
                Navigator.pop(context);
                // Implement day lighting
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_twilight),
              title: const Text('Dawn'),
              onTap: () {
                Navigator.pop(context);
                // Implement dawn lighting
              },
            ),
            ListTile(
              leading: const Icon(Icons.nights_stay),
              title: const Text('Dusk'),
              onTap: () {
                Navigator.pop(context);
                // Implement dusk lighting
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('Night'),
              onTap: () {
                Navigator.pop(context);
                // Implement night lighting
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
