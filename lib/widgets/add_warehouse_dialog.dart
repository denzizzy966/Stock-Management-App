import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../providers/warehouse_provider.dart';

class AddWarehouseDialog extends StatefulWidget {
  final Warehouse? warehouse;

  const AddWarehouseDialog({super.key, this.warehouse});

  @override
  State<AddWarehouseDialog> createState() => _AddWarehouseDialogState();
}

class _AddWarehouseDialogState extends State<AddWarehouseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse?.name ?? '');
    _locationController = TextEditingController(text: widget.warehouse?.location ?? '');
    _descriptionController = TextEditingController(text: widget.warehouse?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.warehouse == null ? 'Add New Warehouse' : 'Edit Warehouse'),
      content: Form(
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
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final warehouse = Warehouse(
                id: widget.warehouse?.id ?? '',
                name: _nameController.text,
                location: _locationController.text,
                description: _descriptionController.text,
              );

              if (widget.warehouse == null) {
                Provider.of<WarehouseProvider>(context, listen: false)
                    .addWarehouse(warehouse);
              } else {
                Provider.of<WarehouseProvider>(context, listen: false)
                    .updateWarehouse(warehouse);
              }

              Navigator.pop(context);
            }
          },
          child: Text(widget.warehouse == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}