import 'package:akarak/models/model.dart';

abstract class ProfileListState {}

class ProfileListLoading extends ProfileListState {}

class ProfileListSuccess extends ProfileListState {
  final List<UserModel> list;
  final bool canLoadMore;
  final bool loadingMore;

  ProfileListSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}
