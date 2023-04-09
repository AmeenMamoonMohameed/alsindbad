import 'package:akarak/packages/chat/models/voice_message_configuration.dart';
import 'package:flutter/material.dart';

import 'emoji_message_configuration.dart';
import 'image_message.dart';
import 'message.dart';
import 'message_reaction_configuration.dart';

class MessageConfiguration {
  final String token;
  final String chatToken;
  final ImageMessageConfiguration? imageMessageConfig;
  final MessageReactionConfiguration? messageReactionConfig;
  final EmojiMessageConfiguration? emojiMessageConfig;
  final Widget Function(Message)? customMessageBuilder;

  /// Configurations for voice message bubble
  final VoiceMessageConfiguration? voiceMessageConfig;

  MessageConfiguration({
    required this.token,
    required this.chatToken,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.emojiMessageConfig,
    this.customMessageBuilder,
    this.voiceMessageConfig,
  });
}
