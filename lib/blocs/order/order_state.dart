import 'package:akarak/models/model.dart';

abstract class OrderState {}

class FormLoading extends OrderState {}

class FormSuccess extends OrderState {
  final OrderStyleModel orderStyle;
  final OrderPaymentModel orderPayment;

  FormSuccess({
    required this.orderStyle,
    required this.orderPayment,
  });
}
