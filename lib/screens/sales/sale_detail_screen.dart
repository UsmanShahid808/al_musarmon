import 'package:flutter/material.dart';
import '../../models/sale_model.dart';
import '../../db/db_helper.dart';
import '../../utils/receipt_helper.dart';

class SaleDetailScreen extends StatefulWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    List<Map<String, dynamic>> data = await DBHelper.getSaleItemsWithProductName(widget.sale.id!);
    setState(() {
      items = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int displayNumber = ReceiptHelper.displayNumber(widget.sale.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sale #$displayNumber'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${widget.sale.date}'),
                          const SizedBox(height: 6),
                          Text('Total: SAR ${widget.sale.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(alignment: Alignment.centerLeft, child: Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text('No items found'))
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              var item = items[index];
                              double qty = (item['quantity'] as num).toDouble();
                              double price = (item['price'] as num).toDouble();
                              return ListTile(
                                title: Text(item['product_name'] ?? 'Unknown'),
                                subtitle: Text('${qty.toStringAsFixed(2)}m x SAR ${price.toStringAsFixed(0)}'),
                                trailing: Text('SAR ${(qty * price).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}