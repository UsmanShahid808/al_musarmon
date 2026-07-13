import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/customer_model.dart';
import '../../models/transaction_model.dart';
import '../../db/db_helper.dart';
import '../../utils/receipt_helper.dart';
import '../../utils/whatsapp_helper.dart';
import 'add_order_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<OrderModel> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() async {
    List<OrderModel> data = await DBHelper.getAllOrders();
    setState(() {
      orders = data;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'ready':
        return const Color(0xFF38A169);
      case 'delivered':
        return Colors.grey;
      default:
        return const Color(0xFFFF9A56);
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'ready':
        return 'Ready';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Pending';
    }
  }

  Future<void> markAsReady(OrderModel order) async {
    await DBHelper.updateOrderStatus(
      order.id!,
      'ready',
      readyDate: DateTime.now().toString().substring(0, 16),
    );
    loadOrders();

    bool? sendMsg = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Order Marked as Ready!'),
        content: Text('Send a WhatsApp message to ${order.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Send'),
          ),
        ],
      ),
    );

    if (sendMsg == true) {
      Customer? customer = await DBHelper.getCustomerById(order.customerId);
      if (customer != null && customer.phone.isNotEmpty) {
        String message = 'مرحباً ${customer.name}،\n'
            'طلبك (${order.itemDescription}) جاهز الآن.\n'
            'المبلغ المتبقي: ${order.remainingAmount.toStringAsFixed(0)} ريال سعودي\n'
            'يرجى التكرم بالحضور لاستلامه.\n'
             'شكراً لتعاملكم معنا - المسارون';
        await WhatsAppHelper.sendMessage(context, customer.phone, message);
      }
    }
  }

  void markAsDelivered(OrderModel order) async {
    final TextEditingController paidNowController = TextEditingController(
      text: order.remainingAmount.toStringAsFixed(0),
    );

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Deliver Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Remaining Amount: SAR ${order.remainingAmount.toStringAsFixed(0)}'),
              const SizedBox(height: 12),
              TextField(
                controller: paidNowController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'How much is the customer paying now?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If not paid in full, the remaining amount will go to the customer\'s account balance',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    double paidNow = double.tryParse(paidNowController.text.trim()) ?? 0;
    double stillOwed = order.remainingAmount - paidNow;

    if (stillOwed > 0) {
      Customer? customer = await DBHelper.getCustomerById(order.customerId);
      if (customer != null) {
        await DBHelper.addTransaction(TransactionModel(
          customerId: customer.id!,
          type: 'debit',
          amount: stillOwed,
          note: 'Order balance: ${order.itemDescription}',
        ));

        double newBalance = customer.balance + stillOwed;
        await DBHelper.updateBalance(customer.id!, newBalance);
      }
    }

    double newAdvancePaid = order.advancePaid + paidNow;
    if (newAdvancePaid > order.totalAmount) newAdvancePaid = order.totalAmount;

    await DBHelper.updateOrderPayment(order.id!, newAdvancePaid);
    await DBHelper.updateOrderStatus(order.id!, 'delivered');
    await DBHelper.addOrderAsSale(order.customerId, order.totalAmount, order.itemDescription);
    loadOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(stillOwed > 0
              ? 'Order delivered. SAR ${stillOwed.toStringAsFixed(0)} added to customer balance.'
              : 'Order delivered. Full payment received!'),
        ),
      );

      bool? sendReceipt = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Send Final Receipt?'),
          content: Text('Send delivery receipt to ${order.customerName}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Skip')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
          ],
        ),
      );

      if (sendReceipt == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparing receipt...')),
        );
        String? error = await ReceiptHelper.generateOrderAdvanceReceipt(
          orderId: order.id!,
          customerName: order.customerName,
          itemDescription: order.itemDescription,
          totalAmount: order.totalAmount,
          advancePaid: newAdvancePaid,
        );
        if (error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      }
    }
  }

  void sendOrderReceipt(OrderModel order) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing receipt...')),
    );

    String? error = await ReceiptHelper.generateOrderAdvanceReceipt(
      orderId: order.id!,
      customerName: order.customerName,
      itemDescription: order.itemDescription,
      totalAmount: order.totalAmount,
      advancePaid: order.advancePaid,
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void deleteOrderConfirm(OrderModel order) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Order?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteOrder(order.id!);
      loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: orders.isEmpty
                  ? const Center(child: Text('No orders yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        OrderModel o = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      o.customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor(o.status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusLabel(o.status),
                                      style: TextStyle(color: statusColor(o.status), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (value) {
                                      if (value == 'delete') deleteOrderConfirm(o);
                                      if (value == 'receipt') sendOrderReceipt(o);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'receipt', child: Text('Send Receipt')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(o.itemDescription, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total: SAR ${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                                  Text('Advance: SAR ${o.advancePaid.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                                  Text(
                                    'Remaining: SAR ${o.remainingAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE53E3E)),
                                  ),
                                ],
                              ),
                              if (o.status != 'delivered') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (o.status == 'pending')
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => markAsReady(o),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38A169), foregroundColor: Colors.white),
                                          child: const Text('Mark Ready'),
                                        ),
                                      ),
                                    if (o.status == 'ready') ...[
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => markAsDelivered(o),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white),
                                          child: const Text('Deliver'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
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
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddOrderScreen()),
          );
          if (result == true) {
            loadOrders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}