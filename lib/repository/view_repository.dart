import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

class ViewsRepository {
  ///load products views
  static Future<List?> getProductsViews({
    required String from,
    required String to,
    required int pageNumber,
    required int pageSize,
    required bool byDays,
  }) async {
    Map<String, dynamic> params = {
      "from": from,
      "to": to,
      "pageNumber": pageNumber,
      "pageSize": pageSize,
    };

    final response = byDays
        ? await Api.requestProductsByDaysViews(params)
        : await Api.requestProductsByHoursViews(params);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ViewsModel.fromJson(item);
      }).toList();
      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///load total views
  static Future<TotalViewsModel?> getTotalViews() async {
    final response = await Api.requestTotalViews();

    if (response.succeeded) {
      return TotalViewsModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///load profile views
  static Future<List?> getProfileViews({
    required String from,
    required String to,
    required int pageNumber,
    required int pageSize,
    required bool byDays,
  }) async {
    Map<String, dynamic> params = {
      "from": from,
      "to": to,
      "pageNumber": pageNumber,
      "pageSize": pageSize,
    };

    final response = byDays
        ? await Api.requestProfileByDaysViews(params)
        : await Api.requestProfileByHoursViews(params);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ViewsModel.fromJson(item);
      }).toList();
      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }
}
