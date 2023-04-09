import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

import '../packages/chat/models/message.dart';

class ChatStatusModel {
  final int chatId;
  final String userId;
  final Status status;

  ChatStatusModel({
    required this.chatId,
    required this.userId,
    required this.status,
  });

  factory ChatStatusModel.fromJson(Map<String, dynamic> json) {
    Status status = Status.sending;
    if ((json['status'] ?? json['Status']) != null) {
      status = Status.values[(json['status'] ?? json['Status'])];
    }
    return ChatStatusModel(
      chatId: json['chatId'] ?? json['ChatId'] ?? 0,
      userId: json['userId'] ?? json['UserId'],
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'userId': userId,
      'status': status.index,
    };
  }
}
