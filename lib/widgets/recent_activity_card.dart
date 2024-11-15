import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentActivityCard extends StatelessWidget {
  final String itemName;
  final int quantity;
  final bool isAddition;
  final String warehouseName;
  final DateTime timestamp;

  const RecentActivityCard({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.isAddition,
    required this.warehouseName,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(itemName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warehouse: $warehouseName'),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          isAddition ? '+$quantity' : '$quantity',
          style: TextStyle(
            color: isAddition ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
