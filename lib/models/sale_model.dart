class Sale {
  int? id;
  int? customerId;
  double totalAmount;
  double paidAmount;
  String date;

  Sale({
    this.id,
    this.customerId,
    required this.totalAmount,
    this.paidAmount = 0,
    this.date = '',
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customer_id'],
      totalAmount: map['total_amount'],
      paidAmount: map['paid_amount'] ?? 0,
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
    };
  }
}