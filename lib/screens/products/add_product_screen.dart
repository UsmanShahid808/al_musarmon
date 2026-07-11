import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../db/db_helper.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController thaanCostController = TextEditingController();
  final TextEditingController numberOfThaansController = TextEditingController(text: '1');
  final TextEditingController salePerSuitController = TextEditingController(text: '240');
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController lowStockController = TextEditingController();

  double hiddenThaanLength = 23;
  double hiddenAvgPieceLength = 3;

  bool get isEditMode => widget.product != null;

  final List<int> quickPrices = [180, 200, 220, 250, 280, 300];

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.product!.name;
      thaanCostController.text = widget.product!.thaanCost.toString();
      quantityController.text = widget.product!.quantity.toString();
      lowStockController.text = widget.product!.lowStockAlert.toString();
      hiddenThaanLength = widget.product!.thaanLength;
      hiddenAvgPieceLength = widget.product!.avgPieceLength;
      salePerSuitController.text = widget.product!.salePricePerPiece.toStringAsFixed(0);
    }
  }

  void calculateTotalStock() {
    int thaans = int.tryParse(numberOfThaansController.text.trim()) ?? 0;
    double total = hiddenThaanLength * thaans;
    setState(() {
      quantityController.text = total.toStringAsFixed(1);
    });
  }

  void saveProduct() async {
    String name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return;
    }

    double thaanCost = double.tryParse(thaanCostController.text.trim()) ?? 0;
    double purchasePricePerMeter = hiddenThaanLength > 0 ? thaanCost / hiddenThaanLength : 0;

    double salePerSuit = double.tryParse(salePerSuitController.text.trim()) ?? 0;
    double salePricePerMeter = hiddenAvgPieceLength > 0 ? salePerSuit / hiddenAvgPieceLength : 0;

    if (isEditMode) {
      Product updatedProduct = widget.product!;
      updatedProduct.name = name;
      updatedProduct.thaanCost = thaanCost;
      updatedProduct.purchasePrice = purchasePricePerMeter;
      updatedProduct.salePrice = salePricePerMeter;
      updatedProduct.quantity = double.tryParse(quantityController.text.trim()) ?? 0;
      updatedProduct.lowStockAlert = double.tryParse(lowStockController.text.trim()) ?? 5;
      updatedProduct.thaanLength = hiddenThaanLength;
      updatedProduct.avgPieceLength = hiddenAvgPieceLength;
      await DBHelper.updateProduct(updatedProduct);
    } else {
      Product newProduct = Product(
        name: name,
        thaanLength: hiddenThaanLength,
        thaanCost: thaanCost,
        purchasePrice: purchasePricePerMeter,
        salePrice: salePricePerMeter,
        quantity: double.tryParse(quantityController.text.trim()) ?? 0,
        avgPieceLength: hiddenAvgPieceLength,
        lowStockAlert: double.tryParse(lowStockController.text.trim()) ?? 5,
      );
      await DBHelper.addProduct(newProduct);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Add New Product'),
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
                colors: [Color(0xFFf6d365), Color(0xFFfda085)],
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
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Product Name (e.g. Arabic Thaan - Cream)',
                        prefixIcon: Icon(Icons.label_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF6C63FF)),
                              SizedBox(width: 6),
                              Text('Purchase Details',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6C63FF))),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: thaanCostController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Total Cost of 1 Thaan (SAR)',
                              prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF262636) : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: numberOfThaansController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'How many Thaans?',
                                    prefixIcon: const Icon(Icons.numbers_rounded, size: 20),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF262636) : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: calculateTotalStock,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                child: const Text('Fill Stock'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: salePerSuitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Sale Price per Suit/Top (SAR) - usually 180-300',
                        prefixIcon: Icon(Icons.sell_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickPrices.map((price) {
                        bool selected = salePerSuitController.text == price.toString();
                        return ChoiceChip(
                          label: Text('SAR $price'),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              salePerSuitController.text = price.toString();
                            });
                          },
                          selectedColor: const Color(0xFF6C63FF),
                          labelStyle: TextStyle(color: selected ? Colors.white : null, fontSize: 12),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Total Stock (meters) - auto-filled or manual',
                        prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: lowStockController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Low Stock Alert (meters) - default 5',
                        prefixIcon: Icon(Icons.warning_amber_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveProduct,
                        icon: Icon(isEditMode ? Icons.check_rounded : Icons.save_rounded),
                        label: Text(isEditMode ? 'Update Product' : 'Save Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFfda085),
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