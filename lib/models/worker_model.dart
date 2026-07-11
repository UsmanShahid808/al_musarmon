class Worker {
  int? id;
  String name;
  String phone;
  double balance; // positive = we owe the worker
  String createdAt;

  Worker({
    this.id,
    required this.name,
    this.phone = '',
    this.balance = 0,
    this.createdAt = '',
  });

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'balance': balance,
    };
  }
}