import 'package:akarak/blocs/app_bloc.dart';
import 'package:akarak/configs/preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/repository/repository.dart';

import '../../configs/application.dart';
import '../../models/model_chat_status.dart';
import '../../packages/chat/models/message.dart';
import 'cubit.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatLoading());
  String keyword = "";
  int pageNumber = 1;
  List<NotificationModel> listNotifications = [];
  List<ChatUserModel> list = [];
  PaginationModel? pagination;

  List<ChatModel> chatList = [];
  PaginationModel? chatPagination;
  String contactId = '';
  int chatId = 0;
  String? chatToken = '';
  int chatPageNumber = 1;
  bool enableNotification = true;
  bool enableDeliveredMessageIndicator = true;
  bool enableReadMessageIndicator = true;

  void onSettingsLoad() {
    enableNotification = Preferences.getBool(
            "${Preferences.enableNotification}_${AppBloc.userCubit.state?.userId}") ??
        true;
    enableDeliveredMessageIndicator = Preferences.getBool(
            "${Preferences.enableDeliveredMessageIndicator}_${AppBloc.userCubit.state?.userId}") ??
        true;
    enableReadMessageIndicator = Preferences.getBool(
            "${Preferences.enableReadMessageIndicator}_${AppBloc.userCubit.state?.userId}") ??
        true;
  }

  Future<void> onLoad({bool isChatUsers = false}) async {
    if (AppBloc.userCubit.state == null) return;
    onSettingsLoad();
    pageNumber = 1;

    ///Fetch API
    final result = await ChatRepository.loadChatUsers(
      keyword: keyword,
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
      loading: list.isNotEmpty ? false : true,
    );

    ///Notify
    if (result != null) {
      if (isChatUsers) {
        list = result[0];
        pagination = result[1];
        emit(ChatUserSuccess(
          list: list,
          canLoadMore: (pagination?.currentPage ?? list.length) <
              (pagination?.totalPages ?? 1),
          loadingMore: false,
          isOpenDrawer: false,
          isAlerm: false,
          isVibrate: true,
        ));
      } else {
        // list = result[0];
        // pagination = result[1];
        if (list.isNotEmpty) {
          Application.newMessagesCount = list
                  .where((element) =>
                      element.lastMessage?.fromUserId !=
                          AppBloc.userCubit.state?.userId &&
                      element.lastMessage?.status == Status.delivered)
                  .length +
              1;
        }

        var isAlerm = list.any((element) =>
            element.lastMessage?.contactId == AppBloc.userCubit.state?.userId &&
            element.lastMessage?.status != Status.delivered &&
            element.lastMessage?.status != Status.seen);
        emit(ChatUserSuccess(
          list: list,
          canLoadMore: (pagination?.currentPage ?? list.length) <
              (pagination?.totalPages ?? 1),
          loadingMore: false,
          isOpenDrawer: isAlerm,
          isAlerm: isAlerm,
          isVibrate: isAlerm,
        ));
      }
    }
  }

  Future<void> onLoadMore() async {
    pageNumber = pageNumber + 1;

    ///Notify
    emit(ChatUserSuccess(
      loadingMore: true,
      list: list,
      canLoadMore: pagination!.currentPage < pagination!.totalPages,
      isOpenDrawer: false,
      isAlerm: false,
      isVibrate: false,
    ));

    final result = await ChatRepository.loadChatUsers(
      keyword: keyword,
      pageNumber: pageNumber,
      pageSize: Application.setting.pageSize,
    );
    if (result != null) {
      list.addAll(result[0]);
      pagination = result[1];
      if (list.isNotEmpty) {
        Application.newMessagesCount = list
                .where((element) =>
                    element.lastMessage?.fromUserId !=
                        AppBloc.userCubit.state?.userId &&
                    element.lastMessage?.status == Status.delivered)
                .length +
            1;
      }

      if (enableDeliveredMessageIndicator) {
        await ChatRepository.sendDeliveredStatusForUsers(
            list.map((e) => e.lastMessage!.chatId).toList());
      }
    }
  }

  Future<void> onLoadChat() async {
    if (list.any((element) =>
        element.userId == contactId &&
        element.chatId == chatId &&
        element.lastMessage?.fromUserId == AppBloc.userCubit.state?.userId &&
        element.lastMessage?.status == Status.delivered)) {
      list
              .singleWhere((element) =>
                  element.userId == contactId &&
                  element.chatId == chatId &&
                  element.lastMessage?.fromUserId ==
                      AppBloc.userCubit.state?.userId)
              .lastMessage
              ?.status ==
          Status.delivered;
    }
    chatPageNumber = 1;
    chatPagination = null;

    chatList = [];

    final result = await ChatRepository.loadChat(
      chatId: chatId,
      contactId: contactId,
      pageNumber: chatPageNumber,
      pageSize: Application.setting.pageSize,
      loading: true,
    );

    ///Notify
    if (result != null) {
      chatList = result[0];
      chatPagination = result[1];
      chatToken = result[2];
      if (chatId == 0 && chatList.isNotEmpty) {
        chatId = chatList.first.chatId;
      }
      emit(ChatSuccess(
        list: chatList,
        canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
      ));

      if (enableReadMessageIndicator &&
          chatList.any((element) =>
              element.fromUserId != AppBloc.userCubit.state!.userId &&
              element.status != Status.seen)) {
        await ChatRepository.sendReadStatus(chatId: chatList.first.chatId);
      }
    }
  }

  Future<void> onLoadMoreChat() async {
    chatPageNumber = chatPageNumber + 1;

    ///Notify
    emit(ChatSuccess(
      loadingMore: true,
      list: chatList,
      canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
    ));

    ///Fetch API
    final result = await ChatRepository.loadChat(
      chatId: chatId,
      contactId: contactId,
      pageNumber: chatPageNumber,
      pageSize: Application.setting.pageSize,
      loading: false,
    );
    if (result != null) {
      chatList.addAll(result[0]);
      chatPagination = result[1];

      ///Notify
      emit(ChatSuccess(
        list: chatList,
        canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
      ));
      // if (chatList.any((element) => element.status != Status.seen)) {
      //   signalR.notifySendReadStatus(contactId).ignore();
      //   await ChatRepository.sendReadStatus(fromUserId: contactId);
      // }
    }
  }

  Future<List<ChatModel>?> onLoadMoreChatTest() async {
    chatPageNumber = chatPageNumber + 1;
    if (chatPagination!.currentPage >= chatPagination!.totalPages) return null;

    ///Fetch API
    final result = await ChatRepository.loadChat(
      chatId: chatId,
      contactId: contactId,
      pageNumber: chatPageNumber,
      pageSize: Application.setting.pageSize,
      loading: false,
    );
    if (result != null) {
      chatList.addAll(result[0]);
      chatPagination = result[1];
      // if (chatList.any((element) => element.status != Status.seen)) {
      //   signalR.notifySendReadStatus(contactId).ignore();
      //   await ChatRepository.sendReadStatus(fromUserId: contactId);
      // }
      return result[0];
    }
    return null;
  }

  Future<int?> onSave(
      {required ChatModel message, Function(num)? progress}) async {
    final msg =
        await ChatRepository.saveMessage(message: message, progress: progress);
    if (msg == null) {
      if (chatId == 0) chatId = msg!.chatId;
      // for error status: null
      final index = chatList
          .indexWhere((element) => element.remoteId == message.remoteId);
      final updatedMessage =
          chatList[index].copyWith(status: null, message: "X");
      chatList[index] = updatedMessage;
    } else {
      chatList.insert(
          0,
          ChatModel(
              id: msg.id,
              chatId: msg.chatId,
              remoteId: message.remoteId,
              fromUserId: message.fromUserId,
              contactId: message.contactId,
              message: message.message,
              deliveredUsers: message.deliveredUsers,
              readedUsers: message.readedUsers));
    }
    // notify
    emit(ChatSuccess(
      list: chatList,
      canLoadMore: chatPagination == null
          ? false
          : chatPagination!.currentPage < chatPagination!.totalPages,
      loadingMore: false,
    ));

    return msg?.id;
  }

  Future<bool> onSendReaction(
      {required int messageId, required String emoji}) async {
    final result = await ChatRepository.sendReaction(
        chatId: chatId, messageId: messageId, emoji: emoji);
    if (result != null) {
      final index = chatList.indexWhere((element) => element.id == messageId);
      final updatedMessage = chatList[index].copyWith(
          reactions: List.from(result['reactions']),
          reactedUserIds: List.from(result['reactedUserIds']));
      chatList[index] = updatedMessage;
      return true;
    }
    return false;
  }

  void onEmit() {
    emit(ChatSuccess(
      list: chatList,
      canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
      loadingMore: false,
    ));
  }

  Future<void> onInit({bool isChatUsers = false}) async {
    // New Msg
    AppBloc.realTimeCubit.onNotifyNewMsg = (notify) async {
      var data = ChatModel.fromJson(notify.data);
      if (data.chatId == chatId) {
        chatList.insert(
            0,
            ChatModel(
                id: data.id,
                chatId: data.chatId,
                remoteId: data.remoteId,
                fromUserId: data.fromUserId,
                contactId: data.contactId,
                message: data.message,
                type: data.type,
                status: Status.delivered,
                deliveredUsers: data.deliveredUsers,
                createdDate: data.createdDate,
                readedUsers: data.readedUsers));

        // send Read status
        if (chatList.any((item) => item.status != Status.seen)) {
          if (enableReadMessageIndicator) {
            await ChatRepository.sendReadStatus(chatId: data.chatId);
          } else if (enableDeliveredMessageIndicator) {
            await ChatRepository.sendDeliveredStatus(chatId: data.chatId);
          }
        }

        // notify
        emit(ChatSuccess(
          list: chatList,
          canLoadMore: chatPagination!.currentPage < chatPagination!.totalPages,
          loadingMore: false,
        ));
      } else {
        if (enableDeliveredMessageIndicator) {
          await ChatRepository.sendDeliveredStatus(chatId: data.chatId);
        }
      }
      if ((chatList.isEmpty || chatList.first.chatId != chatId) &&
          list.any((element) => element.chatId == data.chatId)) {
        list
                .singleWhere((element) => element.chatId == data.chatId)
                .lastMessage =
            ChatModel(
                id: data.id,
                chatId: data.chatId,
                remoteId: data.remoteId,
                fromUserId: data.fromUserId,
                contactId: data.contactId,
                status: Status.sending,
                message: data.message,
                createdDate: data.createdDate,
                deliveredUsers: data.deliveredUsers,
                readedUsers: data.readedUsers);
        emit(ChatUserSuccess(
          list: list,
          canLoadMore: (pagination?.currentPage ?? list.length) <
              (pagination?.totalPages ?? 1),
          loadingMore: false,
          isOpenDrawer: false,
          isAlerm: false,
          isVibrate: true,
        ));
      } else if (chatList.isEmpty || chatList.first.chatId != chatId) {
        // اذا اتصل بالشات من ال productDetails لايتم تحميل قائمة المستخدمين
        onLoad();
      }
    };

    // New Msg Reaction
    AppBloc.realTimeCubit.onNotifyNewMsgReaction = (notify) async {
      if (notify.data['ChatId'] == chatId) {
        final index =
            chatList.indexWhere((item) => item.id == notify.data['MessageId']);
        chatList[index] = chatList[index].copyWith(
            reactedUserIds: List.from(notify.data['ReactedUserIds']),
            reactions: List.from(notify.data['Reactions']));
        emit(NewReactionSuccess(
            messageId: notify.data['MessageId'],
            reactedUserIds: List.from(notify.data['ReactedUserIds']),
            reactions: List.from(notify.data['Reactions'])));
      }
    };

    // Notify Delivered Status
    AppBloc.realTimeCubit.onNotifyDeliveredStatus = (notify) {
      var data = ChatStatusModel.fromJson(notify.data);
      if (data.userId == contactId && chatId == data.chatId) {
        for (var element in chatList) {
          if (element.fromUserId == data.userId) {
            chatList[chatList.indexWhere((item) => item.id == element.id)] =
                element.copyWith(
                    status: element.status != Status.seen
                        ? Status.delivered
                        : Status.seen,
                    readedUsers: [data.userId]);
          }
        }
        if (contactId.isNotEmpty) {
          ChatRepository.confirmReceiptStatus('D-STATUS');
          // notify
          emit(DeliveredStatusSuccess());
        }
      }
    };
    // Notify Readed Status
    AppBloc.realTimeCubit.onNotifyReadedStatus = (notify) {
      var data = ChatStatusModel.fromJson(notify.data);
      if (data.userId == contactId && chatId == data.chatId) {
        for (var element in chatList) {
          if (element.fromUserId == data.userId) {
            chatList[chatList.indexWhere((item) => item.id == element.id)] =
                element
                    .copyWith(status: Status.seen, readedUsers: [data.userId]);
          }
        }
        if (contactId.isNotEmpty) {
          ChatRepository.confirmReceiptStatus('R-STATUS');
          // notify
          emit(ReadStatusSuccess());
        }
      }
    };
    AppBloc.realTimeCubit.onNotifyNewConnect = (notify) {};
    AppBloc.realTimeCubit.onNotifyNewBlocked = (notify) {};
    await onLoad(isChatUsers: isChatUsers);
  }
}
