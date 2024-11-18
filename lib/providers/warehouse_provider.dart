import 'package:flutter/foundation.dart';
import '../models/warehouse.dart';
import '../services/database_helper.dart';

class WarehouseProvider with ChangeNotifier {
  final List<Warehouse> _warehouses = [];
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Warehouse> get warehouses => List.unmodifiable(_warehouses);

  WarehouseProvider() {
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    try {
      final warehouses = await _db.getWarehouses();
      _warehouses.clear();
      _warehouses.addAll(warehouses);
      notifyListeners();
    } catch (e) {
      print('Error loading warehouses: $e');
      rethrow;
    }
  }

  Future<void> addWarehouse(Warehouse warehouse) async {
    try {
      // First insert the warehouse
      await _db.insertWarehouse(warehouse);
      
      // Fetch the updated list to get the warehouse with the generated ID
      final warehouses = await _db.getWarehouses();
      final newWarehouse = warehouses.firstWhere(
        (w) => w.name == warehouse.name && 
              w.location == warehouse.location && 
              w.description == warehouse.description,
        orElse: () => throw Exception('Failed to retrieve inserted warehouse'),
      );
      
      _warehouses.add(newWarehouse);
      notifyListeners();
    } catch (e) {
      print('Error adding warehouse: $e');
      rethrow;
    }
  }

  Future<void> updateWarehouse(Warehouse warehouse) async {
    try {
      final index = _warehouses.indexWhere((w) => w.id == warehouse.id);
      if (index != -1) {
        await _db.updateWarehouse(warehouse);
        _warehouses[index] = warehouse;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating warehouse: $e');
      rethrow;
    }
  }

  Future<void> deleteWarehouse(String id) async {
    try {
      await _db.deleteWarehouse(id);
      _warehouses.removeWhere((warehouse) => warehouse.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting warehouse: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadWarehouses();
  }
}