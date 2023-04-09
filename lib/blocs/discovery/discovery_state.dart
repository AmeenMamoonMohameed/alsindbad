import 'package:akarak/models/model.dart';

abstract class DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoverySuccess extends DiscoveryState {
  final List<ProductModel> list;
  final bool canLoadMore;
  final bool loadingMore;

  DiscoverySuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}
