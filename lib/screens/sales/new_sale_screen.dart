import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/customer_model.dart';
import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';
import '../../db/db_helper.dart';
import '../../utils/receipt_helper.dart';
import '../../utils/whatsapp_helper.dart';
import '../customers/customer_picker_screen.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  List<Product> allProducts = [];
  List<SaleItem> cartItems = [];
  Customer? selectedCustomer;

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

  double get totalAmount {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void showAddItemDialog(Product product) {
    final TextEditingController piecesController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int pieces = int.tryParse(piecesController.text.trim()) ?? 1;
            double calculatedMeters = pieces * product.avgPieceLength;
            double calculatedPrice = calculatedMeters * product.salePrice;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              title: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${product.quantity.toStringAsFixed(1)}m • ~${product.estimatedPieces} pieces',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('How many Suits/Tops?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: piecesController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF262636) : const Color(0xFFF6F7FB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38A169).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Meters', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('${calculatedMeters.toStringAsFixed(2)} m',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Price', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('SAR ${calculatedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38A169), fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    int pcs = int.tryParse(piecesController.text.trim()) ?? 0;

                    if (pcs <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid number')),
                      );
                      return;
                    }

                    double meters = pcs * product.avgPieceLength;

                    if (meters > product.quantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Not enough stock available (only ${product.quantity.toStringAsFixed(1)}m left)')),
                      );
                      return;
                    }

                    setState(() {
                      cartItems.add(SaleItem(
                        saleId: 0,
                        productId: product.id!,
                        productName: '${product.name} ($pcs suit)',
                        quantity: meters,
                        price: product.salePrice,
                      ));
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void completeSale() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some items first')),
      );
      return;
    }

    Sale newSale = Sale(
      customerId: selectedCustomer?.id,
      totalAmount: totalAmount,
      paidAmount: totalAmount,
    );
    int saleId = await DBHelper.addSale(newSale);

    for (var item in cartItems) {
      await DBHelper.addSaleItem(SaleItem(
        saleId: saleId,
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
      ));

      Product product = allProducts.firstWhere((p) => p.id == item.productId);
      double newQty = product.quantity - item.quantity;
      await DBHelper.updateProductQuantity(item.productId, newQty);
    }

    List<SaleItem> savedItems = List.from(cartItems);
    double savedTotal = totalAmount;
    Customer? savedCustomer = selectedCustomer;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale completed!')),
    );

    showAfterSaleOptions(saleId, savedItems, savedTotal, savedCustomer);
  }

  void showAfterSaleOptions(int saleId, List<SaleItem> items, double total, Customer? customer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Sale Completed! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: SAR ${total.toStringAsFixed(0)}'),
              const SizedBox(height: 10),
              if (customer != null && customer.phone.isNotEmpty)
                const Text('Send receipt to customer?', textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              },
              child: const Text('Skip'),
            ),
            if (customer != null && customer.phone.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  String message = 'مرحباً ${customer.name}،\n'
                      'تم إتمام عملية الشراء الخاصة بك.\n'
                      'المبلغ الإجمالي: ${total.toStringAsFixed(0)} ريال سعودي\n'
                      'شكراً لتعاملكم معنا - المسرمون';
                  await WhatsAppHelper.sendMessage(context, customer.phone, message);
                },
                icon: const Icon(Icons.chat),
                label: const Text('Open WhatsApp'),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preparing receipt...')),
                );

                String? error = await ReceiptHelper.generateAndShareReceipt(
                  saleId: saleId,
                  items: items,
                  totalAmount: total,
                  customerName: customer?.name ?? 'Walk-in Customer',
                );

                if (error != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  }
                } else {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Send Receipt'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                Customer? picked = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerPickerScreen()),
                );
                if (picked != null) {
                  setState(() {
                    selectedCustomer = picked.id == -1 ? null : picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF6C63FF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedCustomer?.name ?? 'Walk-in Customer (tap to select)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Available Products', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: allProducts.isEmpty
                        ? const Center(child: Text('Add products first'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: allProducts.length,
                            itemBuilder: (context, index) {
                              Product p = allProducts[index];
                              bool lowStock = p.quantity <= p.lowStockAlert;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (lowStock ? Colors.red : const Color(0xFF6C63FF)).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.checkroom_rounded,
                                        color: lowStock ? Colors.red : const Color(0xFF6C63FF), size: 20),
                                  ),
                                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  subtitle: Text(
                                    'SAR ${p.salePrice.toStringAsFixed(0)}/m • ${p.quantity.toStringAsFixed(1)}m left',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                                  ),
                                  onTap: () => showAddItemDialog(p),
                                ),
                              );
                            },
                          ),
                  ),

                  Container(height: 1, color: Colors.grey.withOpacity(0.2)),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Cart (${cartItems.length})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: cartItems.isEmpty
                        ? const Center(child: Text('Cart is empty'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              SaleItem item = cartItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38A169).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF38A169), size: 20),
                                  ),
                                  title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  subtitle: Text('${item.quantity.toStringAsFixed(2)}m × SAR ${item.price.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 11)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'SAR ${(item.quantity * item.price).toStringAsFixed(0)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            cartItems.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            Text(
                              'SAR ${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF38A169)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: completeSale,
                            icon: const Icon(Icons.check_circle_outline_rounded),
                            label: const Text('Complete Sale', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38A169),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
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