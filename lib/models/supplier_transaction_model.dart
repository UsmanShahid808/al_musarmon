class SupplierTransaction {
  int? id;
  int supplierId;
  String type; // 'purchase' = maal liya (hume dena badha), 'payment' = humne diya (kam hua)
  double amount;
  String note;
  String date;

  SupplierTransaction({
    this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    this.note = '',
    this.date = '',
  });

  factory SupplierTransaction.fromMap(Map<String, dynamic> map) {
    return SupplierTransaction(
      id: map['id'],
      supplierId: map['supplier_id'],
      type: map['type'],
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'type': type,
      'amount': amount,
      'note': note,
    };
  }
}