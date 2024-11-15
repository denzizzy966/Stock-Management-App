class StockItem {
  final String? id;
  final String name;
  final String barcode;
  final int quantity;
  final double price;
  final int minStockLevel;
  final DateTime lastUpdated;
  final String warehouseId;
  final String warehouseName;

  StockItem({
    this.id,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.price,
    required this.minStockLevel,
    required this.lastUpdated,
    required this.warehouseId,
    required this.warehouseName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'price': price,
      'minStockLevel': minStockLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
    };
  }

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      quantity: map['quantity'],
      price: map['price'],
      minStockLevel: map['minStockLevel'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
      warehouseId: map['warehouseId'],
      warehouseName: map['warehouseName'],
    );
  }

  StockItem copyWith({
    String? id,
    String? name,
    String? barcode,
    int? quantity,
    double? price,
    int? minStockLevel,
    DateTime? lastUpdated,
    String? warehouseId,
    String? warehouseName,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
    );
  }
}
