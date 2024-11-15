import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';
import '../widgets/add_warehouse_dialog.dart';

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWarehouseDialog(context),
          ),
        ],
      ),
      body: Consumer<WarehouseProvider>(
        builder: (context, warehouseProvider, child) {
          final warehouses = warehouseProvider.warehouses;

          if (warehouses.isEmpty) {
            return const Center(
              child: Text('No warehouses added yet'),
            );
          }

          return ListView.builder(
            itemCount: warehouses.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final warehouse = warehouses[index];
              return Card(
                child: ListTile(
                  title: Text(warehouse.name),
                  subtitle: Text(warehouse.location),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditWarehouseDialog(context, warehouse),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteWarehouseDialog(context, warehouse, warehouseProvider),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddWarehouseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddWarehouseDialog(),
    );
  }

  void _showEditWarehouseDialog(BuildContext context, warehouse) {
    showDialog(
      context: context,
      builder: (context) => AddWarehouseDialog(warehouse: warehouse),
    );
  }

  void _showDeleteWarehouseDialog(BuildContext context, warehouse, WarehouseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: Text(
          'Are you sure you want to delete ${warehouse.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteWarehouse(warehouse.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
