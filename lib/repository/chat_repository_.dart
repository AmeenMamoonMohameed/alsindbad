// import 'dart:convert';

// import 'package:akarak/api/api.dart';
// import 'package:akarak/blocs/bloc.dart';
// import 'package:akarak/configs/config.dart';
// import 'package:akarak/models/model.dart';

// class ChatRepository {
//   ///Fetch api validToken
//   static Future<bool> validateToken() async {
//     final response = await Api.requestValidateToken();
//     if (response.succeeded) {
//       return true;
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return false;
//   }

//   ///Block User
//   static Future<bool?> blockUser(
//       {required String userId, String? because}) async {
//     Map<String, dynamic> params = {
//       "userId": userId,
//       "because": because,
//     };

//     final response = await Api.requestBlockUser(params);

//     ///Case success
//     if (response.succeeded) {
//       return response.data;
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return null;
//   }

//   ///UnBlock User
//   static Future<bool?> unblockUser(String userId) async {
//     final response = await Api.requestUnBlockUser(userId);

//     ///Case success
//     if (response.succeeded) {
//       return response.data;
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return null;
//   }

//   ///Send Report
//   static Future<bool?> sendReport(ReportModel report) async {
//     Map<String, dynamic> params = {
//       "reportedId": report.reportedId,
//       "name": report.name,
//       "description": report.description,
//     };

//     final response = await Api.requestSendReport(params, report.type);

//     ///Case success
//     if (response.succeeded) {
//       return response.data;
//     }
//     return false;
//   }

//   ///Send Message Contact Us
//   static Future<int?> sendMessageContactUs(String name, String message) async {
//     Map<String, dynamic> params = {
//       "name": name,
//       "message": message,
//     };

//     final response = await Api.requestSendContactUs(params);
//     AppBloc.messageCubit.onShow(response.message);

//     ///Case success
//     if (response.succeeded) {
//       return response.data;
//     }
//     return null;
//   }

//   ///Save Chat
//   static Future<int?> saveMessage({required ChatModel message}) async {
//     final response = await Api.requestSaveMessage(message.toJson());

//     ///Case success
//     if (response.succeeded) {
//       return response.data;
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return null;
//   }

//   ///Reached Chat
//   static Future<void> ping() async {
//     await Api.requestPing();
//   }

//   ///confirm Receipt Status
//   static Future<void> confirmReceiptStatus(String statusType) async {
//     await Api.requestConfirmReceiptStatus(statusType);
//   }

//   ///Reached Chat
//   static Future<void> sendReadStatus({required String fromUserId}) async {
//     await Api.requestSendReadStatus(fromUserId);
//   }

//   ///Delivered Chat Messages
//   static Future<void> sendDeliveredStatus({required String fromUserId}) async {
//     await Api.requestSendDeliveredStatus(fromUserId);
//   }

//   ///Delivered Chat Messages
//   static Future<void> sendDeliveredStatusForUsers(List<String> users) async {
//     await Api.requestSendDeliveredStatusForUsers(users);
//   }

//   ///Load Chat
//   static Future<List?> loadChat({
//     required String contactId,
//     required int pageNumber,
//     required int pageSize,
//     bool loading = false,
//   }) async {
//     final response = await Api.requestChat(
//       contactId: contactId,
//       pageNumber: pageNumber,
//       pageSize: pageSize,
//       loading: loading,
//     );
//     if (response.succeeded) {
//       final list = List.from(response.data ?? []).map((item) {
//         return ChatModel.fromJson(item);
//       }).toList();

//       return [list, response.pagination];
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return null;
//   }

//   ///Load Chat Users
//   static Future<List?> loadChatUsers({
//     required String keyword,
//     required int pageNumber,
//     required int pageSize,
//     bool loading = false,
//   }) async {
//     final response = await Api.requestChatUsers(
//         keyword: keyword,
//         pageNumber: pageNumber,
//         pageSize: pageSize,
//         loading: loading);
//     if (response.succeeded) {
//       final list = List.from(response.data ?? []).map((item) {
//         return ChatUserModel.fromJson(item);
//       }).toList();

//       return [list, response.pagination];
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return [];
//   }

//   ///Load Blocked Users
//   static Future<List?> loadBlockedUsers({
//     required String keyword,
//     required int pageNumber,
//     required int pageSize,
//     bool loading = false,
//   }) async {
//     final response = await Api.requestBlockedUsers(
//       keyword: keyword,
//       pageNumber: pageNumber,
//       pageSize: pageSize,
//       loading: loading,
//     );
//     if (response.succeeded) {
//       final list = List.from(response.data ?? []).map((item) {
//         return ChatUserModel.fromJson(item);
//       }).toList();

//       return [list, response.pagination];
//     }
//     AppBloc.messageCubit.onShow(response.message);
//     return [];
//   }

//   // ///Delete Chat
//   // static Future<bool> blockChat() async {
//   //   return await Preferences.remove(Preferences.user);
//   // }
// }
