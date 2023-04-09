import 'package:akarak/models/model.dart';

class SlotOrderModel extends OrderStyleModel {
  SlotOrderModel({
    price,
    adult,
    children,
  }) : super(price: price, adult: adult, children: children);

  @override
  Map<String, dynamic> get params {
    return {
      'orderStyle': 'slot',
      'adult': adult,
      'children': children,
    };
  }

  factory SlotOrderModel.fromJson(Map<String, dynamic> json) {
    return SlotOrderModel(
      price: json['price'] as String,
    );
  }
}
