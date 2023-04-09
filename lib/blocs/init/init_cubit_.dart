// import 'package:bloc/bloc.dart';
// import 'package:akarak/api/api.dart';
// import 'package:akarak/blocs/bloc.dart';
// import 'package:akarak/configs/config.dart';
// import 'package:akarak/models/model.dart';
// import '../../repository/chat_repository.dart';
// import '../../repository/repository.dart';

// class InitCubit extends Cubit<InitState> {
//   InitCubit() : super(InitLoading()) {}

//   String keyword = "";
//   int pageNumber = 1;
//   List<NotificationModel> listNotifications = [];
//   List<ChatUserModel> list = [];
//   PaginationModel? pagination;

//   List<ChatModel> chatList = [];
//   PaginationModel? chatPagination;
//   String contactId = '';
//   int chatPageNumber = 1;
//   bool enableNotification = true;
//   bool enableDeliveredMessageIndicator = true;
//   bool enableReadMessageIndicator = true;

//   void onSettingsLoad() {
//     enableNotification = Preferences.getBool(
//             "${Preferences.enableNotification}_${AppBloc.userCubit.state?.userId}") ??
//         true;
//     enableDeliveredMessageIndicator = Preferences.getBool(
//             "${Preferences.enableDeliveredMessageIndicator}_${AppBloc.userCubit.state?.userId}") ??
//         true;
//     enableReadMessageIndicator = Preferences.getBool(
//             "${Preferences.enableReadMessageIndicator}_${AppBloc.userCubit.state?.userId}") ??
//         true;
//   }

//   Future<void> onLoad({bool isChatUsers = false}) async {
//     if (AppBloc.userCubit.state == null) return;
//     onSettingsLoad();
//     pageNumber = 1;
//     if (!Application.isStartedSignalR) {
//       await AppBloc.chatSignalRCubit.build(
//           receiveNotificationFunc: receiveNotificationHandler,
//           receiveMessageFunc: receiveMessageHandler,
//           receiveReadStatusMessageFunc: receiveReadStatusMessageHandler,
//           receiveDeliveredStatusMessageFunc:
//               receiveDeliveredStatusMessageHandler);
//     }

//     ///Fetch API
//     final result = await ChatRepository.loadChatUsers(
//       keyword: keyword,
//       pageNumber: pageNumber,
//       pageSize: Application.setting.pageSize,
//       loading: list.isNotEmpty ? false : true,
//     );

//     ///Notify
//     if (result != null) {
//       if (isChatUsers) {
//         list = result[0];
//         pagination = result[1];
//         emit(InitSuccess(
//           list: list,
//           canLoadMore: (pagination?.currentPage ?? list.length) <
//               (pagination?.totalPages ?? 1),
//           loadingMore: false,
//           isOpenDrawer: false,
//           isAlerm: false,
//           isVibrate: true,
//         ));
//       } else {
//         // list = result[0];
//         // pagination = result[1];
//         if (list.isNotEmpty) {
//           Application.newMessagesCount = list
//                   .where((element) =>
//                       element.lastMessage?.fromUserId !=
//                           AppBloc.userCubit.state?.userId &&
//                       element.lastMessage?.status == Status.delivered)
//                   .length +
//               1;
//         }

//         var isAlerm = list.any((element) =>
//             element.lastMessage?.toUserId == AppBloc.userCubit.state?.userId &&
//             element.lastMessage?.status != Status.delivered &&
//             element.lastMessage?.status != Status.seen);
//         emit(InitSuccess(
//           list: list,
//           canLoadMore: (pagination?.currentPage ?? list.length) <
//               (pagination?.totalPages ?? 1),
//           loadingMore: false,
//           isOpenDrawer: isAlerm,
//           isAlerm: isAlerm,
//           isVibrate: isAlerm,
//         ));
//       }

//       if (enableDeliveredMessageIndicator) {
//         // AppBloc.chatSignalRCubit
//         //     .notifySendDeliveredStatusForAll(list
//         //         .where((element) =>
//         //             element.lastMessage != null &&
//         //             element.lastMessage!.fromUserId !=
//         //                 AppBloc.userCubit.state?.id)
//         //         .map((e) => e.lastMessage!.fromUserId)
//         //         .toList())
//         //     .ignore();

//         // await ChatRepository.sendDeliveredStatusForUsers(list
//         //     .where((element) => element.lastMessage != null)
//         //     .map((e) => e.lastMessage!.fromUserId)
//         //     .toList());
//       }
//     }
//   }

//   Future<void> onLoadMore() async {
//     pageNumber = pageNumber + 1;

//     ///Notify
//     emit(InitSuccess(
//       loadingMore: true,
//       list: list,
//       canLoadMore: pagination!.currentPage < pagination!.totalPages,
//       isOpenDrawer: false,
//       isAlerm: false,
//       isVibrate: false,
//     ));

//     final result = await ChatRepository.loadChatUsers(
//       keyword: keyword,
//       pageNumber: pageNumber,
//       pageSize: Application.setting.pageSize,
//     );
//     if (result != null) {
//       list.addAll(result[0]);
//       pagination = result[1];
//       if (list.isNotEmpty) {
//         Application.newMessagesCount = list
//                 .where((element) =>
//                     element.lastMessage?.fromUserId !=
//                         AppBloc.userCubit.state?.userId &&
//                     element.lastMessage?.status == Status.delivered)
//                 .length +
//             1;
//       }

//       if (enableDeliveredMessageIndicator) {
//         // AppBloc.chatSignalRCubit
//         //     .notifySendDeliveredStatusForAll(
//         //         list.map((e) => e.lastMessage!.fromUserId).toList())
//         //     .ignore();
//         await ChatRepository.sendDeliveredStatusForUsers(
//             list.map((e) => e.lastMessage!.fromUserId).toList());
//       }
//     }
//   }

//   Future<void> onLoadChat() async {
//     contactId = contactId;
//     if (list.any((element) =>
//         element.id == contactId &&
//         element.lastMessage?.fromUserId == AppBloc.userCubit.state?.userId &&
//         element.lastMessage?.status == Status.delivered)) {
//       list
//               .singleWhere((element) =>
//                   element.id == contactId &&
//                   element.lastMessage?.fromUserId ==
//                       AppBloc.userCubit.state?.userId)
//               .lastMessage
//               ?.status ==
//           Status.delivered;
//     }
//     chatPageNumber = 1;
//     chatPagination = null;

//     chatList = [];

//     final result = await ChatRepository.loadChat(
//       contactId: contactId,
//       pageNumber: chatPageNumber,
//       pageSize: Application.setting.pageSize,
//       loading: true,
//     );

//     ///Notify
//     if (result != null) {
//       chatList = result[0];
//       chatPagination = result[1];

//       emit(ChatSuccess(
//         list: chatList,
//         canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//       ));

//       if (enableReadMessageIndicator &&
//           chatList.any((element) =>
//               element.fromUserId != AppBloc.userCubit.state!.userId &&
//               element.status != Status.seen)) {
//         // AppBloc.chatSignalRCubit.notifySendReadStatus(contactId).ignore();
//         await ChatRepository.sendReadStatus(fromUserId: contactId);
//       }
//     }
//   }

//   Future<void> onLoadMoreChat() async {
//     chatPageNumber = chatPageNumber + 1;

//     ///Notify
//     emit(ChatSuccess(
//       loadingMore: true,
//       list: chatList,
//       canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//     ));

//     ///Fetch API
//     final result = await ChatRepository.loadChat(
//       contactId: contactId,
//       pageNumber: chatPageNumber,
//       pageSize: Application.setting.pageSize,
//       loading: false,
//     );
//     if (result != null) {
//       chatList.addAll(result[0]);
//       chatPagination = result[1];

//       ///Notify
//       emit(ChatSuccess(
//         list: chatList,
//         canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//       ));
//       // if (chatList.any((element) => element.status != Status.seen)) {
//       //   signalR.notifySendReadStatus(contactId).ignore();
//       //   await ChatRepository.sendReadStatus(fromUserId: contactId);
//       // }
//     }
//   }

//   Future<List<NotificationModel>> onLoadNotifications() async {
//     if (AppBloc.userCubit.state == null) return [];
//     onSettingsLoad();
//     if (!enableNotification) return [];
//     return await NotificationRepository.loadNotification();
//   }

//   Future<void> receiveNotificationHandler(List<dynamic>? args) async {
//     if (args![0]['userId'] != AppBloc.userCubit.state!.userId) return;

//     emit(HasNewNotification(
//       notification: NotificationModel.fromJson(args[0]),
//     ));
//   }

//   Future<void> receiveMessageHandler(List<dynamic>? args) async {
//     // for chat Tap (from me)
//     if (args![0]['toUserId'] == contactId &&
//         args[0]['fromUserId'] == AppBloc.userCubit.state!.userId) {
//       // final index = chatList
//       //     .indexWhere((element) => element.remoteId == args[0]['remoteId']);
//       // final updatedMessage = chatList[index].copyWith(
//       //   id: args[0]['id'],
//       //   remoteId: args[0]['remoteId'] ?? "",
//       //   fromUserId: args[0]['fromUserId'],
//       //   toUserId: args[0]['toUserId'],
//       //   message: args[0]['message'],
//       //   metadata: args[0]['metadata'],
//       //   createdDate: args[0]['createdDate'],
//       //   status: Status.values[args[0]['status'] ?? 1],
//       //   type: MessageType.values[args[0]['type'] ?? 4],
//       // );
//       // chatList[0] = updatedMessage;
//       // send delivered status
//       // if (chatList.any((item) => item.status != Status.seen)) {
//       //   signalR.notifySendReadStatus(args[0]['fromUserId']).ignore();
//       //   await ChatRepository.sendReadStatus(fromUserId: args[0]['fromUserId']);
//       // }
//       // notify
//       emit(ChatSuccess(
//         list: chatList,
//         canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//         loadingMore: false,
//       ));
//     }
//     // for chat Tap (To me)
//     else if ((args[0]['toUserId'] == AppBloc.userCubit.state!.userId &&
//         args[0]['fromUserId'] == contactId)) {
//       chatList.insert(
//           0,
//           ChatModel(
//               id: args[0]['id'] ?? "",
//               remoteId: args[0]['remoteId'] ?? "",
//               fromUserId: args[0]['fromUserId'],
//               toUserId: args[0]['toUserId'],
//               message: args[0]['message']));

//       // send Read status
//       if (chatList.any((item) => item.status != Status.seen)) {
//         if (enableReadMessageIndicator) {
//           await ChatRepository.sendReadStatus(
//               fromUserId: args[0]['fromUserId']);
//         } else if (enableDeliveredMessageIndicator) {
//           await ChatRepository.sendDeliveredStatus(
//               fromUserId: args[0]['fromUserId']);
//         }
//       }
//       // notify
//       emit(ChatSuccess(
//         list: chatList,
//         canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//         loadingMore: false,
//       ));
//     }

//     // for chat users list Tap & general (To me)
//     else if (list.any((item) =>
//         (item.lastMessage?.toUserId == AppBloc.userCubit.state!.userId &&
//             item.lastMessage?.fromUserId == args[0]['fromUserId']) ||
//         (item.lastMessage?.fromUserId == AppBloc.userCubit.state!.userId &&
//             item.lastMessage?.toUserId == args[0]['fromUserId']))) {
//       list
//               .singleWhere((item) =>
//                   (item.lastMessage?.fromUserId ==
//                           AppBloc.userCubit.state!.userId &&
//                       item.lastMessage?.toUserId == args[0]['fromUserId']) ||
//                   (item.lastMessage?.toUserId == AppBloc.userCubit.state!.userId &&
//                       item.lastMessage?.fromUserId == args[0]['fromUserId']))
//               .lastMessage =
//           ChatModel(
//               id: args[0]['id'] ?? "",
//               remoteId: args[0]['remoteId'] ?? "",
//               fromUserId: args[0]['fromUserId'],
//               toUserId: args[0]['toUserId'],
//               status: Status.nothing,
//               message: args[0]['message']);
//       Application.newMessagesCount += 1;
//       // send delivered status
//       if (enableDeliveredMessageIndicator &&
//           list.any((item) => item.lastMessage?.status != Status.delivered)) {
//         // AppBloc.chatSignalRCubit
//         //     .notifySendDeliveredStatus(args[0]['fromUserId'])
//         //     .ignore();
//         await ChatRepository.sendDeliveredStatusForUsers(
//             [args[0]['fromUserId']]);
//       }
//       // notify
//       if (args[0]['status'] != 0 && args[0]['status'] != 2) {
//         emit(InitSuccess(
//           list: list,
//           canLoadMore: pagination!.currentPage < pagination!.totalPages,
//           loadingMore: false,
//           isOpenDrawer: true,
//           isAlerm: true,
//           isVibrate: true,
//         ));
//       }
//     } else {
//       onLoad();
//       // send delivered status
//       if (enableDeliveredMessageIndicator &&
//           list.any((item) =>
//               item.lastMessage?.status != Status.seen &&
//               item.lastMessage?.status != Status.delivered)) {
//         // AppBloc.chatSignalRCubit
//         //     .notifySendDeliveredStatusForAll([args[0]['fromUserId']]).ignore();
//         await ChatRepository.sendDeliveredStatusForUsers(
//             [args[0]['fromUserId']]);
//       }
//       // notify
//       emit(InitSuccess(
//         list: list,
//         canLoadMore: (pagination?.currentPage ?? list.length) <
//             (pagination?.totalPages ?? 1),
//         loadingMore: false,
//         isOpenDrawer: false,
//         isAlerm: false,
//         isVibrate: false,
//       ));
//     }
//   }

//   Future<void> receiveReadStatusMessageHandler(List<dynamic>? args) async {
//     if (args?[0] == AppBloc.userCubit.state!.userId && contactId == args?[1]) {
//       chatList
//           .where((element) => element.status != Status.seen)
//           .forEach((element) {
//         if (element.fromUserId == args?[0]) {
//           chatList[chatList.indexWhere((item) => item.id == element.id)] =
//               element.copyWith(status: Status.seen);
//         }
//       });
//       if (contactId.isNotEmpty) {
//         ChatRepository.confirmReceiptStatus('R-STATUS');
//         // notify
//         emit(ReadStatusSuccess());
//       }
//     }
//   }

//   Future<void> receiveDeliveredStatusMessageHandler(List<dynamic>? args) async {
//     if (args?[0] == AppBloc.userCubit.state!.userId && contactId == args?[1]) {
//       chatList
//           .where((element) =>
//               element.status != Status.delivered &&
//               element.status != Status.seen)
//           .forEach((element) {
//         if (element.fromUserId == args?[0]) {
//           chatList[chatList.indexWhere((item) => item.id == element.id)] =
//               element.copyWith(status: Status.delivered);
//           // AppBloc.
//         }
//       });
//       // notify
//       if (contactId.isNotEmpty) {
//         ChatRepository.confirmReceiptStatus('D-STATUS');
//         // notify
//         emit(DeliveredStatusSuccess());
//       }
//     } else if (args?[0] == AppBloc.userCubit.state!.userId) {
//       // AppBloc.messageCubit.onShow('domain_not_correct');
//     }
//   }

//   Future<int?> onSave({required ChatModel message}) async {
//     // chatList.insert(
//     //     0,
//     //     ChatModel(
//     //         remoteId: message.remoteId,
//     //         fromUserId: message.fromUserId,
//     //         toUserId: message.toUserId,
//     //         message: message.message));

//     final msgId = await ChatRepository.saveMessage(message: message);
//     if (msgId == null) {
//       // for error status: null
//       final index = chatList
//           .indexWhere((element) => element.remoteId == message.remoteId);
//       final updatedMessage =
//           chatList[index].copyWith(status: null, message: "X");
//       chatList[0] = updatedMessage;
//     } else {
//       // final index = chatList
//       //     .indexWhere((element) => element.remoteId == message.remoteId);
//       // final updatedMessage =
//       //     chatList[index].copyWith(id: msgId, status: Status.sent);
//       // chatList[0] = updatedMessage;

//       chatList.insert(
//           0,
//           ChatModel(
//               id: msgId,
//               remoteId: message.remoteId,
//               fromUserId: message.fromUserId,
//               toUserId: message.toUserId,
//               message: message.message));
//       // AppBloc.chatSignalRCubit.sendMessage(
//       //     message.fromUserId,
//       //     message.toUserId,
//       //     msgId,
//       //     message.remoteId,
//       //     AppBloc.userCubit.state?.accountName ?? "",
//       //     message.message);
//     }
//     // notify
//     emit(ChatSuccess(
//       list: chatList,
//       canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//       loadingMore: false,
//     ));

//     return msgId;
//   }

//   void onEmit() {
//     emit(ChatSuccess(
//       list: chatList,
//       canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
//       loadingMore: false,
//     ));
//   }
// }
