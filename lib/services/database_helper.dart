import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock_item.dart';
import '../models/stock_history.dart';
import '../models/warehouse.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  bool _isInitialized = false;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!_isInitialized) {
      // Delete existing database if it exists
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      
      try {
        await deleteDatabase(path);
        print('Existing database deleted successfully');
      } catch (e) {
        print('Error deleting database: $e');
      }
      
      _isInitialized = true;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create warehouses table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS warehouses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Create stock_items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        barcode TEXT UNIQUE,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        minStockLevel INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL,
        warehouseId TEXT NOT NULL,
        warehouseName TEXT NOT NULL,
        FOREIGN KEY (warehouseId) REFERENCES warehouses (id)
          ON DELETE CASCADE
      )
    ''');

    // Create stock_history table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_history (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        warehouseId TEXT NOT NULL,
        warehouseName TEXT NOT NULL,
        quantityChange INTEGER NOT NULL,
        newQuantity INTEGER NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (itemId) REFERENCES stock_items (id)
          ON DELETE CASCADE,
        FOREIGN KEY (warehouseId) REFERENCES warehouses (id)
          ON DELETE CASCADE
      )
    ''');

    print('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop existing tables if they exist
      await db.execute('DROP TABLE IF EXISTS stock_history');
      await db.execute('DROP TABLE IF EXISTS stock_items');
      await db.execute('DROP TABLE IF EXISTS warehouses');
      
      // Recreate all tables
      await _createDB(db, newVersion);
      print('Database upgraded from version $oldVersion to $newVersion');
    }
  }

  Future<List<Warehouse>> getWarehouses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('warehouses');
    return List.generate(maps.length, (i) => Warehouse.fromMap(maps[i]));
  }

  Future<String> insertWarehouse(Warehouse warehouse) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final warehouseWithId = warehouse.copyWith(id: id);
    await db.insert('warehouses', warehouseWithId.toMap());
    return id;
  }

  Future<void> updateWarehouse(Warehouse warehouse) async {
    final db = await database;
    await db.update(
      'warehouses',
      warehouse.toMap(),
      where: 'id = ?',
      whereArgs: [warehouse.id],
    );
  }

  Future<void> deleteWarehouse(String id) async {
    final db = await database;
    await db.delete(
      'warehouses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<StockItem>> getStockItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('stock_items');
    return List.generate(maps.length, (i) => StockItem.fromMap(maps[i]));
  }

  Future<String> insertStockItem(StockItem item) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final itemWithId = item.copyWith(id: id);
    await db.insert('stock_items', itemWithId.toMap());
    return id;
  }

  Future<void> updateStockItem(StockItem item) async {
    final db = await database;
    await db.update(
      'stock_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteStockItem(String id) async {
    final db = await database;
    await db.delete(
      'stock_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<StockHistory>> getStockHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_history',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => StockHistory.fromMap(maps[i]));
  }

  Future<void> insertStockHistory(StockHistory history) async {
    final db = await database;
    await db.insert('stock_history', history.toMap());
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<bool> checkTables() async {
    final db = await database;
    try {
      await db.query('warehouses', limit: 1);
      await db.query('stock_items', limit: 1);
      await db.query('stock_history', limit: 1);
      return true;
    } catch (e) {
      print('Error checking tables: $e');
      return false;
    }
  }
}
