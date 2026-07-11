import 'package:flutter/material.dart';
import '../../models/supplier_model.dart';
import '../../db/db_helper.dart';
import 'add_supplier_screen.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  List<Supplier> allSuppliers = [];
  List<Supplier> filteredSuppliers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSuppliers();
  }

  void loadSuppliers() async {
    List<Supplier> data = await DBHelper.getAllSuppliers();
    setState(() {
      allSuppliers = data;
      filteredSuppliers = data;
    });
  }

  void filterSuppliers(String query) {
    setState(() {
      filteredSuppliers = allSuppliers.where((s) {
        return s.name.toLowerCase().contains(query.toLowerCase()) || s.phone.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Suppliers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF636FA4), Color(0xFFE8CBC0)]),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterSuppliers,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        searchController.clear();
                        filterSuppliers('');
                      })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: filteredSuppliers.isEmpty
                  ? const Center(child: Text('No suppliers found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        Supplier s = filteredSuppliers[index];
                        bool pending = s.balance > 0;
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
                              backgroundColor: const Color(0xFF636FA4).withOpacity(0.12),
                              child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF636FA4), fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(s.phone),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: (pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169)).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('SAR ${s.balance.abs().toStringAsFixed(0)}', style: TextStyle(color: pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169), fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(pending ? 'Payment Due' : 'Cleared', style: TextStyle(fontSize: 9, color: pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169))),
                                ],
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => SupplierDetailScreen(supplier: s)));
                              loadSuppliers();
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
          bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
          if (result == true) loadSuppliers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}