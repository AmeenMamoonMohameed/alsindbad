import 'dart:convert';

import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

class NotificationRepository {
  /// Load Notification
  static Future<List?> load({
    int? pageNumber,
    int? pageSize,
  }) async {
    Map<String, dynamic> params = {
      "pageNumber": pageNumber,
      "pageSize": pageSize,
    };

    final result = await Api.requestLoadNotification(params);
    if (result.succeeded) {
      final list = List.from(result.data ?? []).map((item) {
        return NotificationModel.fromJson(item);
      }).toList();

      return [list, result.pagination];
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }
}
