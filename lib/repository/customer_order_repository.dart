import 'package:flutter/material.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

class CustomerOrderRepository {
  static Future<String?> calcPrice(Map<String, dynamic> params) async {
    final response = await Api.requestPrice(params);
    if (response.succeeded) {
      return response.data['totalDisplay'];
    } else {
      ///Notify
      AppBloc.messageCubit.onShow(response.message);
    }
    return null;
  }

  static Future<List?> loadList({
    String? searchString,
    int? pageNumber,
    int? pageSize,
    SortModel? sort,
    OrderStatus? orderStatus,
    // SortModel? status,
  }) async {
    Map<String, dynamic> params = {
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "searchString": searchString,
      "orderStatus": orderStatus?.index ?? "",
    };
    if (sort != null) {
      params['orderBy'] = "${sort.field} ${sort.value}";
    }

    final response = await Api.requestCustomerOrderList(params);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return CustomerOrderModel.fromJson(item);
      }).toList();

      final listSort = List.from(response.attr?['sort'] ?? []).map((item) {
        return SortModel.fromJson(item);
      }).toList();

      return [
        list,
        response.attr['countAwaitingApproval'],
        response.pagination,
        listSort /*, listStatus*/
      ];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  static Future<int?> outStockOrder({
    required int itemId,
    required String message,
  }) async {
    Map<String, dynamic> params = {
      "itemId": itemId,
      "message": message,
    };

    final response = await Api.requestOutStockOrder(params);
    if (response.succeeded) {
      return response.data;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  static Future<CheckOutModel?> customerOrderAmount(
      {required int id}) async {
    final response = await Api.requestCustomerOrderAmount(id);
    if (response.succeeded) {
      return CheckOutModel.fromJson(response.data);
    } else {
      ///Notify
      AppBloc.messageCubit.onShow(response.message);
    }
    return null;
  }

  static Future<int?> confirmCustomerOrder({
    required int itemId,
  }) async {
    Map<String, dynamic> params = {
      "itemId": itemId,
    };

    final response = await Api.requestConfirmCustomerOrder(params);
    if (response.succeeded) {
      return response.data;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  static Future<int?> confirmRefuseRefund({
    required int orderItemId,
  }) async {
    Map<String, dynamic> params = {
      "orderItemId": orderItemId,
    };

    final response = await Api.requestConfirmRefuseRefund(params);
    if (response.succeeded) {
      return response.data;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  static Future<List?> loadDetail({int? id}) async {
    final response = await Api.requestOrderDetail(id);
    if (response.succeeded) {
      // return OrderModel.fromJson(response.data);
      return response.data != null
          ? [
              OrderModel.fromJson(response.data),
              response.data['hasUnpaidOrders'],
            ]
          : null;
    } else {
      ///Notify
      AppBloc.messageCubit.onShow(response.message);
    }
    return null;
  }

  ///add delete cart
  static Future<bool> addDeleteCart(id) async {
    final response = await Api.requestAddDeleteCart(id);
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }
}
