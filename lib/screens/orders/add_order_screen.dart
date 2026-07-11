import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../db/db_helper.dart';
import '../../utils/receipt_helper.dart';
import '../customers/customer_picker_screen.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  Customer? selectedCustomer;
  List<Product> allProducts = [];

  final TextEditingController itemController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    List<Product> data = await DBHelper.getAllProducts();
    setState(() {
      allProducts = data;
    });
  }

  void saveOrder() async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer first')),
      );
      return;
    }

    String item = itemController.text.trim();
    double total = double.tryParse(totalController.text.trim()) ?? 0;
    double advance = double.tryParse(advanceController.text.trim()) ?? 0;

    if (item.isEmpty || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item description and total amount are required')),
      );
      return;
    }

    if (advance > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advance cannot be more than total')),
      );
      return;
    }

    OrderModel newOrder = OrderModel(
      customerId: selectedCustomer!.id!,
      itemDescription: item,
      totalAmount: total,
      advancePaid: advance,
      status: 'pending',
    );

    int orderId = await DBHelper.addOrder(newOrder);

    if (advance > 0 && mounted) {
      bool? sendReceipt = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Send Advance Receipt?'),
          content: Text('Send a receipt showing SAR ${advance.toStringAsFixed(0)} paid and SAR ${(total - advance).toStringAsFixed(0)} remaining?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Skip')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
          ],
        ),
      );

      if (sendReceipt == true) {
        await ReceiptHelper.generateOrderAdvanceReceipt(
          orderId: orderId,
          customerName: selectedCustomer!.name,
          itemDescription: item,
          totalAmount: total,
          advancePaid: advance,
        );
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Order'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 34),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        Customer? picked = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CustomerPickerScreen()),
                        );
                        if (picked != null && picked.id != -1) {
                          setState(() {
                            selectedCustomer = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF262636) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedCustomer?.name ?? 'Tap to select customer',
                                style: TextStyle(
                                  fontWeight: selectedCustomer != null ? FontWeight.w600 : FontWeight.normal,
                                  color: selectedCustomer != null ? null : Colors.grey,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: itemController,
                      decoration: const InputDecoration(
                        hintText: 'What needs to be made (e.g. 1 Suit Stitching)',
                        prefixIcon: Icon(Icons.content_cut_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (allProducts.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allProducts.map((p) {
                          return ActionChip(
                            label: Text(p.name, style: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              setState(() {
                                itemController.text = p.name;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    TextField(
                      controller: totalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Total Amount (SAR)',
                        prefixIcon: Icon(Icons.payments_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: advanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Advance Paid (SAR) - if any',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveOrder,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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
}