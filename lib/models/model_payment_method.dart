class PaymentMethodModel {
  final String id;
  final String? name;
  final String? description;
  final String? instruction;

  PaymentMethodModel({
    required this.id,
    this.name,
    this.description,
    this.instruction,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      name: json['name'],
      description: json['desc'],
      instruction: json['instruction'],
    );
  }
}
