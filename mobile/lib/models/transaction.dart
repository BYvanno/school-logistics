class Transaction {
  final int id;
  final String type;
  final int quantity;
  final String? reason;
  final DateTime createdAt;
  final String? userName;

  Transaction({
    required this.id,
    required this.type,
    required this.quantity,
    this.reason,
    required this.createdAt,
    this.userName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      quantity: json['quantity'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['user']?['name'],
    );
  }
}
