import 'package:flutter/material.dart';
import '../models/stock_item.dart';

class StockItemTile extends StatelessWidget {
  final StockItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const StockItemTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = item.quantity <= item.minStockLevel;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Quantity: ${item.quantity}'),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            if (isLowStock)
              const Text(
                'Low Stock!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red : Colors.blue,
          child: Text(
            item.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
