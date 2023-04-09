import 'package:akarak/models/model.dart';

abstract class UserState {}

class UserLoading extends UserState {}

class UserSuccess extends UserState {
  final List<UserModel> list;
  final bool canLoadMore;
  final bool loadingMore;

  UserSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}
