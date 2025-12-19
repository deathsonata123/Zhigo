class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? photoUrl;
  final String role;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.photoUrl,
    this.role = 'customer',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      photoUrl: json['photo_url'],
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (photoUrl != null) 'photo_url': photoUrl,
    'role': role,
  };
}

class Address {
  final String? id;
  final String userId;
  final String label;
  final String street;
  final String? city;
  final String? state;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address({
    this.id,
    required this.userId,
    required this.label,
    required this.street,
    this.city,
    this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      userId: json['user_id'].toString(),
      label: json['label'] ?? '',
      street: json['street'] ?? '',
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'label': label,
    'street': street,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (zipCode != null) 'zip_code': zipCode,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'is_default': isDefault,
  };
}
