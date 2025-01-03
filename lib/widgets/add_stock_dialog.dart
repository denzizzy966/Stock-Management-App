import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';
import '../screens/scanner_screen.dart';

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
  late TextEditingController _warehouseController;

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
    _warehouseController = TextEditingController(
        text: widget.item?.warehouseName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _minStockController.dispose();
    _warehouseController.dispose();
    super.dispose();
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
                    onPressed: () async {
                      // Push to scanner screen with flag indicating it's from add_stock_dialog
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerScreen(),
                          settings: const RouteSettings(arguments: true), // true indicates from add_stock_dialog
                        ),
                      );
                      
                      // Update barcode if result is not null and widget is still mounted
                      if (result != null && mounted) {
                        setState(() {
                          _barcodeController.text = result;
                        });
                      }
                    },
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
              TextFormField(
                controller: _warehouseController,
                decoration: const InputDecoration(labelText: 'Warehouse'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a warehouse';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(widget.item == null ? 'Add' : 'Save'),
          onPressed: () async {
            final currentContext = context;
            if (_formKey.currentState!.validate()) {
              final stockProvider =
                  Provider.of<StockProvider>(currentContext, listen: false);

              // Get the current warehouse information from the input field
              final warehouseName = _warehouseController.text;
              final warehouseId = warehouseName.replaceAll(' ', '_').toUpperCase(); // Generate simple ID from name

              final item = StockItem(
                id: widget.item?.id,
                name: _nameController.text,
                barcode: _barcodeController.text,
                quantity: int.parse(_quantityController.text),
                price: double.parse(_priceController.text),
                minStockLevel: int.parse(_minStockController.text),
                lastUpdated: DateTime.now(),
                warehouseId: warehouseId,
                warehouseName: warehouseName,
              );

              if (!mounted) return;

              if (widget.item == null) {
                await stockProvider.addItem(item);
              } else {
                await stockProvider.updateItem(item);
              }

              if (!mounted) return;
              Navigator.of(currentContext).pop();
            }
          },
        ),
      ],
    );
  }
}
