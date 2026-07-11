import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../models/transaction_model.dart';
import '../../db/db_helper.dart';
import 'add_customer_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  List<TransactionModel> transactions = [];
  late Customer customer;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
    loadTransactions();
  }

  void loadTransactions() async {
    List<TransactionModel> data = await DBHelper.getTransactionsByCustomer(customer.id!);
    setState(() {
      transactions = data;
    });
  }

  void addTransaction(String type) async {
    double amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    TransactionModel newTransaction = TransactionModel(
      customerId: customer.id!,
      type: type,
      amount: amount,
      note: noteController.text.trim(),
    );

    await DBHelper.addTransaction(newTransaction);

    double newBalance = type == 'debit' ? customer.balance + amount : customer.balance - amount;
    await DBHelper.updateBalance(customer.id!, newBalance);

    setState(() {
      customer.balance = newBalance;
    });

    amountController.clear();
    noteController.clear();
    loadTransactions();

    Navigator.pop(context);
  }

  void showAddTransactionDialog(String type) {
    amountController.clear();
    noteController.clear();
    bool isDebit = type == 'debit';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(isDebit ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                  color: isDebit ? Colors.red : Colors.green),
              const SizedBox(width: 8),
              Text(isDebit ? 'Credit Given' : 'Payment Received'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Amount (SAR)', prefixIcon: Icon(Icons.payments_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes_rounded)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => addTransaction(type),
              style: ElevatedButton.styleFrom(backgroundColor: isDebit ? Colors.red : Colors.green, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void editCustomer() async {
    bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerScreen(customer: customer)));
    if (result == true) {
      List<Customer> allCustomers = await DBHelper.getAllCustomers();
      Customer updated = allCustomers.firstWhere((c) => c.id == customer.id);
      setState(() {
        customer = updated;
      });
    }
  }

  void deleteCustomerConfirm() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Customer?'),
        content: Text('Deleting ${customer.name} will also delete their entire history. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteCustomer(customer.id!);
      Navigator.pop(context, true);
    }
  }

  void deleteTransactionConfirm(TransactionModel t) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry?'),
        content: const Text('Deleting this entry will also adjust the balance back.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteTransaction(t.id!);
      double newBalance = t.type == 'debit' ? customer.balance - t.amount : customer.balance + t.amount;
      await DBHelper.updateBalance(customer.id!, newBalance);
      setState(() {
        customer.balance = newBalance;
      });
      loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool owes = customer.balance > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(customer.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: editCustomer),
          IconButton(icon: const Icon(Icons.delete_rounded), onPressed: deleteCustomerConfirm),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                if (customer.phone.isNotEmpty) Text(customer.phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text(
                        'SAR ${customer.balance.abs().toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: owes ? const Color(0xFFE53E3E) : const Color(0xFF38A169)),
                      ),
                      Text(
                        customer.balance > 0 ? 'Customer owes this amount' : customer.balance < 0 ? 'We owe this customer' : 'All settled',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
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
                            onPressed: () => showAddTransactionDialog('debit'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Credit Given'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => showAddTransactionDialog('credit'),
                            icon: const Icon(Icons.remove_rounded, size: 18),
                            label: const Text('Payment Received'),
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
                              TransactionModel t = transactions[index];
                              bool isDebit = t.type == 'debit';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (isDebit ? Colors.red : Colors.green).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(isDebit ? Icons.add_rounded : Icons.remove_rounded, color: isDebit ? Colors.red : Colors.green, size: 18),
                                  ),
                                  title: Text('SAR ${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(t.note.isEmpty ? t.date : '${t.note} • ${t.date}', style: const TextStyle(fontSize: 11)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                                    onPressed: () => deleteTransactionConfirm(t),
                                  ),
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
}