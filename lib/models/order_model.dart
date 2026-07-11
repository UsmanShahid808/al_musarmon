class OrderModel {
  int? id;
  int customerId;
  String customerName; // UI ke liye, DB mein save nahi hota
  String itemDescription;
  double totalAmount;
  double advancePaid;
  String status; // 'pending', 'ready', 'delivered'
  String orderDate;
  String readyDate;

  OrderModel({
    this.id,
    required this.customerId,
    this.customerName = '',
    required this.itemDescription,
    required this.totalAmount,
    this.advancePaid = 0,
    this.status = 'pending',
    this.orderDate = '',
    this.readyDate = '',
  });

  double get remainingAmount => totalAmount - advancePaid;

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      customerId: map['customer_id'],
      itemDescription: map['item_description'],
      totalAmount: (map['total_amount'] as num).toDouble(),
      advancePaid: (map['advance_paid'] as num?)?.toDouble() ?? 0,
      status: map['status'] ?? 'pending',
      orderDate: map['order_date'] ?? '',
      readyDate: map['ready_date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'item_description': itemDescription,
      'total_amount': totalAmount,
      'advance_paid': advancePaid,
      'status': status,
      'ready_date': readyDate,
    };
  }
}