import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';
import '../widgets/stock_summary_card.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/low_stock_alert_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Consumer2<StockProvider, WarehouseProvider>(
        builder: (context, stockProvider, warehouseProvider, child) {
          final totalItems = stockProvider.items.length;
          final lowStockItems = stockProvider.getLowStockItems().length;
          final totalWarehouses = warehouseProvider.warehouses.length;
          final totalValue = stockProvider.getTotalValue();
          final recentHistory = stockProvider.getRecentHistory(5);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Date and Time
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          dateFormat.format(now),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            return Text(
                              timeFormat.format(DateTime.now()),
                              style: Theme.of(context).textTheme.titleMedium,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: StockSummaryCard(
                        title: 'Total Items',
                        value: totalItems.toString(),
                        icon: Icons.inventory,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: StockSummaryCard(
                        title: 'Low Stock',
                        value: lowStockItems.toString(),
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: StockSummaryCard(
                        title: 'Warehouses',
                        value: totalWarehouses.toString(),
                        icon: Icons.warehouse,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: StockSummaryCard(
                        title: 'Total Value',
                        value: 'Rp ${_formatCurrency(totalValue)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (recentHistory.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No recent activity'),
                    ),
                  )
                else
                  ...recentHistory.map((history) {
                    final isAddition = history.type == 'addition';
                    return RecentActivityCard(
                      itemName: history.itemName,
                      quantity: history.quantityChange,
                      isAddition: isAddition,
                      warehouseName: history.warehouseName,
                      timestamp: history.timestamp,
                    );
                  }),
                const SizedBox(height: 24.0),
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (lowStockItems == 0)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No low stock items'),
                    ),
                  )
                else
                  ...stockProvider.getLowStockItems().map((item) => 
                    LowStockAlertCard(
                      itemName: item.name,
                      currentStock: item.quantity,
                      minStock: item.minStockLevel,
                      warehouseName: item.warehouseName,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
