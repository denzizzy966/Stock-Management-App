import 'package:flutter/material.dart';
import '../models/stock_item.dart';

class LowStockList extends StatelessWidget {
  final List<StockItem> items;

  const LowStockList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No items with low stock',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text(
              'Current: ${item.quantity} | Minimum: ${item.minStockLevel}',
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.warning,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
