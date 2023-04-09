import 'dart:async';

import 'package:flutter/material.dart';

import '../models/models.dart';

class ChatController {
  List<Message> initialMessageList;
  ScrollController scrollController;
  List<ChatUser> chatUsers;
  Function(String, String, String) onSetReaction;

  ChatController({
    required this.initialMessageList,
    required this.scrollController,
    required this.chatUsers,
    required this.onSetReaction,
  });

  StreamController<List<Message>> messageStreamController = StreamController();

  void dispose() => messageStreamController.close();

  void addMessage(Message message) {
    initialMessageList.add(message);
    messageStreamController.sink.add(initialMessageList);
  }

  void setReaction({
    required String emoji,
    required String messageId,
    required String userId,
  }) {
    onSetReaction(emoji, messageId, userId);
    final message =
        initialMessageList.firstWhere((element) => element.id == messageId);
    final reactedUserIds = message.reaction.reactedUserIds;
    final indexOfMessage = initialMessageList.indexOf(message);
    final userIndex = reactedUserIds.indexOf(userId);
    if (userIndex != -1) {
      if (message.reaction.reactions[userIndex] == emoji) {
        message.reaction.reactions.removeAt(userIndex);
        message.reaction.reactedUserIds.removeAt(userIndex);
      } else {
        message.reaction.reactions[userIndex] = emoji;
      }
    } else {
      message.reaction.reactions.add(emoji);
      message.reaction.reactedUserIds.add(userId);
    }
    initialMessageList[indexOfMessage] = Message(
      id: messageId,
      message: message.message,
      createdAt: message.createdAt,
      sendBy: message.sendBy,
      replyMessage: message.replyMessage,
      attachmentMessage: message.attachmentMessage,
      reaction: message.reaction,
      messageType: message.messageType,
      status: message.status,
    );
    messageStreamController.sink.add(initialMessageList);
  }

  void scrollToLastMessage() => Timer(
        const Duration(milliseconds: 300),
        () => scrollController.animateTo(
          scrollController.position.minScrollExtent,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
        ),
      );

  void loadMoreData(List<Message> messageList) {
    initialMessageList.insertAll(0, messageList);
    // initialMessageList.addAll(messageList);
    messageStreamController.sink.add(initialMessageList);
  }

  ChatUser getUserFromId(String userId) =>
      chatUsers.firstWhere((element) => element.id == userId);
}
