class Mechanic {
  final String id;
  final String name;
  final String businessName;
  final String specialty;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final bool available;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String experience;
  final double distanceKm;

  const Mechanic({
    required this.id,
    required this.name,
    required this.businessName,
    required this.specialty,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.available,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.experience,
    this.distanceKm = 0,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) => Mechanic(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        businessName: json['businessName'] as String? ?? '',
        specialty: json['specialty'] as String? ?? '',
        services: (json['services'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        available: json['available'] as bool? ?? false,
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        experience: json['experience'] as String? ?? '',
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      );

  Mechanic copyWith({double? distanceKm}) => Mechanic(
        id: id,
        name: name,
        businessName: businessName,
        specialty: specialty,
        services: services,
        rating: rating,
        reviewCount: reviewCount,
        available: available,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        experience: experience,
        distanceKm: distanceKm ?? this.distanceKm,
      );
}