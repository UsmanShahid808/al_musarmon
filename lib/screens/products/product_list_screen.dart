import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../db/db_helper.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    List<Product> data = await DBHelper.getAllProducts();
    setState(() {
      allProducts = data;
      filteredProducts = data;
    });
  }

  void filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void editProduct(Product p) async {
    bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen(product: p)));
    if (result == true) loadProducts();
  }

  void deleteProductConfirm(Product p) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete ${p.name}? This cannot be undone.'),
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
      await DBHelper.deleteProduct(p.id!);
      loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Products / Stock'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFf6d365), Color(0xFFfda085)]),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterProducts,
              decoration: InputDecoration(
                hintText: 'Search product name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        searchController.clear();
                        filterProducts('');
                      })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: filteredProducts.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        Product p = filteredProducts[index];
                        bool isLowStock = p.quantity <= p.lowStockAlert;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isLowStock ? const Color(0xFFE53E3E).withOpacity(0.1) : const Color(0xFFf6d365).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.checkroom_rounded, color: isLowStock ? const Color(0xFFE53E3E) : const Color(0xFFfda085)),
                            ),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('SAR ${p.salePricePerPiece.toStringAsFixed(0)}/suit • ~${p.estimatedPieces} pieces', style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${p.quantity.toStringAsFixed(1)}m',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: isLowStock ? const Color(0xFFE53E3E) : null)),
                                    if (isLowStock) const Text('Low Stock!', style: TextStyle(color: Color(0xFFE53E3E), fontSize: 10)),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) {
                                    if (value == 'edit') editProduct(p);
                                    if (value == 'delete') deleteProductConfirm(p);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
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
          bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
          if (result == true) loadProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}