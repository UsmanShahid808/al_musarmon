class TransactionModel {
  int? id;
  int customerId;
  String type; // 'debit' = customer ne udhaar liya, 'credit' = customer ne paisa wapas kiya
  double amount;
  String note;
  String date;

  TransactionModel({
    this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note = '',
    this.date = '',
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      customerId: map['customer_id'],
      type: map['type'],
      amount: map['amount'],
      note: map['note'] ?? '',
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'type': type,
      'amount': amount,
      'note': note,
    };
  }
}