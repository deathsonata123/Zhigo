class Restaurant {
  final String id;
  final String name;
  final String address;
  final String? photoUrl;
  final String? email;
  final String? phone;
  final String? ownerId;
  final String status;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    this.photoUrl,
    this.email,
    this.phone,
    this.ownerId,
    required this.status,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      photoUrl: json['photo_url'],
      email: json['email'],
      phone: json['phone'],
      ownerId: json['owner_id']?.toString(),
      status: json['status'] ?? 'pending',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'photo_url': photoUrl,
      'email': email,
      'phone': phone,
      'owner_id': ownerId,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
