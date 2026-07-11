import 'package:flutter/material.dart';
import '../../db/db_helper.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  double totalRevenue = 0;
  double totalCost = 0;
  double totalProfit = 0;
  int totalOrders = 0;
  List<Map<String, dynamic>> productProfits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    double revenue = await DBHelper.getTotalRevenue();
    double cost = await DBHelper.getTotalCostOfGoodsSold();
    int orders = await DBHelper.getTotalOrdersCount();
    List<Map<String, dynamic>> byProduct = await DBHelper.getProfitByProduct();

    setState(() {
      totalRevenue = revenue;
      totalCost = cost;
      totalProfit = revenue - cost;
      totalOrders = orders;
      productProfits = byProduct;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profit / Loss'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadData();
            },
          ),
        ],
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        loadData();
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: totalProfit >= 0 ? const [Color(0xFF11998e), Color(0xFF38ef7d)] : const [Color(0xFFE53E3E), Color(0xFFFF9A56)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (totalProfit >= 0 ? const Color(0xFF11998e) : const Color(0xFFE53E3E)).withOpacity(0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(totalProfit >= 0 ? 'Total Profit' : 'Total Loss', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 6),
                                Text('SAR ${totalProfit.abs().toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('From $totalOrders sales so far', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMiniCard(title: 'Total Revenue', value: 'SAR ${totalRevenue.toStringAsFixed(0)}', icon: Icons.trending_up_rounded, color: const Color(0xFF4facfe), isDark: isDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMiniCard(title: 'Total Cost', value: 'SAR ${totalCost.toStringAsFixed(0)}', icon: Icons.shopping_bag_rounded, color: const Color(0xFFfda085), isDark: isDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Product-wise Profit', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          productProfits.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2C) : Colors.white, borderRadius: BorderRadius.circular(16)),
                                  child: const Text('No sales yet'),
                                )
                              : Column(
                                  children: productProfits.map((p) {
                                    double revenue = (p['revenue'] as num?)?.toDouble() ?? 0;
                                    double cost = (p['cost'] as num?)?.toDouble() ?? 0;
                                    double profit = revenue - cost;
                                    double sold = (p['total_sold'] as num?)?.toDouble() ?? 0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text(p['product_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                                              Text('SAR ${profit.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: profit >= 0 ? const Color(0xFF38A169) : const Color(0xFFE53E3E))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('${sold.toStringAsFixed(1)}m sold • Revenue: SAR ${revenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({required String title, required String value, required IconData icon, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}