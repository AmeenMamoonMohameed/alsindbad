import 'package:akarak/models/model.dart';

class CheckOutModel {
  final int id;
  final double amount;
  final double totalDiscount;
  final double totalShipping;
  final String totalShippingDestance;
  final double totalTax;
  final String totalDisplay;
  final double total;
  final String currencyCode;
  final AddressModel? address;
  final List<OrderItemModel> orderItems;

  CheckOutModel({
    required this.id,
    required this.amount,
    required this.totalDiscount,
    required this.totalShipping,
    required this.totalShippingDestance,
    required this.totalTax,
    required this.totalDisplay,
    required this.total,
    required this.currencyCode,
    required this.address,
    required this.orderItems,
  });

  factory CheckOutModel.fromJson(Map<String, dynamic> json) {
    return CheckOutModel(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      totalDiscount: double.parse(json['totalDiscount'].toString()),
      totalShipping: double.parse(json['totalShipping'].toString()),
      totalShippingDestance: json['totalShippingDestance'],
      totalTax: double.parse(json['totalTax'].toString()),
      totalDisplay: json['totalDisplay'],
      total: double.parse(json['total'].toString()),
      currencyCode: json['currencyCode'],
      address: json['shipppingAddress'] != null
          ? AddressModel.fromJson(json['shipppingAddress'])
          : null,
      orderItems: List.from(json['orderItems'] ?? []).map((item) {
        return OrderItemModel.fromJson(item);
      }).toList(),
    );
  }
}
