class Product {
  int? id;
  String name;
  double purchasePrice; // per meter, calculated internally
  double salePrice; // per meter, calculated internally from per-suit price
  double quantity;
  double avgPieceLength; // hidden default, saved per product
  double thaanLength; // hidden default, saved per product
  double thaanCost;
  double lowStockAlert;
  String createdAt;

  Product({
    this.id,
    required this.name,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.quantity = 0,
    this.avgPieceLength = 3,
    this.thaanLength = 23,
    this.thaanCost = 0,
    this.lowStockAlert = 5,
    this.createdAt = '',
  });

  int get estimatedPieces {
    if (avgPieceLength <= 0) return 0;
    return (quantity / avgPieceLength).floor();
  }

  double get salePricePerPiece => salePrice * avgPieceLength;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      avgPieceLength: (map['avg_piece_length'] as num?)?.toDouble() ?? 3,
      thaanLength: (map['thaan_length'] as num?)?.toDouble() ?? 23,
      thaanCost: (map['thaan_cost'] as num?)?.toDouble() ?? 0,
      lowStockAlert: (map['low_stock_alert'] as num?)?.toDouble() ?? 5,
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'quantity': quantity,
      'avg_piece_length': avgPieceLength,
      'thaan_length': thaanLength,
      'thaan_cost': thaanCost,
      'low_stock_alert': lowStockAlert,
    };
  }
}