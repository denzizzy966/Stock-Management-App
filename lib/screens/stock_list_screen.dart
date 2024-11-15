import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/warehouse.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';
import '../widgets/stock_item_tile.dart';
import '../widgets/add_stock_dialog.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  Warehouse? _selectedWarehouse;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Items'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddStockDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warehouse Filter
                  Consumer<WarehouseProvider>(
                    builder: (context, warehouseProvider, child) {
                      final warehouses = warehouseProvider.warehouses;
                      return DropdownButtonFormField<Warehouse?>(
                        value: _selectedWarehouse,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Warehouse',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem<Warehouse?>(
                            value: null,
                            child: Text('All Warehouses'),
                          ),
                          ...warehouses.map((warehouse) {
                            return DropdownMenuItem<Warehouse>(
                              value: warehouse,
                              child: Text(warehouse.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (Warehouse? value) {
                          setState(() {
                            _selectedWarehouse = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Date Filter
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, true),
                            ),
                          ),
                          controller: TextEditingController(
                            text: _startDate != null
                                ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                : '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, false),
                            ),
                          ),
                          controller: TextEditingController(
                            text: _endDate != null
                                ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                : '',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Clear Filters Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedWarehouse = null;
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stock Items List
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, stockProvider, child) {
                var items = stockProvider.items;

                // Apply warehouse filter
                if (_selectedWarehouse != null) {
                  items = items.where((item) => 
                    item.warehouseId == _selectedWarehouse!.id
                  ).toList();
                }

                // Apply date filter
                if (_startDate != null) {
                  items = items.where((item) => 
                    item.lastUpdated.isAfter(_startDate!)
                  ).toList();
                }
                if (_endDate != null) {
                  items = items.where((item) => 
                    item.lastUpdated.isBefore(_endDate!.add(const Duration(days: 1)))
                  ).toList();
                }

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return StockItemTile(
                      item: item,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Item'),
                            content: Text('Are you sure you want to delete ${item.name}?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await stockProvider.deleteItem(item.id!);
                        }
                      },
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddStockDialog(item: item),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
