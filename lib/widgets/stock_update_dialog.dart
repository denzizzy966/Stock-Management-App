import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../providers/stock_provider.dart';

class StockUpdateDialog extends StatefulWidget {
  final StockItem item;

  const StockUpdateDialog({
    super.key,
    required this.item,
  });

  @override
  State<StockUpdateDialog> createState() => _StockUpdateDialogState();
}

class _StockUpdateDialogState extends State<StockUpdateDialog> {
  late TextEditingController _quantityController;
  bool _isAddition = true;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Stock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text('Current Quantity: ${widget.item.quantity}'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Add Stock'),
                icon: Icon(Icons.add),
              ),
              ButtonSegment(
                value: false,
                label: Text('Remove Stock'),
                icon: Icon(Icons.remove),
              ),
            ],
            selected: {_isAddition},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _isAddition = newSelection.first;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Update'),
          onPressed: () {
            final quantity = int.tryParse(_quantityController.text);
            if (quantity == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid quantity'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final stockProvider =
                Provider.of<StockProvider>(context, listen: false);
            final newQuantity = _isAddition
                ? widget.item.quantity + quantity
                : widget.item.quantity - quantity;

            if (newQuantity < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot remove more items than available'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            stockProvider.updateStock(widget.item.id!, newQuantity);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
