import 'package:bloc/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit() : super(OrderListLoading());

  int pageNumber = 1;
  List<OrderModel> list = [];
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
    final result = await OrderRepository.loadList(
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      sort: sort,
      orderStatus: orderStatus,
      searchString: searchString,
    );
    if (result != null) {
      list = result[0];
      pagination = result[1];
      if (sortOption.isEmpty) {
        sortOption = result[2];
      }
      // if (statusOption.isEmpty) {
      //   statusOption = result[3];
      // }

      ///Notify
      emit(OrderListSuccess(
        list: list,
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
    emit(OrderListSuccess(
      loadingMore: true,
      list: list,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
    ));

    ///Fetch API
    final result = await OrderRepository.loadList(
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      sort: sort,
      orderStatus: orderStatus,
      searchString: searchString,
    );

    if (result != null) {
      list.addAll(result[0]);
      pagination = result[1];

      ///Notify
      emit(OrderListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadDetail({int? id}) async {
    ///Fetch API
    final result = await OrderRepository.loadDetail(id: id);
    if (result != null) {
      emit(OrderDetailsSuccess(
        orderDetails: result[0],
        hasUnpaidOrders: result[1],
      ));
    }
  }

  Future<bool> onInitOrder({required List<OrderItemModel> list}) async {
    return await OrderRepository.initOrder(list: list);
  }

  Future<void> onCheckOut({required int id}) async {
    ///Fetch API
    final result = await OrderRepository.checkOut(id: id);
    emit(CkeckOutSuccess(
      checkOut: result,
    ));
  }

  Future<bool> onSetShippingAddress(
      {required int orderId, required int addressId}) async {
    ///Fetch API
    return await OrderRepository.setShippingAddress(
        orderId: orderId, addressId: addressId);
    // emit(CkeckOutSuccess(
    //   checkOut: result,
    // ));
  }

  Future<void> onCancel(id) async {
    final result = await OrderRepository.cancel(id);
    if (result) {
      list.removeWhere((element) => element.orderId == id);
      emit(OrderListSuccess(
        list: list,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onCancelItem(orderId, orderItemId) async {
    final result = await OrderRepository.cancelItem(orderId, orderItemId);
    if (result) {
      // list.removeWhere((element) => element.orderId == id);
      onLoadDetail();
      // emit(OrderListSuccess(
      //   list: list,
      //   canLoadMore: pagination!.currentPage < pagination!.totalPages,
      // ));
    }
  }
}
