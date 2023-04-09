import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:akarak/packages/chat/widgets/question_message_widget.dart';
import 'package:flutter/material.dart';
import '../app_properties.dart';
import '../models/chat_bubble.dart';
import '../models/link_preview_configuration.dart';
import '../models/message.dart';
import '../models/message_reaction_configuration.dart';
import '../utils/constants.dart';
import 'bubbles/bubbles/bubble_normal.dart';
import 'link_preview.dart';
import 'reaction_widget.dart';
import 'status_widget.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key? key,
    required this.isMessageBySender,
    required this.message,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.messageReactionConfig,
    this.highlightMessage = false,
    this.highlightColor,
  }) : super(key: key);

  final bool isMessageBySender;
  final Message message;
  final double? chatBubbleMaxWidth;
  final ChatBubble? inComingChatBubbleConfig;
  final ChatBubble? outgoingChatBubbleConfig;
  final MessageReactionConfiguration? messageReactionConfig;
  final bool highlightMessage;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (isMessageBySender ? message.status == Status.sent : false) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (isMessageBySender ? message.status == Status.delivered : false) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (isMessageBySender ? message.status == Status.seen : false) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Row(
      children: <Widget>[
        isMessageBySender
            ? const Expanded(
                child: SizedBox(
                  width: 5,
                ),
              )
            : Container(),
        Stack(
          children: <Widget>[
            Container(
              color: Colors.transparent,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8,
                  minHeight: 50),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: isMessageBySender
                        ? transparentYellow
                        : Colors.blue.withOpacity(0.4),
                    boxShadow: smallShadow,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMessageBySender ? 16 : 0),
                      bottomRight: Radius.circular(isMessageBySender ? 0 : 16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (message.attachmentMessage != null &&
                          message.attachmentMessage!.hasValue()) ...[
                        QuestionMessageWidget(
                            isSender: isMessageBySender, message: message),
                        const Divider(),
                      ],
                      Padding(
                        padding: stateTick
                            ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                            : const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                        child: message.message.isUrl
                            ? LinkPreview(
                                linkPreviewConfig: _linkPreviewConfig,
                                url: message.message,
                              )
                            : Text(
                                message.message,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (message.status == Status.sending)
              Positioned(
                bottom: 4,
                right: 6,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    value: message.progressValue,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              stateIcon != null && stateTick
                  ? Positioned(
                      bottom: 4,
                      right: 6,
                      child: stateIcon,
                    )
                  : const SizedBox(
                      width: 1,
                    ),
            if (message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: isMessageBySender,
                reaction: message.reaction,
                messageReactionConfig: messageReactionConfig,
              ),
          ],
        ),
      ],
    );
  }

  LinkPreviewConfiguration? get _linkPreviewConfig => isMessageBySender
      ? outgoingChatBubbleConfig?.linkPreviewConfig
      : inComingChatBubbleConfig?.linkPreviewConfig;
}
