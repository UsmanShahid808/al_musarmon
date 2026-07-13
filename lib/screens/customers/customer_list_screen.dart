import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../db/db_helper.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> allCustomers = [];
  List<Customer> filteredCustomers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  void loadCustomers() async {
    List<Customer> data = await DBHelper.getAllCustomers();
    setState(() {
      allCustomers = data;
      filteredCustomers = data;
    });
  }

  void filterCustomers(String query) {
    setState(() {
      filteredCustomers = allCustomers.where((c) {
        return c.name.toLowerCase().contains(query.toLowerCase()) || c.phone.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterCustomers,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        searchController.clear();
                        filterCustomers('');
                      })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: filteredCustomers.isEmpty
                  ? const Center(child: Text('No customers found'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        Customer c = filteredCustomers[index];
                        bool owes = c.balance > 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
                              child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(c.phone),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'SAR ${c.balance.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: owes ? const Color(0xFFE53E3E) : const Color(0xFF38A169),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(owes ? 'owed' : 'clear', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetailScreen(customer: c)));
                              loadCustomers();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
          if (result == true) loadCustomers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}