import 'package:akarak/models/model.dart';

abstract class CustomerOrderState {}

class CustomerOrderLoading extends CustomerOrderState {}

class CustomerOrderSuccess extends CustomerOrderState {
  final List<CustomerOrderModel> list;
  final int countAwaitingApproval;
  final bool canLoadMore;
  final bool loadingMore;

  CustomerOrderSuccess({
    required this.list,
    required this.countAwaitingApproval,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}

class OrderDetailsSuccess_ extends CustomerOrderState {
  final CustomerOrderModel? customerOrderDetails;
  final bool hasUnpaidOrders;

  OrderDetailsSuccess_({
    required this.customerOrderDetails,
    this.hasUnpaidOrders = false,
  });
}

class CalcOrderAmountSuccess_ extends CustomerOrderState {
  final CheckOutModel? calcOrderAmount;

  CalcOrderAmountSuccess_({
    required this.calcOrderAmount,
  });
}
