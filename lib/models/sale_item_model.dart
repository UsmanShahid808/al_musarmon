class SaleItem {
  int? id;
  int saleId;
  int productId;
  String productName;
  double quantity; // ab meters mein (decimal)
  double price; // per meter price

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    this.productName = '',
    required this.quantity,
    required this.price,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: (map['quantity'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}