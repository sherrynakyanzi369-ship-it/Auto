class AssistanceRequest {
  final String id;
  final String vehicleName;
  final String issueType;
  final String description;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final String status;
  final String mechanicName;
  final DateTime createdAt;

  const AssistanceRequest({
    required this.id,
    required this.vehicleName,
    required this.issueType,
    required this.description,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.mechanicName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleName': vehicleName,
        'issueType': issueType,
        'description': description,
        'locationLabel': locationLabel,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'mechanicName': mechanicName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AssistanceRequest.fromJson(Map<String, dynamic> json) => AssistanceRequest(
        id: json['id'] as String? ?? '',
        vehicleName: json['vehicleName'] as String? ?? '',
        issueType: json['issueType'] as String? ?? '',
        description: json['description'] as String? ?? '',
        locationLabel: json['locationLabel'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'Pending',
        mechanicName: json['mechanicName'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}