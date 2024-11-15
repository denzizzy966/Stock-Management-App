import 'package:flutter/material.dart';

class LowStockAlertCard extends StatelessWidget {
  final String itemName;
  final int currentStock;
  final int minStock;
  final String warehouseName;

  const LowStockAlertCard({
    super.key,
    required this.itemName,
    required this.currentStock,
    required this.minStock,
    required this.warehouseName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(itemName),
        subtitle: Text('Warehouse: $warehouseName'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Stock: $currentStock',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Min: $minStock'),
          ],
        ),
      ),
    );
  }
}
