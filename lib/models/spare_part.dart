class SparePart {
  final String id;
  final String name;
  final String category;
  final double price;
  final String supplier;
  final String supplierArea;
  final bool inStock;
  final String vehicleCompat;

  const SparePart({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.supplier,
    required this.supplierArea,
    required this.inStock,
    required this.vehicleCompat,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) => SparePart(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        supplier: json['supplier'] as String? ?? '',
        supplierArea: json['supplierArea'] as String? ?? '',
        inStock: json['inStock'] as bool? ?? false,
        vehicleCompat: json['vehicleCompat'] as String? ?? '',
      );

  String get currency => 'UGX';
}