import 'package:akarak/models/model.dart';

abstract class NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<NotificationModel> list;
  final bool canLoadMore;
  final bool loadingMore;

  NotificationsSuccess({
    required this.list,
    required this.canLoadMore,
    this.loadingMore = false,
  });
}
