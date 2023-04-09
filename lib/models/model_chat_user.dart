import 'package:akarak/models/model.dart';

class ChatUserModel {
  late String userId;
  late int chatId;
  late String userName;
  late String profilePictureDataUrl;
  late String accountName;
  late String fullName;
  late String? emailAddress;
  late bool hasNewMessage;
  late bool isOnline;
  late ChatModel? lastMessage;
  late String? lastMessageTimeElapsed;

  ChatUserModel({
    required this.userId,
    this.chatId = 0,
    required this.userName,
    required this.profilePictureDataUrl,
    required this.accountName,
    required this.fullName,
    this.emailAddress,
    this.hasNewMessage = false,
    this.isOnline = false,
    this.lastMessage,
    this.lastMessageTimeElapsed,
  });

  ChatUserModel.fromSource(source) {
    userId = source.userId;
    chatId = source.chatId;
    userName = source.userName;
    profilePictureDataUrl = source.profilePictureDataUrl;
    accountName = source.accountName;
    fullName = source.fullName;
    emailAddress = source.emailAddress;
    hasNewMessage = source.hasNewMessage;
    isOnline = source.isOnline;
    lastMessage = source.lastMessage;
    lastMessageTimeElapsed = source.lastMessageTimeElapsed;
  }

  ChatUserModel clone() {
    return ChatUserModel.fromSource(this);
  }

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    ChatModel? lastMessage_;
    if (json['lastMessage'] != null) {
      lastMessage_ = ChatModel.fromJson(json['lastMessage']);
    }
    return ChatUserModel(
      userId: json['userId'] ?? '',
      chatId: json['chatId'] ?? 0,
      userName: json['userName'] ?? '',
      profilePictureDataUrl: json['profilePictureDataUrl'] ?? '',
      accountName: json['accountName'] ?? 'Unknown',
      fullName: json['fullName'] ?? 'Unknown',
      emailAddress: json['emailAddress'] ?? 'Unknown',
      hasNewMessage: json['hasNewMessage'] ?? false,
      lastMessageTimeElapsed: json['lastMessageTimeElapsed'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastMessage: lastMessage_,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'chatId': chatId,
      'userName': userName,
      'profilePictureDataUrl': profilePictureDataUrl,
      'firstName': accountName,
      'lastName': fullName,
      'emailAddress': emailAddress,
      'hasNewMessage': hasNewMessage,
      'isOnline': isOnline,
      'lastMessage': lastMessage,
      'lastMessageTimeElapsed': lastMessageTimeElapsed,
    };
  }

  ChatUserModel copyWith({
    String? userId,
    int? chatId,
    String? userName,
    String? profilePictureDataUrl,
    String? accountName,
    String? fullName,
    String? emailAddress,
    bool? hasNewMessage,
    bool? isOnline,
    ChatModel? lastMessage,
    String? lastMessageTimeElapsed,
  }) =>
      ChatUserModel(
        userId: userId ?? this.userId,
        chatId: chatId ?? this.chatId,
        userName: userName ?? this.userName,
        profilePictureDataUrl:
            profilePictureDataUrl ?? this.profilePictureDataUrl,
        accountName: accountName ?? this.accountName,
        fullName: fullName ?? this.fullName,
        emailAddress: emailAddress ?? this.emailAddress,
        hasNewMessage: hasNewMessage ?? this.hasNewMessage,
        lastMessageTimeElapsed:
            lastMessageTimeElapsed ?? this.lastMessageTimeElapsed,
        isOnline: isOnline ?? this.isOnline,
        lastMessage: lastMessage ?? this.lastMessage,
      );
}
