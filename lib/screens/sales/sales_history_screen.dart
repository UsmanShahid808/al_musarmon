import 'package:flutter/material.dart';
import '../../models/sale_model.dart';
import '../../db/db_helper.dart';
import '../../utils/receipt_helper.dart';
import 'sale_detail_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<Sale> sales = [];

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  void loadSales() async {
    List<Sale> data = await DBHelper.getAllSales();
    setState(() {
      sales = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: sales.isEmpty
                  ? const Center(child: Text('No sales yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        Sale s = sales[index];
                        int displayNumber = ReceiptHelper.displayNumber(s.id!);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(color: const Color(0xFF38A169).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF38A169)),
                            ),
                            title: Text('SAR ${s.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            subtitle: Text('#$displayNumber • ${s.date}', style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SaleDetailScreen(sale: s)));
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}