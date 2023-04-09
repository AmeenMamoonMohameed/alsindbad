import 'package:akarak/models/model.dart';

abstract class CustomerOrderListState {}

class CustomerOrderListLoading extends CustomerOrderListState {}

class CustomerOrderListSuccess extends CustomerOrderListState {
  final List<CustomerOrderModel> list;
  final int countAwaitingApproval;
  final bool canLoadMore;
  final bool loadingMore;

  CustomerOrderListSuccess({
    required this.list,
    required this.countAwaitingApproval,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}

class CustomerOrderAmountSuccess extends CustomerOrderListState {
  final CheckOutModel? customerOrderAmount;

  CustomerOrderAmountSuccess({
    required this.customerOrderAmount,
  });
}
