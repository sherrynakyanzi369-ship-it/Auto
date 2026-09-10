class Vehicle {
  final String id;
  final String make;
  final String model;
  final String year;
  final String plate;
  final String color;
  final String type;
  final String fuelType;

  const Vehicle({
    this.id = '',
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
    required this.type,
    required this.fuelType,
  });

  String get displayName => '$make $model';

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'plate': plate,
        'color': color,
        'type': type,
        'fuelType': fuelType,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String? ?? '',
        make: json['make'] as String? ?? '',
        model: json['model'] as String? ?? '',
        year: json['year'] as String? ?? '',
        plate: json['plate'] as String? ?? '',
        color: json['color'] as String? ?? '',
        type: json['type'] as String? ?? '',
        fuelType: json['fuelType'] as String? ?? '',
      );
}