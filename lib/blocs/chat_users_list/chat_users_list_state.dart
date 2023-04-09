import 'package:akarak/models/model.dart';

abstract class ChatUsersListState {}

class ChatUsersListLoading extends ChatUsersListState {}

class ChatUsersListSuccess extends ChatUsersListState {
  final List<ChatUserModel> list;
  final bool canLoadMore;
  final bool loadingMore;
  ChatUsersListSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}

class SeenMessageSuccess extends ChatUsersListState {
  final String userId;
  SeenMessageSuccess({
    required this.userId,
  });
}
