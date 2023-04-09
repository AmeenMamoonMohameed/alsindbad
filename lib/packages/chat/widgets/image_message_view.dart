import 'dart:convert';

import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


import '../models/image_message.dart';
import '../models/message.dart';
import '../models/message_reaction_configuration.dart';
import 'app_placeholder.dart';
import 'bubbles/bubbles/bubble_normal_image.dart';
import 'share_icon.dart';
import 'reaction_widget.dart';

class ImageMessageView extends StatelessWidget {
  const ImageMessageView({
    Key? key,
    required this.token,
    required this.chatToken,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
  }) : super(key: key);

  final String token;
  final String chatToken;
  final Message message;
  final bool isMessageBySender;
  final ImageMessageConfiguration? imageMessageConfig;
  final MessageReactionConfiguration? messageReactionConfig;
  final bool highlightImage;
  final double highlightScale;

  String get imageUrl => message.message;

  @override
  Widget build(BuildContext context) {
    return BubbleNormalImage(
      id: 'id001',
      image: imageUrl.fromMemory
          ? Image.memory(
              base64Decode(imageUrl),
              // base64Decode(imageUrl.substring(
              //     imageUrl.indexOf('base64') + 7)),
              fit: BoxFit.fill,
            )
          : Image.network(
              imageUrl,
              headers: {
                "Authorization": "Bearer $token",
                "ChatToken": chatToken,
                "FileType": "Chat",
              },
              fit: BoxFit.fitHeight,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, url, error) {
                return AppPlaceholder(
                  child: Container(
                    // width: 60,
                    // height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                    ),
                    child: const Icon(Icons.error),
                  ),
                );
              },
            ),
      color: Colors.purpleAccent,
      tail: true,
      isSender: isMessageBySender,
      sent: isMessageBySender ? message.status == Status.sent : false,
      delivered: isMessageBySender ? message.status == Status.delivered : false,
      seen: isMessageBySender ? message.status == Status.seen : false,
      reaction: message.reaction,
      messageReactionConfig: messageReactionConfig,
    );
  }
}
