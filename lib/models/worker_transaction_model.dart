class WorkerTransaction {
  int? id;
  int workerId;
  String type; // 'work' = work done (we owe more), 'payment' = we paid worker
  double amount;
  String note; // e.g. "Stitched 5 tops"
  String date;

  WorkerTransaction({
    this.id,
    required this.workerId,
    required this.type,
    required this.amount,
    this.note = '',
    this.date = '',
  });

  factory WorkerTransaction.fromMap(Map<String, dynamic> map) {
    return WorkerTransaction(
      id: map['id'],
      workerId: map['worker_id'],
      type: map['type'],
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worker_id': workerId,
      'type': type,
      'amount': amount,
      'note': note,
    };
  }
}