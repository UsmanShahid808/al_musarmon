import 'package:flutter/material.dart';
import 'customers/customer_list_screen.dart';
import 'products/product_list_screen.dart';
import 'sales/new_sale_screen.dart';
import 'sales/sales_history_screen.dart';
import 'reports/dashboard_screen.dart';
import 'backup/backup_screen.dart';
import 'orders/order_list_screen.dart';
import 'suppliers/supplier_list_screen.dart';
import 'workers/worker_list_screen.dart';
import '../theme/theme_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Al Musarmon'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () {
                  themeNotifier.value = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'السلام عليكم 👋',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Shahid Sahab',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your complete shop management, in one place',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.05,
                      children: [
                        _buildMenuCard(
                          context,
                          icon: Icons.dashboard_rounded,
                          title: 'Dashboard',
                          gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.people_alt_rounded,
                          title: 'Customers',
                          gradientColors: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.inventory_2_rounded,
                          title: 'Products / Stock',
                          gradientColors: const [Color(0xFFf6d365), Color(0xFFfda085)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.point_of_sale_rounded,
                          title: 'New Sale',
                          gradientColors: const [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const NewSaleScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.checkroom_rounded,
                          title: 'Orders (Advance)',
                          gradientColors: const [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderListScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.local_shipping_rounded,
                          title: 'Suppliers',
                          gradientColors: const [Color(0xFF636FA4), Color(0xFFE8CBC0)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierListScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.engineering_rounded,
                          title: 'Workers',
                          gradientColors: const [Color(0xFF9C27B0), Color(0xFF6C63FF)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerListScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.history_rounded,
                          title: 'Sales History',
                          gradientColors: const [Color(0xFFfa709a), Color(0xFFfee140)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesHistoryScreen()));
                          },
                        ),
                        _buildMenuCard(
                          context,
                          icon: Icons.backup_rounded,
                          title: 'Backup & Restore',
                          gradientColors: const [Color(0xFF636FA4), Color(0xFFE8CBC0)],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}