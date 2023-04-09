import 'package:akarak/models/model.dart';

abstract class OrderListState {}

class OrderListLoading extends OrderListState {}

class OrderListSuccess extends OrderListState {
  final List<OrderModel> list;
  final bool canLoadMore;
  final bool loadingMore;

  OrderListSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}

class OrderDetailsSuccess extends OrderListState {
  final OrderModel? orderDetails;
  final bool hasUnpaidOrders;

  OrderDetailsSuccess({
    required this.orderDetails,
    this.hasUnpaidOrders = false,
  });
}

class CkeckOutSuccess extends OrderListState {
  final CheckOutModel? checkOut;

  CkeckOutSuccess({
    required this.checkOut,
  });
}
