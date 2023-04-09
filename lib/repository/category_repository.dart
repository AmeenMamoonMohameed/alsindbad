import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

import '../models/model_location.dart';

class CategoryRepository {
  ///Load Category
  static Future<List<CategoryModel>?> loadCategory() async {
    final result = await Api.requestCategory();
    if (result.succeeded) {
      return List.from(result.data ?? []).map((item) {
        return CategoryModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }

  // ///Load Location category
  // static Future<List<LocationModel>?> loadLocation(int id) async {
  //   final result = await Api.requestLocation({"parent_id": id});
  //   if (result.succeeded) {
  //     return List.from(result.data ?? []).map((item) {
  //       return LocationModel.fromJson(item);
  //     }).toList();
  //   }
  //   AppBloc.messageCubit.onShow(result.message);
  //   return null;
  // }

  ///Load Discovery
  static Future<List<DiscoveryModel>?> loadDiscovery() async {
    final result = await Api.requestDiscovery();
    if (result.succeeded) {
      return List.from(result.data ?? []).map((item) {
        return DiscoveryModel.fromJson(item);
      }).toList();
    }
    AppBloc.messageCubit.onShow(result.message);
    return null;
  }
}
