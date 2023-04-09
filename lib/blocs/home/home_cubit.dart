import 'package:bloc/bloc.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

import '../../models/model_location.dart';
import '../../repository/repository.dart';
import '../../utils/other.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading());
  // int pageNumber = 1;
  List<HomeSectionModel> list = [];
  PaginationModel? pagination;

  Future<void> onLoad() async {
    ///Fetch API Home
    ///Set Device Token
    Application.device?.token = await UtilOther.getDeviceToken();
    // فقط للتأخير لبعد ان يتم تعيين توكين الجهاز
    if (Application.device?.token != null) {
      final response = await Api.requestHome();
      if (response.succeeded) {
        final result = await HomeRepository.load(pageNumber: 1, pageSize: 20);
        if (result != null) {
          list = result[0];
          pagination = result[1];
        }
        emit(HomeSuccess(
          list: list,
          // popularLocations: popularLocations,
          // recentProducts: recentProducts, 
        ));
      } else {
        ///Notify
        AppBloc.messageCubit.onShow(response.message);
      }
    } else {
      final response = await Api.requestHome();
      if (response.succeeded) {
        final result = await HomeRepository.load(pageNumber: 1, pageSize: 20);
        if (result != null) {
          list = result[0];
          pagination = result[1];
        }
        emit(HomeSuccess(
          list: list,
          // popularLocations: popularLocations,
          // recentProducts: recentProducts,
        ));
      } else {
        ///Notify
        AppBloc.messageCubit.onShow(response.message);
      }
    }

    // final response = await Api.requestHome();
    // if (response.succeeded) {
    //   final result = await HomeRepository.load(pageNumber: 1, pageSize: 20);
    //   if (result != null) {
    //     list = result[0];
    //     pagination = result[1];
    //   }
    //   // final homeSections =
    //   //     List.from(response.data['homeSections'] ?? []).map((item) {
    //   //   return HomeSectionModel.fromJson(item);
    //   // }).toList();

    //   // final popularLocations =
    //   //     List.from(response.data['popularLocations'] ?? []).map((item) {
    //   //   return LocationModel.fromJson(item);
    //   // }).toList();

    //   // final recentProducts =
    //   //     List.from(response.data['recentProducts'] ?? []).map((item) {
    //   //   return ProductModel.fromJson(
    //   //     item,
    //   //     setting: Application.setting,
    //   //   );
    //   // }).toList();

    //   ///Notify
    //   emit(HomeSuccess(
    //     list: list,
    //     // popularLocations: popularLocations,
    //     // recentProducts: recentProducts,
    //   ));
    // } else {
    //   ///Notify
    //   AppBloc.messageCubit.onShow(response.message);
    // }
  }
}
