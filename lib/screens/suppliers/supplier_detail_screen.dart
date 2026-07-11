import 'package:flutter/material.dart';
import '../../models/supplier_model.dart';
import '../../models/supplier_transaction_model.dart';
import '../../db/db_helper.dart';
import 'add_supplier_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  List<SupplierTransaction> transactions = [];
  late Supplier supplier;
  double totalReceived = 0;
  double totalPaid = 0;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    supplier = widget.supplier;
    loadAll();
  }

  void loadAll() async {
    List<SupplierTransaction> data = await DBHelper.getSupplierTransactions(supplier.id!);
    Map<String, double> stats = await DBHelper.getSupplierStats(supplier.id!);
    setState(() {
      transactions = data;
      totalReceived = stats['totalReceived'] ?? 0;
      totalPaid = stats['totalPaid'] ?? 0;
    });
  }

  double get netDue => totalReceived - totalPaid;

  void addTransaction(String type) async {
    double amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    SupplierTransaction newTransaction = SupplierTransaction(supplierId: supplier.id!, type: type, amount: amount, note: noteController.text.trim());

    await DBHelper.addSupplierTransaction(newTransaction);

    double newBalance = type == 'purchase' ? supplier.balance + amount : supplier.balance - amount;
    await DBHelper.updateSupplierBalance(supplier.id!, newBalance);

    amountController.clear();
    noteController.clear();
    loadAll();

    Navigator.pop(context);
  }

  void showAddTransactionDialog(String type) {
    amountController.clear();
    noteController.clear();
    bool isPurchase = type == 'purchase';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(isPurchase ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded, color: isPurchase ? Colors.red : Colors.green),
            const SizedBox(width: 8),
            Text(isPurchase ? 'Goods Received' : 'Pay Supplier'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: amountController, keyboardType: TextInputType.number, autofocus: true, decoration: const InputDecoration(labelText: 'Amount (SAR)', prefixIcon: Icon(Icons.payments_outlined))),
              const SizedBox(height: 10),
              TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note (e.g. 5 rolls received)', prefixIcon: Icon(Icons.notes_rounded))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => addTransaction(type),
              style: ElevatedButton.styleFrom(backgroundColor: isPurchase ? Colors.red : Colors.green, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void editSupplier() async {
    bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddSupplierScreen(supplier: supplier)));
    if (result == true) {
      List<Supplier> allSuppliers = await DBHelper.getAllSuppliers();
      Supplier updated = allSuppliers.firstWhere((s) => s.id == supplier.id);
      setState(() {
        supplier = updated;
      });
    }
  }

  void deleteSupplierConfirm() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Supplier?'),
        content: Text('Deleting ${supplier.name} will also delete their entire history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteSupplier(supplier.id!);
      Navigator.pop(context, true);
    }
  }

  void deleteTransactionConfirm(SupplierTransaction t) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry?'),
        content: const Text('This will also update the totals.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteSupplierTransaction(t.id!);
      double newBalance = t.type == 'purchase' ? supplier.balance - t.amount : supplier.balance + t.amount;
      await DBHelper.updateSupplierBalance(supplier.id!, newBalance);
      loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool pending = netDue > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(supplier.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: editSupplier),
          IconButton(icon: const Icon(Icons.delete_rounded), onPressed: deleteSupplierConfirm),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF636FA4), Color(0xFFE8CBC0)]),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                if (supplier.phone.isNotEmpty) Text(supplier.phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _statBox('Total Received', totalReceived)),
                    const SizedBox(width: 8),
                    Expanded(child: _statBox('Total Paid', totalPaid)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      Text('SAR ${netDue.abs().toStringAsFixed(0)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169))),
                      Text(pending ? 'Net amount due to supplier' : (netDue < 0 ? 'Advance paid to supplier' : 'All settled'), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => showAddTransactionDialog('purchase'),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Goods Received'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => showAddTransactionDialog('payment'),
                            icon: const Icon(Icons.remove_rounded, size: 20),
                            label: const Text('Pay Supplier'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(child: Text('No transactions yet'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              SupplierTransaction t = transactions[index];
                              bool isPurchase = t.type == 'purchase';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2C) : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: (isPurchase ? Colors.red : Colors.green).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Icon(isPurchase ? Icons.add_rounded : Icons.remove_rounded, color: isPurchase ? Colors.red : Colors.green, size: 18),
                                  ),
                                  title: Text('SAR ${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(t.note.isEmpty ? t.date : '${t.note} • ${t.date}', style: const TextStyle(fontSize: 11)),
                                  trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20), onPressed: () => deleteTransactionConfirm(t)),
                                ),
                              );
                            },
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

  Widget _statBox(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Text('SAR ${value.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}