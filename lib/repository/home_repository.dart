import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

import '../models/model_location.dart';

class HomeRepository {
  ///Load Category
  static Future<List?> load(
      {required int pageNumber, required int pageSize}) async {
    final params = {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    final response = await Api.requestHomeSections(params);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return HomeSectionModel.fromJson(item);
      }).toList();
      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }
}
