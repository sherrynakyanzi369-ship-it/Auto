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

  String get currency => 'UGX';
}