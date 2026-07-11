import 'package:flutter/material.dart';
import '../../db/db_helper.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  double totalSale = 0;
  int totalOrders = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  void loadReport() async {
    setState(() => isLoading = true);
    Map<String, dynamic> result = await DBHelper.getSalesInDateRange(
      startDate.toIso8601String().substring(0, 10),
      endDate.toIso8601String().substring(0, 10),
    );
    setState(() {
      totalSale = result['total'];
      totalOrders = result['count'];
      isLoading = false;
    });
  }

  void setQuickRange(String range) {
    DateTime now = DateTime.now();
    setState(() {
      switch (range) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = now;
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          endDate = now;
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
      }
    });
    loadReport();
  }

  Future<void> pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(context: context, initialDate: isStart ? startDate : endDate, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      loadReport();
    }
  }

  String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Date-wise Sales Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => setQuickRange('today'), child: const Text('Today'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: () => setQuickRange('week'), child: const Text('This Week'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: () => setQuickRange('month'), child: const Text('This Month'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => pickDate(true),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('From', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(formatDate(startDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => pickDate(false),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              const Text('To', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(formatDate(endDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Sale in This Range', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text('SAR ${totalSale.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('$totalOrders sales in this duration', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}