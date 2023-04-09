import 'package:akarak/models/model.dart';

import '../../models/model_location.dart';

enum ViewsStateType { productViews, profileViews }

abstract class ViewsState {}

class ViewsLoading extends ViewsState {}

class ViewsSuccess extends ViewsState {
  final List<ViewsModel> list;
  final bool canLoadMore;
  final bool loadingMore;
  final ViewsStateType type;
  TotalViewsModel? totalViews;

  ViewsSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
    required this.type,
    required this.totalViews,
  });
}
