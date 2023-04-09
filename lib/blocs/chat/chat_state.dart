import 'package:akarak/models/model.dart';

import '../../models/model_location.dart';

abstract class ChatState {}

class ChatLoading extends ChatState {}

class ChatUserSuccess extends ChatState {
  final List<ChatUserModel> list;
  final bool canLoadMore;
  final bool loadingMore;
  final bool isOpenDrawer;
  final bool isAlerm;
  final bool isVibrate;

  ChatUserSuccess({
    required this.list,
    required this.canLoadMore,
    required this.loadingMore,
    required this.isOpenDrawer,
    required this.isAlerm,
    required this.isVibrate,
  });
}

class HasNewNotification extends ChatState {
  final NotificationModel notification;
  HasNewNotification({
    required this.notification,
  });
}

class ChatSuccess extends ChatState {
  final List<ChatModel> list;
  final bool canLoadMore;
  final bool loadingMore;
  ChatSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}

class ReadStatusSuccess extends ChatState {
  ReadStatusSuccess();
}

class DeliveredStatusSuccess extends ChatState {
  DeliveredStatusSuccess();
}

class NewReactionSuccess extends ChatState {
  final int messageId;
  final List<String>? reactedUserIds;
  final List<String>? reactions;

  NewReactionSuccess(
      {required this.messageId, this.reactedUserIds, this.reactions});
}
