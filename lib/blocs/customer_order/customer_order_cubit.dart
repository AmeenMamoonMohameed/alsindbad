import 'package:bloc/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import 'cubit.dart';

class CustomerOrderCubit extends Cubit<CustomerOrderState> {
  CustomerOrderCubit() : super(CustomerOrderLoading());

  int pageNumber = 1;
  List<CustomerOrderModel> list = [];
  int countAwaitingApproval = 0;
  PaginationModel? pagination;
  SortModel? sort;
  SortModel? status;
  List<SortModel> sortOption = [];
  List<SortModel> statusOption = [];

  Future<void> onLoad({
    SortModel? sort,
    SortModel? status,
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
      // status: status,
      searchString: searchString,
    );
    if (result != null) {
      list = result[0];
      countAwaitingApproval = result[1];
      pagination = result[2];
      if (sortOption.isEmpty) {
        sortOption = result[3];
      }
      // if (statusOption.isEmpty) {
      //   statusOption = result[3];
      // }

      ///Notify
      emit(CustomerOrderSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onLoadMore({
    SortModel? sort,
    SortModel? status,
    String? searchString,
    OrderStatus orderStatus = OrderStatus.awaitingApproval,
  }) async {
    pageNumber = pageNumber + 1;

    ///Notify
    emit(CustomerOrderSuccess(
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
      // status: status,
      searchString: searchString,
    );

    if (result != null) {
      list.addAll(result[0]);
      // countAwaitingApproval = result[1];
      pagination = result[2];

      ///Notify
      emit(CustomerOrderSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }

  Future<void> onOutStockOrder({
    required int itemId,
    required String message,
  }) async {
    final result = await CustomerOrderRepository.outStockOrder(
        itemId: itemId, message: message);
    if (result != null) {
      emit(CustomerOrderSuccess(
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
      emit(CustomerOrderSuccess(
        list: list,
        countAwaitingApproval: countAwaitingApproval,
        canLoadMore: pagination!.currentPage < pagination!.totalPages,
      ));
    }
  }
}
