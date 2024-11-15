import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/warehouse.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
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
        title: const Text('Stock History'),
        centerTitle: true,
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
          // History List
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, stockProvider, child) {
                var history = stockProvider.history;

                // Apply warehouse filter
                if (_selectedWarehouse != null) {
                  history = history.where((h) => 
                    h.warehouseId == _selectedWarehouse!.id
                  ).toList();
                }

                // Apply date filter
                if (_startDate != null) {
                  history = history.where((h) => 
                    h.timestamp.isAfter(_startDate!)
                  ).toList();
                }
                if (_endDate != null) {
                  history = history.where((h) => 
                    h.timestamp.isBefore(_endDate!.add(const Duration(days: 1)))
                  ).toList();
                }

                if (history.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history found',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          item.type == 'addition'
                              ? Icons.add_circle
                              : Icons.remove_circle,
                          color: item.type == 'addition'
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(item.itemName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.warehouseName),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(item.timestamp),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.type == 'addition' ? '+' : '-'}${item.quantityChange}',
                              style: TextStyle(
                                color: item.type == 'addition'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Total: ${item.newQuantity}'),
                          ],
                        ),
                      ),
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
