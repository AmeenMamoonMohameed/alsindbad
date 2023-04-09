// import 'package:akarak/models/model.dart';

// class ChatUserModel {
//   late String id;
//   late String userName;
//   late String profilePictureDataUrl;
//   late String accountName;
//   late String fullName;
//   late String? emailAddress;
//   late bool hasNewMessage;
//   late bool isOnline;
//   late ChatModel? lastMessage;
//   late String? lastMessageTimeElapsed;
//   late List<ChatModel>? chatFromUsers;
//   late List<ChatModel>? chatToUsers;

//   ChatUserModel({
//     required this.id,
//     required this.userName,
//     required this.profilePictureDataUrl,
//     required this.accountName,
//     required this.fullName,
//     this.emailAddress,
//     this.hasNewMessage = false,
//     this.isOnline = false,
//     this.lastMessage,
//     this.lastMessageTimeElapsed,
//     this.chatFromUsers,
//     this.chatToUsers,
//   });

//   ChatUserModel.fromSource(source) {
//     id = source.userId;
//     userName = source.userName;
//     profilePictureDataUrl = source.profilePictureDataUrl;
//     accountName = source.accountName;
//     fullName = source.fullName;
//     emailAddress = source.emailAddress;
//     hasNewMessage = source.hasNewMessage;
//     isOnline = source.isOnline;
//     lastMessage = source.lastMessage;
//     lastMessageTimeElapsed = source.lastMessageTimeElapsed;
//     chatFromUsers = source.chatFromUsers;
//     chatToUsers = source.chatToUsers;
//   }

//   ChatUserModel clone() {
//     return ChatUserModel.fromSource(this);
//   }

//   factory ChatUserModel.fromJson(Map<String, dynamic> json) {
//     ChatModel? lastMessage_;
//     if (json['lastMessage'] != null) {
//       lastMessage_ = ChatModel.fromJson(json['lastMessage']);
//     }
//     return ChatUserModel(
//       id: json['id'] ?? '',
//       userName: json['userName'] ?? '',
//       profilePictureDataUrl: json['profilePictureDataUrl'] ?? '',
//       accountName: json['accountName'] ?? 'Unknown',
//       fullName: json['fullName'] ?? 'Unknown',
//       emailAddress: json['emailAddress'] ?? 'Unknown',
//       hasNewMessage: json['hasNewMessage'] ?? false,
//       lastMessageTimeElapsed: json['lastMessageTimeElapsed'] ?? '',
//       isOnline: json['isOnline'] ?? false,
//       lastMessage: lastMessage_,
//       chatFromUsers: List.from(json['chatFromUsers'] ?? [])
//           .map((e) => ChatModel.fromJson(e))
//           .toList(),
//       chatToUsers: List.from(json['chatToUsers'] ?? [])
//           .map((e) => ChatModel.fromJson(e))
//           .toList(),
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userName': userName,
//       'profilePictureDataUrl': profilePictureDataUrl,
//       'firstName': accountName,
//       'lastName': fullName,
//       'emailAddress': emailAddress,
//       'hasNewMessage': hasNewMessage,
//       'isOnline': isOnline,
//       'lastMessage': lastMessage,
//       'lastMessageTimeElapsed': lastMessageTimeElapsed,
//       'chatFromUsers': chatFromUsers?.asMap() ?? [],
//       'chatToUsers': chatFromUsers?.asMap() ?? [],
//     };
//   }

//   ChatUserModel copyWith({
//     String? id,
//     String? userName,
//     String? profilePictureDataUrl,
//     String? accountName,
//     String? fullName,
//     String? emailAddress,
//     bool? hasNewMessage,
//     bool? isOnline,
//     ChatModel? lastMessage,
//     String? lastMessageTimeElapsed,
//     List<ChatModel>? chatFromUsers,
//     List<ChatModel>? chatToUsers,
//   }) =>
//       ChatUserModel(
//         id: id ?? this.id,
//         userName: userName ?? this.userName,
//         profilePictureDataUrl:
//             profilePictureDataUrl ?? this.profilePictureDataUrl,
//         accountName: accountName ?? this.accountName,
//         fullName: fullName ?? this.fullName,
//         emailAddress: emailAddress ?? this.emailAddress,
//         hasNewMessage: hasNewMessage ?? this.hasNewMessage,
//         lastMessageTimeElapsed:
//             lastMessageTimeElapsed ?? this.lastMessageTimeElapsed,
//         isOnline: isOnline ?? this.isOnline,
//         lastMessage: lastMessage ?? this.lastMessage,
//         chatFromUsers: chatFromUsers == null || chatFromUsers.isNotEmpty
//             ? List.from(chatFromUsers ?? [])
//                 .map((e) => ChatModel.fromJson(e))
//                 .toList()
//             : this.chatFromUsers,
//         chatToUsers: chatToUsers == null || chatToUsers.isNotEmpty
//             ? List.from(chatToUsers ?? [])
//                 .map((e) => ChatModel.fromJson(e))
//                 .toList()
//             : this.chatToUsers,
//       );
// }
