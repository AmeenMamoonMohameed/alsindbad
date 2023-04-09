import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:akarak/packages/chat/models/reaction.dart';
import 'package:akarak/packages/chat/models/reply_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../values/enumaration.dart';
import 'attachment_message.dart';

enum Status { delivered, sent, seen, error, sending }

class Message {
  final String id;
  final GlobalKey key;
  final String message;
  final DateTime createdAt;
  final String sendBy;
  final ReplyMessage replyMessage;
  final AttachmentMessage? attachmentMessage;
  final Reaction reaction;
  final MessageType messageType;
  final Status status;
  late double? progressValue;

  /// Provides max duration for recorded voice message.
  Duration? voiceMessageDuration;

  Message({
    this.id = '',
    required this.message,
    required this.createdAt,
    required this.sendBy,
    this.replyMessage = const ReplyMessage(),
    this.attachmentMessage = const AttachmentMessage(),
    Reaction? reaction,
    this.messageType = MessageType.text,
    required this.status,
    this.voiceMessageDuration,
    this.progressValue,
  })  : reaction = reaction ?? Reaction(reactions: [], reactedUserIds: []),
        key = GlobalKey(),
        assert(
          (messageType.isVoice
              ? ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android))
              : true),
          "Voice messages are only supported with android and ios platform",
        );

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        message: json["message"],
        createdAt: json["createdAt"],
        sendBy: json["sendBy"],
        replyMessage: ReplyMessage.fromJson(json["replyMessage"]),
        attachmentMessage:
            AttachmentMessage.fromJson(json["attachmentMessage"]),
        reaction: Reaction.fromJson(json["reaction"]),
        messageType: json["messageType"],
        status: json["status"],
        voiceMessageDuration: json["voice_message_duration"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'createdAt': createdAt,
        'sendBy': sendBy,
        'replyMessage': replyMessage.toJson(),
        'attachmentMessage': attachmentMessage?.toJson(),
        'reaction': reaction.toJson(),
        'messageType': messageType,
        'status': status,
        'voice_message_duration': voiceMessageDuration,
      };

  Message copyWith({
    String? id,
    String? message,
    DateTime? createdAt,
    String? sendBy,
    ReplyMessage? replyMessage,
    AttachmentMessage? attachmentMessage,
    Reaction? reaction,
    int? unixTimeMilliseconds,
    Status? status,
    MessageType? messageType,
    Duration? voiceMessageDuration,
  }) {
    return Message(
      id: id ?? this.id,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      sendBy: sendBy ?? this.sendBy,
      replyMessage: replyMessage ?? this.replyMessage,
      attachmentMessage: attachmentMessage ?? this.attachmentMessage,
      reaction: reaction ?? this.reaction,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      voiceMessageDuration: voiceMessageDuration ?? this.voiceMessageDuration,
    );
  }
}
