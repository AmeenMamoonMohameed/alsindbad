import 'package:akarak/models/model.dart';

import '../../models/model_location.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<HomeSectionModel> list;
  // final List<LocationModel> popularLocations;
  // final List<ProductModel> recentProducts;

  HomeSuccess({
    required this.list,
    // required this.popularLocations,
    // required this.recentProducts,
  });
}
