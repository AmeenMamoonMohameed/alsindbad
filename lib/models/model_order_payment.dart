import 'package:akarak/models/model.dart';

class OrderPaymentModel {
  bool use;
  String term;
  PaymentMethodModel? method;
  List<PaymentMethodModel> listMethod;
  List<BankAccountModel> listAccount;

  OrderPaymentModel({
    required this.use,
    required this.term,
    this.method,
    required this.listMethod,
    required this.listAccount,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    PaymentMethodModel? method;
    if (json['use'] == true) {
      method = PaymentMethodModel.fromJson(json['method']);
    }
    return OrderPaymentModel(
      use: json['use'] ?? false,
      term: json['termConditionPage'] ?? '',
      method: method,
      listMethod: List.from(json['listMethod'] ?? []).map((e) {
        return PaymentMethodModel.fromJson(e);
      }).toList(),
      listAccount: List.from(json['listAccount'] ?? []).map((e) {
        return BankAccountModel.fromJson(e);
      }).toList(),
    );
  }
}
