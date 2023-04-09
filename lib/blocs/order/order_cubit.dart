import 'package:bloc/bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(FormLoading());

  ///Init Order data
  Future<void> initOrder(int id) async {
    final result = await OrderRepository.loadOrderForm(id);
    if (result != null) {
      emit(FormSuccess(
        orderStyle: result[0],
        orderPayment: result[1],
      ));
    }
  }

  ///Calc price
  Future<String?> calcPrice({
    required int id,
    required FormSuccess form,
  }) async {
    final params = {
      "productId": id,
      ...form.orderStyle.params,
    };
    return await OrderRepository.calcPrice(params);
  }

  ///Order
  Future<ResultApiModel> order({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String address,
    String? message,
    required FormSuccess form,
  }) async {
    final params = {
      "productId": id,
      "paymentMethod": form.orderPayment.method?.id,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "address": address,
      "memo": message,
      ...form.orderStyle.params,
    };
    return await OrderRepository.order(params);
  }
}
