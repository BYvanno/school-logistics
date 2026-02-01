class Item {
  final int id;
  final String name;
  final String? description;
  final int quantity;
  final String unit;
  final int minStockLevel;
  final String? categoryName;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    required this.minStockLevel,
    this.categoryName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      unit: json['unit'],
      minStockLevel: json['minStockLevel'],
      categoryName: json['category']?['name'],
    );
  }

  bool get isLowStock => quantity < minStockLevel;
}
