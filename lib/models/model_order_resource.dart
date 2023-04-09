class OrderResourceModel {
  final int id;
  final String name;
  final int quantity;
  final num total;

  OrderResourceModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.total,
  });

  factory OrderResourceModel.fromJson(Map<String, dynamic> json) {
    return OrderResourceModel(
      id: json['id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? '',
      total: json['total'] ?? '',
    );
  }
}
