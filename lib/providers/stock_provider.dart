import 'package:flutter/foundation.dart';
import '../models/stock_item.dart';
import '../models/stock_history.dart';
import '../services/database_helper.dart';

class StockProvider with ChangeNotifier {
  final List<StockItem> _items = [];
  final List<StockHistory> _history = [];
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<StockItem> get items => List.unmodifiable(_items);
  List<StockHistory> get history => List.unmodifiable(_history);

  StockProvider() {
    _loadItems();
    _loadHistory();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _db.getStockItems();
      _items.clear();
      _items.addAll(items);
      notifyListeners();
    } catch (e) {
      print('Error loading items: $e');
      rethrow;
    }
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _db.getStockHistory();
      _history.clear();
      _history.addAll(history);
      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
      rethrow;
    }
  }

  Future<void> addItem(StockItem item) async {
    try {
      // First insert the stock item
      await _db.insertStockItem(item);
      
      // Get the item with generated ID
      final items = await _db.getStockItems();
      final newItem = items.firstWhere(
        (i) => i.barcode == item.barcode && i.warehouseId == item.warehouseId,
        orElse: () => throw Exception('Failed to retrieve inserted item'),
      );
      
      _items.add(newItem);

      // Add to history
      final historyEntry = StockHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: newItem.id!, // Now we can safely use the ID
        itemName: newItem.name,
        warehouseId: newItem.warehouseId,
        warehouseName: newItem.warehouseName,
        quantityChange: newItem.quantity,
        newQuantity: newItem.quantity,
        type: 'addition',
        notes: 'Initial stock',
        timestamp: DateTime.now(),
      );
      
      await _db.insertStockHistory(historyEntry);
      _history.add(historyEntry);

      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(StockItem item) async {
    try {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        await _db.updateStockItem(item);
        _items[index] = item;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _db.deleteStockItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }

  Future<void> updateStock(String id, int newQuantity) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        final quantityChange = newQuantity - item.quantity;
        final updatedItem = item.copyWith(
          quantity: newQuantity,
          lastUpdated: DateTime.now(),
        );

        await _db.updateStockItem(updatedItem);
        _items[index] = updatedItem;

        // Add to history
        final historyEntry = StockHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          itemId: id,
          itemName: item.name,
          warehouseId: item.warehouseId,
          warehouseName: item.warehouseName,
          quantityChange: quantityChange,
          newQuantity: newQuantity,
          type: quantityChange > 0 ? 'addition' : 'removal',
          notes: 'Stock update',
          timestamp: DateTime.now(),
        );
        await _db.insertStockHistory(historyEntry);
        _history.add(historyEntry);

        notifyListeners();
      }
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }

  StockItem? findByBarcode(String barcode) {
    try {
      return _items.firstWhere((item) => item.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<StockItem?> findItemByBarcode(String barcode) async {
    try {
      return findByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }

  List<StockHistory> getStockHistory([String? warehouseId]) {
    if (warehouseId == null) {
      return List.unmodifiable(_history);
    }
    return List.unmodifiable(
      _history.where((h) => h.warehouseId == warehouseId).toList(),
    );
  }

  List<StockHistory> getRecentHistory(int limit) {
    final sortedHistory = List<StockHistory>.from(_history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(
      sortedHistory.take(limit).toList(),
    );
  }

  List<StockItem> getWarehouseItems(String warehouseId) {
    return List.unmodifiable(
      _items.where((item) => item.warehouseId == warehouseId).toList(),
    );
  }

  double getTotalValue() {
    return _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  List<StockItem> getLowStockItems() {
    return List.unmodifiable(
      _items.where((item) => item.quantity <= item.minStockLevel).toList(),
    );
  }

  Future<StockItem?> getItemById(String id) async {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addStock(String itemId, String warehouseId, int quantity, {String? notes}) async {
    try {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        final newQuantity = item.quantity + quantity;
        final updatedItem = item.copyWith(quantity: newQuantity);
        
        await _db.updateStockItem(updatedItem);
        _items[index] = updatedItem;

        // Add to history
        final historyEntry = StockHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          itemId: itemId,
          itemName: item.name,
          warehouseId: warehouseId,
          warehouseName: item.warehouseName,
          quantityChange: quantity,
          newQuantity: newQuantity,
          type: 'addition',
          notes: notes ?? 'Stock added via QR scan',
          timestamp: DateTime.now(),
        );
        await _db.insertStockHistory(historyEntry);
        _history.add(historyEntry);

        notifyListeners();
      }
    } catch (e) {
      print('Error adding stock: $e');
      rethrow;
    }
  }

  Future<void> removeStock(String itemId, String warehouseId, int quantity, {String? notes}) async {
    try {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        final newQuantity = item.quantity - quantity;
        if (newQuantity < 0) {
          throw Exception('Insufficient stock');
        }
        
        final updatedItem = item.copyWith(quantity: newQuantity);
        await _db.updateStockItem(updatedItem);
        _items[index] = updatedItem;

        // Add to history
        final historyEntry = StockHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          itemId: itemId,
          itemName: item.name,
          warehouseId: warehouseId,
          warehouseName: item.warehouseName,
          quantityChange: -quantity,
          newQuantity: newQuantity,
          type: 'removal',
          notes: notes ?? 'Stock removed via QR scan',
          timestamp: DateTime.now(),
        );
        await _db.insertStockHistory(historyEntry);
        _history.add(historyEntry);

        notifyListeners();
      }
    } catch (e) {
      print('Error removing stock: $e');
      rethrow;
    }
  }
}
