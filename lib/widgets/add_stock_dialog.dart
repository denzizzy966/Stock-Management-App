import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../models/warehouse.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'add_warehouse_dialog.dart';

class AddStockDialog extends StatefulWidget {
  final StockItem? item;

  const AddStockDialog({super.key, this.item});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _minStockController;
  String? _selectedWarehouseId;
  Warehouse? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _barcodeController = TextEditingController(text: widget.item?.barcode);
    _quantityController = TextEditingController(
        text: widget.item?.quantity.toString());
    _priceController = TextEditingController(
        text: widget.item?.price.toString());
    _minStockController = TextEditingController(
        text: widget.item?.minStockLevel.toString());
    _selectedWarehouseId = widget.item?.warehouseId;

    // Initialize warehouse selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final warehouseProvider = Provider.of<WarehouseProvider>(context, listen: false);
      if (_selectedWarehouseId != null) {
        try {
          _selectedWarehouse = warehouseProvider.warehouses
              .firstWhere((w) => w.id == _selectedWarehouseId);
        } catch (e) {
          print('Error finding warehouse: $e');
        }
      } else if (warehouseProvider.warehouses.isNotEmpty) {
        setState(() {
          _selectedWarehouse = warehouseProvider.warehouses.first;
          _selectedWarehouseId = _selectedWarehouse?.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final String? barcode = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isEmpty) return;
                    
                    final String? rawValue = barcodes.first.rawValue;
                    if (rawValue == null) return;
                    
                    Navigator.of(context).pop(rawValue);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (barcode != null) {
      setState(() {
        _barcodeController.text = barcode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add New Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a barcode';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minStockController,
                decoration: const InputDecoration(labelText: 'Minimum Stock Level'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a minimum stock level';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<WarehouseProvider>(
                builder: (context, warehouseProvider, child) {
                  final warehouses = warehouseProvider.warehouses;
                  
                  if (warehouses.isEmpty) {
                    return Column(
                      children: [
                        const Text(
                          'No warehouses available',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Show add warehouse dialog
                            showDialog(
                              context: context,
                              builder: (context) => const AddWarehouseDialog(),
                            );
                          },
                          child: const Text('Add Warehouse'),
                        ),
                      ],
                    );
                  }

                  // Make sure we have a selected warehouse
                  if (_selectedWarehouse == null && warehouses.isNotEmpty) {
                    _selectedWarehouse = warehouses.first;
                    _selectedWarehouseId = _selectedWarehouse?.id;
                  }

                  return DropdownButtonFormField<Warehouse>(
                    value: _selectedWarehouse,
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                    ),
                    items: warehouses.map((warehouse) {
                      return DropdownMenuItem<Warehouse>(
                        value: warehouse,
                        child: Text(warehouse.name),
                      );
                    }).toList(),
                    onChanged: (Warehouse? value) {
                      setState(() {
                        _selectedWarehouse = value;
                        _selectedWarehouseId = value?.id;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a warehouse';
                      }
                      return null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && _selectedWarehouse != null) {
              try {
                final item = StockItem(
                  id: widget.item?.id,
                  name: _nameController.text,
                  barcode: _barcodeController.text,
                  quantity: int.parse(_quantityController.text),
                  price: double.parse(_priceController.text),
                  minStockLevel: int.parse(_minStockController.text),
                  lastUpdated: DateTime.now(),
                  warehouseId: _selectedWarehouse!.id,
                  warehouseName: _selectedWarehouse!.name,
                );

                final stockProvider = Provider.of<StockProvider>(context, listen: false);
                
                if (widget.item == null) {
                  await stockProvider.addItem(item);
                } else {
                  await stockProvider.updateItem(item);
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: Text(widget.item == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
