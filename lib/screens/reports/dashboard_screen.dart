import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../db/db_helper.dart';
import 'profit_report_screen.dart';
import 'sales_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double todaySale = 0;
  double totalOutstanding = 0;
  List<Product> lowStockProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  void loadDashboardData() async {
    double sale = await DBHelper.getTodayTotalSale();
    double outstanding = await DBHelper.getTotalOutstanding();
    List<Product> lowStock = await DBHelper.getLowStockProducts();

    setState(() {
      todaySale = sale;
      totalOutstanding = outstanding;
      lowStockProducts = lowStock;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadDashboardData();
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
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)]),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        loadDashboardData();
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfitReportScreen()));
                                  },
                                  icon: const Icon(Icons.bar_chart_rounded, size: 18),
                                  label: const Text('Profit/Loss'),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesReportScreen()));
                                  },
                                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                                  label: const Text('Date-wise'),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11998e), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Today\'s Sale',
                                  value: 'SAR ${todaySale.toStringAsFixed(0)}',
                                  icon: Icons.trending_up_rounded,
                                  gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total Outstanding',
                                  value: 'SAR ${totalOutstanding.toStringAsFixed(0)}',
                                  icon: Icons.account_balance_wallet_rounded,
                                  gradientColors: const [Color(0xFFfa709a), Color(0xFFfee140)],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Low Stock Products', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          lowStockProducts.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                                  ),
                                  child: const Row(children: [
                                    Icon(Icons.check_circle, color: Color(0xFF38A169)),
                                    SizedBox(width: 10),
                                    Text('All products are well stocked'),
                                  ]),
                                )
                              : Column(
                                  children: lowStockProducts.map((p) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.2)),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.warning_rounded, color: Color(0xFFE53E3E)),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                          Text('${p.quantity.toStringAsFixed(1)}m', style: const TextStyle(color: Color(0xFFE53E3E), fontWeight: FontWeight.bold)),
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

  Widget _buildStatCard({required String title, required String value, required IconData icon, required List<Color> gradientColors}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}