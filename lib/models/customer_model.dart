class Customer {
  int? id;
  String name;
  String phone;
  String address;
  double balance;
  String createdAt;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.balance = 0,
    this.createdAt = '',
  });

  // Map se Customer object banane ke liye (database se data read karte waqt)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      balance: map['balance'],
      createdAt: map['created_at'],
    );
  }

  // Customer object ko Map mein convert karne ke liye (database mein save karte waqt)
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