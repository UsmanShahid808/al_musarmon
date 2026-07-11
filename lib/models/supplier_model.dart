class Supplier {
  int? id;
  String name;
  String phone;
  String address;
  double balance; // positive = hume unko dena hai
  String createdAt;

  Supplier({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.balance = 0,
    this.createdAt = '',
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'balance': balance,
    };
  }
}