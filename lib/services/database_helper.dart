import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/stock_item.dart';
import '../models/stock_history.dart';
import '../models/warehouse.dart';
import 'package:logging/logging.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final _logger = Logger('DatabaseHelper');

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stock_manager.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE stock_items(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      barcode TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      minStockLevel INTEGER NOT NULL,
      lastUpdated TEXT NOT NULL,
      warehouseId TEXT NOT NULL,
      warehouseName TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE stock_history(
      id TEXT PRIMARY KEY,
      itemId TEXT NOT NULL,
      itemName TEXT NOT NULL,
      warehouseId TEXT NOT NULL,
      warehouseName TEXT NOT NULL,
      quantityChange INTEGER NOT NULL,
      newQuantity INTEGER NOT NULL,
      type TEXT NOT NULL,
      notes TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE warehouses(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL
    )
  ''');

    // Insert default warehouse
    await db.insert('warehouses', {
      'id': 'WH001',
      'name': 'Main Warehouse',
      'location': 'Main Location',
      'description': 'Default warehouse'
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      _logger.info('Upgrading database from version $oldVersion to $newVersion');
      
      // Drop existing tables if they exist
      await db.execute('DROP TABLE IF EXISTS stock_items');
      await db.execute('DROP TABLE IF EXISTS stock_history');
      await db.execute('DROP TABLE IF EXISTS warehouses');
      
      // Recreate tables with new schema
      await _onCreate(db, newVersion);
    }
  }

  // Stock Item Methods
  Future<List<StockItem>> getStockItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('stock_items');
      return List.generate(maps.length, (i) => StockItem.fromMap(maps[i]));
    } catch (e) {
      _logger.severe('Error getting stock items: $e');
      rethrow;
    }
  }

  Future<void> insertStockItem(StockItem item) async {
  try {
    final db = await database;
    await db.insert('stock_items', {
      ...item.toMap(),
      'id': item.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Ensure we have an ID
    });
  } catch (e) {
    _logger.severe('Error inserting stock item: $e');
    rethrow;
  }
}

  Future<int> updateStockItem(StockItem item) async {
    try {
      final db = await database;
      return await db.update(
        'stock_items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      _logger.severe('Error updating stock item: $e');
      rethrow;
    }
  }

  Future<int> deleteStockItem(String id) async {
    try {
      final db = await database;
      return await db.delete(
        'stock_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.severe('Error deleting stock item: $e');
      rethrow;
    }
  }

  // Stock History Methods
  Future<List<StockHistory>> getStockHistory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_history',
        orderBy: 'timestamp DESC'
      );
      return List.generate(maps.length, (i) => StockHistory.fromMap(maps[i]));
    } catch (e) {
      _logger.severe('Error getting stock history: $e');
      rethrow;
    }
  }

  Future<void> insertStockHistory(StockHistory history) async {
    try {
      final db = await database;
      await db.insert('stock_history', history.toMap());
    } catch (e) {
      _logger.severe('Error inserting stock history: $e');
      rethrow;
    }
  }

  // Warehouse Methods
  Future<List<Warehouse>> getWarehouses() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('warehouses');
      return List.generate(maps.length, (i) => Warehouse.fromMap(maps[i]));
    } catch (e) {
      _logger.severe('Error getting warehouses: $e');
      rethrow;
    }
  }

Future<void> insertWarehouse(Warehouse warehouse) async {
  try {
    final db = await database;
    await db.insert('warehouses', {
      ...warehouse.toMap(),
      'id': warehouse.id.isEmpty ? 'WH${DateTime.now().millisecondsSinceEpoch}' : warehouse.id,
    });
  } catch (e) {
    _logger.severe('Error inserting warehouse: $e');
    rethrow;
  }
}

  Future<int> updateWarehouse(Warehouse warehouse) async {
    try {
      final db = await database;
      return await db.update(
        'warehouses',
        warehouse.toMap(),
        where: 'id = ?',
        whereArgs: [warehouse.id],
      );
    } catch (e) {
      _logger.severe('Error updating warehouse: $e');
      rethrow;
    }
  }

  Future<int> deleteWarehouse(String id) async {
    try {
      final db = await database;
      return await db.delete(
        'warehouses',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.severe('Error deleting warehouse: $e');
      rethrow;
    }
  }
}
