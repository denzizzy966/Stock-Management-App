class StockHistory {
  final String? id;
  final String itemId;
  final String itemName;
  final String warehouseId;
  final String warehouseName;
  final int quantityChange;
  final int newQuantity;
  final String type;
  final String notes;
  final DateTime timestamp;

  StockHistory({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantityChange,
    required this.newQuantity,
    required this.type,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'quantityChange': quantityChange,
      'newQuantity': newQuantity,
      'type': type,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static StockHistory fromMap(Map<String, dynamic> map) {
    return StockHistory(
      id: map['id'],
      itemId: map['itemId'],
      itemName: map['itemName'],
      warehouseId: map['warehouseId'],
      warehouseName: map['warehouseName'],
      quantityChange: map['quantityChange'],
      newQuantity: map['newQuantity'],
      type: map['type'],
      notes: map['notes'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  StockHistory copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? warehouseId,
    String? warehouseName,
    int? quantityChange,
    int? newQuantity,
    String? type,
    String? notes,
    DateTime? timestamp,
  }) {
    return StockHistory(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      quantityChange: quantityChange ?? this.quantityChange,
      newQuantity: newQuantity ?? this.newQuantity,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
