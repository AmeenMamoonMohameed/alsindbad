import '../values/enumaration.dart';

class ReplyMessage {
  final String message;
  final String replyBy;
  final String replyTo;
  final MessageType messageType;

  /// Provides max duration for recorded voice message.
  final Duration? voiceMessageDuration;

  /// Id of message, it replies to.
  final String messageId;

  const ReplyMessage({
    this.messageId = '',
    this.message = '',
    this.replyTo = '',
    this.replyBy = '',
    this.messageType = MessageType.text,
    this.voiceMessageDuration,
  });

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    Duration? voiceMessageDuration;
    if (json['voiceMessageDuration'] != null ||
        json['VoiceMessageDuration'] != null) {
      voiceMessageDuration = Duration(
          seconds:
              json['voiceMessageDuration'] ?? json['VoiceMessageDuration']);
    }

    return ReplyMessage(
      message: json['message'] ?? json['Message'],
      replyBy: json['replyBy'] ?? json['ReplyBy'] ?? '',
      replyTo: json['replyTo'] ?? json['ReplyTo'] ?? '',
      messageType:
          MessageType.values[json["messageType"] ?? json["MessageType"]],
      messageId: json["messageId"] ?? json["MessageId"],
      voiceMessageDuration: voiceMessageDuration,
    );
  }
  Map<String, dynamic> toJson() => {
        'message': message,
        'replyBy': replyBy,
        'replyTo': replyTo,
        'messageType': messageType.index,
        'messageId': messageId,
        'voiceMessageDuration': voiceMessageDuration?.inSeconds,
      };
}
