import 'dart:convert';

import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';

class ChatRepository {
  ///Fetch api validToken
  static Future<bool> validateToken() async {
    final response = await Api.requestValidateToken();
    if (response.succeeded) {
      return true;
    }
    AppBloc.messageCubit.onShow(response.message);
    return false;
  }

  ///Block User
  static Future<bool?> blockUser(
      {required String userId, String? because}) async {
    Map<String, dynamic> params = {
      "userId": userId,
      "because": because,
    };

    final response = await Api.requestBlockUser(params);

    ///Case success
    if (response.succeeded) {
      return response.data;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///UnBlock User
  static Future<bool?> unblockUser(String userId) async {
    final response = await Api.requestUnBlockUser(userId);

    ///Case success
    if (response.succeeded) {
      return response.data;
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Send Report
  static Future<bool?> sendReport(ReportModel report) async {
    Map<String, dynamic> params = {
      "reportedId": report.reportedId,
      "name": report.name,
      "description": report.description,
    };

    final response = await Api.requestSendReport(params, report.type);

    ///Case success
    if (response.succeeded) {
      return response.data;
    }
    return false;
  }

  ///Send Message Contact Us
  static Future<int?> sendMessageContactUs(String name, String message) async {
    Map<String, dynamic> params = {
      "name": name,
      "message": message,
    };

    final response = await Api.requestSendContactUs(params);
    AppBloc.messageCubit.onShow(response.message);

    ///Case success
    if (response.succeeded) {
      return response.data;
    }
    return null;
  }

  ///Save Chat
  static Future<ChatModel?> saveMessage(
      {required ChatModel message, Function(num)? progress}) async {
    final response =
        await Api.requestSaveMessage(message.toSendJson(), progress);

    ///Case success
    if (response.succeeded) {
      return ChatModel.fromJson(response.data);
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Send Reaction
  static Future<Map<String, dynamic>?> sendReaction(
      {required int chatId,
      required int messageId,
      required String emoji}) async {
    Map<String, dynamic> params = {
      "chatId": chatId,
      "messageId": messageId,
      "emoji": emoji,
    };

    final response = await Api.requestSetReaction(params);

    ///Case success
    if (response.succeeded) {
      return response.data;
    }
    return null;
  }

  ///confirm Receipt Status
  static Future<void> confirmReceiptStatus(String statusType) async {
    await Api.requestConfirmReceiptStatus(statusType);
  }

  ///Reached Chat
  static Future<void> sendReadStatus({required int chatId}) async {
    await Api.requestSendReadStatus(chatId);
  }

  ///Delivered Chat Messages
  static Future<void> sendDeliveredStatus({required int chatId}) async {
    await Api.requestSendDeliveredStatus(chatId);
  }

  ///Delivered Chat Messages
  static Future<void> sendDeliveredStatusForUsers(List<int> chats) async {
    await Api.requestSendDeliveredStatusForUsers(chats);
  }

  ///Load Chat
  static Future<List?> loadChat({
    required int chatId,
    required String contactId,
    required int pageNumber,
    required int pageSize,
    bool loading = false,
  }) async {
    final response = await Api.requestChat(
      chatId: chatId,
      contactId: contactId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      loading: loading,
    );
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ChatModel.fromJson(item);
      }).toList();

      return [list, response.pagination, response.attr];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  ///Load Chat Users
  static Future<List?> loadChatUsers({
    required String keyword,
    required int pageNumber,
    required int pageSize,
    bool loading = false,
  }) async {
    final response = await Api.requestChatUsers(
        keyword: keyword,
        pageNumber: pageNumber,
        pageSize: pageSize,
        loading: loading);
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ChatUserModel.fromJson(item);
      }).toList();

      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return [];
  }

  ///Load Blocked Users
  static Future<List?> loadBlockedUsers({
    required String keyword,
    required int pageNumber,
    required int pageSize,
    bool loading = false,
  }) async {
    final response = await Api.requestBlockedUsers(
      keyword: keyword,
      pageNumber: pageNumber,
      pageSize: pageSize,
      loading: loading,
    );
    if (response.succeeded) {
      final list = List.from(response.data ?? []).map((item) {
        return ChatUserModel.fromJson(item);
      }).toList();

      return [list, response.pagination];
    }
    AppBloc.messageCubit.onShow(response.message);
    return [];
  }

  // ///Delete Chat
  // static Future<bool> blockChat() async {
  //   return await Preferences.remove(Preferences.user);
  // }
}
