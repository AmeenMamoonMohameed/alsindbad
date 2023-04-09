import 'package:bloc/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class CustomerOrderListCubit extends Cubit<CustomerOrderListState> {
  CustomerOrderListCubit() : super(CustomerOrderListLoading());

  int pageNumber = 1;
  List<CustomerOrderModel> list = [];
  int countAwaitingApproval = 0;
  PaginationModel? pagination;
  SortModel? sort;
  SortModel? status;
  List<SortModel> sortOption = [
    SortModel(
      name: "lasted",
      value: "descending",
      field: "CreatedOn",
    ),
    SortModel(
      name: "oldest",
      value: "ascending",
      field: "CreatedOn",
    ),
  ];
  List<SortModel> statusOption = [
    SortModel(
      name: 'all',
      value: null,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.order.name,
      value: OrderStatus.order.index,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.awaitingApproval.name,
      value: OrderStatus.awaitingApproval.index,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.outStock.name,
      value: OrderStatus.outStock.index,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.progress.name,
      value: OrderStatus.progress.index,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.onShipping.name,
      value: OrderStatus.onShipping.index,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.finished.name,
      value: OrderStatus.finished.index,
      field: "Status",
    ),
    SortModel(
      name: OrderStatus.returned.name,
      value: OrderStatus.returned.index,
      field: "Status",
    ),
  ];

  Future<void> onLoad({
    SortModel? sort,
    String? searchString,
    OrderStatus? orderStatus,
  }) async {
    pageNumber = 1;

    ///Fetch API
    final result = await CustomerOrderRepository.loadList(
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      sort: sort,
      orderStatus: orderStatus,
      searchString: searchString,
    );
    if (result != null) {
      list = result[0];
      countAwaitingApproval = result[1];
      pagination = result[2];
      if (sortOption.isEmpty) {
        sortOption = result[3];
      }

      ///Notify
      emit(CustomerOrderListSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadMore({
    SortModel? sort,
    String? searchString,
    OrderStatus? orderStatus,
  }) async {
    pageNumber = pageNumber + 1;

    ///Notify
    emit(CustomerOrderListSuccess(
      loadingMore: true,
      list: list,
      countAwaitingApproval: countAwaitingApproval,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
    ));

    ///Fetch API
    final result = await CustomerOrderRepository.loadList(
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      sort: sort,
      orderStatus: orderStatus,
      searchString: searchString,
    );

    if (result != null) {
      list.addAll(result[0]);
      // countAwaitingApproval = result[1];
      pagination = result[2];

      ///Notify
      emit(CustomerOrderListSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onGetCustomerOrderAmount({required int id}) async {
    ///Fetch API
    final result = await CustomerOrderRepository.customerOrderAmount(id: id);
    emit(CustomerOrderAmountSuccess(
      customerOrderAmount: result,
    ));
  }

  Future<void> onOutStockOrder({
    required int itemId,
    required String message,
  }) async {
    final result = await CustomerOrderRepository.outStockOrder(
        itemId: itemId, message: message);
    if (result != null) {
      // onLoad();
      list.singleWhere((element) => element.id == result).status =
          OrderStatus.outStock;
      countAwaitingApproval = countAwaitingApproval - 1;
      emit(CustomerOrderListSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onConfirmCustomerOrder({
    required int itemId,
  }) async {
    final result =
        await CustomerOrderRepository.confirmCustomerOrder(itemId: itemId);
    if (result != null) {
      // onLoad();
      list.singleWhere((element) => element.id == result).status =
          OrderStatus.progress;
      countAwaitingApproval = countAwaitingApproval - 1;
      emit(CustomerOrderListSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  // Future<void> onLoadDetail({int? id}) async {
  //   ///Fetch API
  //   final result = await CustomerOrderRepository.loadDetail(id: id);
  //   emit(OrderDetailsSuccess_(
  //     orderDetails: result == null ? null : result[0],
  //     hasUnpaidOrders: result == null ? false : result[1],
  //   ));
  // }

  Future<void> onCancel(id) async {
    final result = await OrderRepository.cancel(id);
    if (result) {
      list.removeWhere((element) => element.orderId == id);
      emit(CustomerOrderListSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }
}
