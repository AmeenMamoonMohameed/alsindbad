import 'package:akarak/configs/application.dart';
import 'package:akarak/models/model.dart';
import '../packages/chat/models/attachment_message.dart';
import '../packages/chat/models/message.dart';
import '../packages/chat/models/reply_message.dart';
import '../packages/chat/values/enumaration.dart';

// enum MessageType { custom, file, image, system, text, unsupported }

// enum Status { delivered, error, seen, sending, sent, nothing }

class ChatModel {
  final int? id;
  final int chatId;
  final String remoteId;
  final String fromUserId;
  final String contactId;
  final String message;
  final String? metadata;
  final bool showStatus;
  final DateTime? createdDate;
  final int? unixTimeMilliseconds;
  final Status status;
  final MessageType type;
  final Duration? voiceMessageDuration;
  final ReplyMessage? reply;
  final AttachmentMessage? attachment;
  final List<String>? deliveredUsers;
  final List<String>? readedUsers;
  final List<String>? reactions;
  final List<String>? reactedUserIds;
  final Map<String, dynamic>? upload;
  ChatModel({
    this.id,
    required this.chatId,
    required this.remoteId,
    required this.fromUserId,
    required this.contactId,
    required this.message,
    this.metadata,
    this.showStatus = false,
    this.createdDate,
    this.unixTimeMilliseconds,
    this.status = Status.sending,
    this.type = MessageType.text,
    this.voiceMessageDuration,
    this.reply,
    this.attachment,
    this.deliveredUsers,
    this.readedUsers,
    this.reactions,
    this.reactedUserIds,
    this.upload,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    Status status = Status.sending;
    MessageType type = MessageType.text;
    Duration? voiceMessageDuration;
    String message = json['message'] ?? json['Message'] ?? '';
    if ((json['status'] ?? json['Status']) != null) {
      status = Status.values[(json['status'] ?? json['Status'])];
    }
    if ((json['type'] ?? json['Type']) != null) {
      type = MessageType.values[(json['type'] ?? json['Type'])];
    }
    if (type == MessageType.image || type == MessageType.voice) {
      message = "${Application.domain}$message";
    }
    if (json['voiceMessageDuration'] != null ||
        json['VoiceMessageDuration'] != null) {
      voiceMessageDuration = Duration(
          seconds:
              json['voiceMessageDuration'] ?? json['VoiceMessageDuration']);
    }
    return ChatModel(
      id: int.tryParse((json['id'] ?? json['Id']).toString()) ?? 0,
      chatId: int.tryParse((json['chatId'] ?? json['ChatId']).toString()) ?? 0,
      remoteId: json['remoteId'] ?? json['RemoteId'] ?? '',
      fromUserId: json['fromUserId'] ?? json['FromUserId'] ?? '',
      contactId: json['contactId'] ?? json['ContactId'] ?? '',
      message: message,
      metadata: json['metadata'] ?? json['Metadata'] ?? '',
      showStatus: json['showStatus'] ?? json['ShowStatus'] ?? false,
      createdDate: DateTime.tryParse(
          (json['createdDate'] ?? json['CreatedDate']).toString()),
      unixTimeMilliseconds:
          json['unixTimeMilliseconds'] ?? json['UnixTimeMilliseconds'],
      status: status,
      type: type,
      voiceMessageDuration: voiceMessageDuration,
      reply: (json['reply'] ?? json['Reply']) != null
          ? ReplyMessage.fromJson(json['reply'] ?? json['Reply'])
          : null,
      attachment: (json['attachment'] ?? json['Attachment']) != null
          ? AttachmentMessage.fromJson(json['attachment'] ?? json['Attachment'])
          : null,
      deliveredUsers: (json['deliveredUsers'] ?? json['DeliveredUsers']) != null
          ? List.from((json['deliveredUsers'] ?? json['DeliveredUsers']))
              .map((e) => e.toString())
              .toList()
          : null,
      readedUsers: (json['readedUsers'] ?? json['ReadedUsers']) != null
          ? List.from((json['readedUsers'] ?? json['ReadedUsers']))
              .map((e) => e.toString())
              .toList()
          : null,
      reactions: (json['reactions'] ?? json['reactions']) != null
          ? List.from((json['reactions'] ?? json['reactions']))
              .map((e) => e.toString())
              .toList()
          : null,
      reactedUserIds: (json['reactedUserIds'] ?? json['reactedUserIds']) != null
          ? List.from((json['reactedUserIds'] ?? json['reactedUserIds']))
              .map((e) => e.toString())
              .toList()
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'chatId': chatId,
      'remoteId': remoteId,
      'fromUserId': fromUserId,
      'contactId': contactId,
      'message': message,
      'metadata': metadata,
      'createdDate': createdDate,
      'unixTimeMilliseconds': unixTimeMilliseconds,
      'status': status.index,
      'type': type.index,
      'voiceMessageDuration': voiceMessageDuration?.inSeconds,
      'deliveredUsers': deliveredUsers,
      'readedUsers': readedUsers,
      'reactions': reactions,
      'reactedUserIds': reactedUserIds,
      'reply': reply?.toJson(),
      'attachment': attachment?.toJson()
    };
  }

  Map<String, dynamic> toSendJson() {
    return {
      "id": id,
      'chatId': chatId,
      'remoteId': remoteId,
      'fromUserId': fromUserId,
      'contactId': contactId,
      'message': message,
      'metadata': metadata,
      'status': status.index,
      'type': type.index,
      'voiceMessageDuration': voiceMessageDuration?.inSeconds,
      'reply': reply?.toJson(),
      'attachment': attachment?.toJson(),
      'upload': upload
    };
  }

  ChatModel copyWith({
    int? id,
    int? chatId,
    String? remoteId,
    String? fromUserId,
    String? contactId,
    String? message,
    String? metadata,
    DateTime? createdDate,
    int? unixTimeMilliseconds,
    Status? status,
    MessageType? type,
    Duration? voiceMessageDuration,
    List<String>? deliveredUsers,
    List<String>? readedUsers,
    List<String>? reactions,
    List<String>? reactedUserIds,
    ReplyMessage? reply,
    AttachmentMessage? attachment,
    Map<String, dynamic>? uploadFile,
  }) {
    if (deliveredUsers != null && deliveredUsers.isNotEmpty) {
      deliveredUsers.addAll(this.deliveredUsers!);
      if (this.deliveredUsers != null) {
        deliveredUsers.addAll(this.deliveredUsers!);
      }
    }
    if (readedUsers != null && readedUsers.isNotEmpty) {
      if (this.readedUsers != null) {
        readedUsers.addAll(this.readedUsers!);
      }
    }

    return ChatModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      remoteId: remoteId ?? this.remoteId,
      fromUserId: fromUserId ?? this.fromUserId,
      contactId: contactId ?? this.contactId,
      message: message ?? this.message,
      reply: reply ?? this.reply,
      attachment: attachment ?? this.attachment,
      metadata: metadata ?? this.metadata,
      createdDate: createdDate ?? this.createdDate,
      unixTimeMilliseconds: unixTimeMilliseconds ?? this.unixTimeMilliseconds,
      status: status ?? this.status,
      type: type ?? this.type,
      voiceMessageDuration: voiceMessageDuration ?? this.voiceMessageDuration,
      deliveredUsers: deliveredUsers,
      readedUsers: readedUsers,
      reactions: reactions,
      reactedUserIds: reactedUserIds,
      upload: uploadFile,
    );
  }
}
