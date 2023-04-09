import 'package:akarak/models/model.dart';

import '../../models/model_location.dart';

abstract class RealTimeState {}

class RealTimeLoading extends RealTimeState {}

class RealTimeSuccess extends RealTimeState {
  final List<ChatUserModel> list;
  final bool canLoadMore;
  final bool loadingMore;
  final bool isOpenDrawer;
  final bool isAlerm;
  final bool isVibrate;

  RealTimeSuccess({
    required this.list,
    required this.canLoadMore,
    required this.loadingMore,
    required this.isOpenDrawer,
    required this.isAlerm,
    required this.isVibrate,
  });
}

class NotifyNewView extends RealTimeState {
  NotifyNewView();
}

class NotifyNewAddress extends RealTimeState {
  NotifyNewAddress();
}

class NotifyNewOrder extends RealTimeState {
  NotifyNewOrder();
}

class NotifyNewShoppingCart extends RealTimeState {
  NotifyNewShoppingCart();
}

class NotifyCustomerOrder extends RealTimeState {
  NotifyCustomerOrder();
}

class NotifyNewReview extends RealTimeState {
  final double rating;

  NotifyNewReview({required this.rating});
}

// class ChatSuccess extends RealTimeState {
//   final List<ChatModel> list;
//   final bool canLoadMore;
//   final bool loadingMore;
//   ChatSuccess({
//     required this.list,
//     required this.canLoadMore,
//     this.loadingMore = false,
//   });
// }

// class ReadStatusSuccess extends RealTimeState {
//   ReadStatusSuccess();
// }

// class DeliveredStatusSuccess extends RealTimeState {
//   DeliveredStatusSuccess();
// }
