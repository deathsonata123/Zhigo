class Restaurant {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? zone;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.zone,
    this.phone,
    this.email,
    this.imageUrl,
    this.logoUrl,
    this.latitude,
    this.longitude,
    required this.status,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      zone: json['zone'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      imageUrl: json['image_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'zone': zone,
      'phone': phone,
      'email': email,
      'image_url': imageUrl,
      'logo_url': logoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
