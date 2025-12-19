import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../models/delivery.dart';

class ActiveDeliveryMapScreen extends StatefulWidget {
  final Delivery delivery;
  final Function() onArrivedAtRestaurant;
  final Function() onConfirmPickup;
  final Function() onArrivedAtCustomer;
  final Function() onCompleteDelivery;

  const ActiveDeliveryMapScreen({
    super.key,
    required this.delivery,
    required this.onArrivedAtRestaurant,
    required this.onConfirmPickup,
    required this.onArrivedAtCustomer,
    required this.onCompleteDelivery,
  });

  @override
  State<ActiveDeliveryMapScreen> createState() => _ActiveDeliveryMapScreenState();
}

class _ActiveDeliveryMapScreenState extends State<ActiveDeliveryMapScreen> {
  MapboxMap? mapboxMap;
  final String _mapboxAccessToken = 'pk.eyJ1IjoiemhpZ28xdXNlciIsImEiOiJjbWY0MDR6ZnMwMGJ0MmlxdmQxczhoeHZyIn0.7v1KgJkk2S-R--wSL5_ReQ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Delivery'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Mapbox Map
          MapWidget(
            key: const ValueKey('mapWidget'),
            resourceOptions: ResourceOptions(accessToken: _mapboxAccessToken),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  widget.delivery.restaurantLongitude ?? 90.4125,
                  widget.delivery.restaurantLatitude ?? 23.8103,
                ),
              ),
              zoom: 14.0,
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: (MapboxMap map) {
              mapboxMap = map;
              _setupMap();
            },
          ),
          // Delivery Info Card at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBadge(),
                      const SizedBox(height: 16),
                      _buildCurrentStep(),
                      const SizedBox(height: 16),
                      _buildOrderDetails(),
                      const SizedBox(height: 20),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setupMap() async {
    if (mapboxMap == null) return;

    // Add markers for restaurant and customer
    // Note: Mapbox Flutter implementation for markers varies by version
    // This is a simplified version - adjust based on your mapbox_maps_flutter version
  }

  Widget _buildStatusBadge() {
    String status = widget.delivery.status;
    Color color;
    String label;

    switch (status) {
      case 'assigned':
        color = Colors.blue;
        label = 'Heading to Restaurant';
        break;
      case 'at_restaurant':
        color = Colors.orange;
        label = 'At Restaurant';
        break;
      case 'picked_up':
        color = Colors.purple;
        label = 'Delivering to Customer';
        break;
      case 'delivering':
        color = Colors.green;
        label = 'At Customer Location';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    String status = widget.delivery.status;
    IconData icon;
    String title;
    String subtitle;

    if (status == 'assigned') {
      icon = Icons.store;
      title = widget.delivery.restaurantName ?? 'Restaurant';
      subtitle = 'Pickup location';
    } else {
      icon = Icons.location_on;
      title = widget.delivery.customerAddress ?? 'Customer';
      subtitle = 'Delivery location';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.cyan.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order #${widget.delivery.id?.substring(0, 8) ?? 'N/A'}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          'Tk ${widget.delivery.total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    String status = widget.delivery.status;
    String buttonText;
    VoidCallback? onPressed;

    switch (status) {
      case 'assigned':
        buttonText = 'Arrived at Restaurant';
        onPressed = widget.onArrivedAtRestaurant;
        break;
      case 'at_restaurant':
        buttonText = 'Confirm Pickup';
        onPressed = widget.onConfirmPickup;
        break;
      case 'picked_up':
        buttonText = 'Arrived at Customer';
        onPressed = widget.onArrivedAtCustomer;
        break;
      case 'delivering':
        buttonText = 'Complete Delivery';
        onPressed = widget.onCompleteDelivery;
        break;
      default:
        buttonText = 'Continue';
        onPressed = null;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
