import 'package:akarak/packages/chat/chatview.dart';
import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../models/chat_bubble.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import '../values/typedefs.dart';
import 'image_message_view.dart';
import 'map_message_view.dart';
import 'text_message_view.dart';
import 'reaction_widget.dart';
import 'voice_message_view.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    required this.onLongPress,
    required this.isLongPressEnable,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.longPressAnimationDuration,
    this.onDoubleTap,
    this.highlightColor = Colors.red,
    this.shouldHighlight = false,
    this.highlightScale = 1.2,
    this.messageConfig,
    this.onMaxDuration,
  }) : super(key: key);

  final Message message;
  final bool isMessageBySender;
  final DoubleCallBack onLongPress;
  final double? chatBubbleMaxWidth;
  final ChatBubble? inComingChatBubbleConfig;
  final ChatBubble? outgoingChatBubbleConfig;
  final Duration? longPressAnimationDuration;
  final MessageCallBack? onDoubleTap;
  final Color highlightColor;
  final bool shouldHighlight;
  final double highlightScale;
  final MessageConfiguration? messageConfig;
  final bool isLongPressEnable;
  final Function(int)? onMaxDuration;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  MessageConfiguration? get messageConfig => widget.messageConfig;

  bool get isLongPressEnable => widget.isLongPressEnable;

  @override
  void initState() {
    super.initState();
    if (isLongPressEnable) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.longPressAnimationDuration ??
            const Duration(milliseconds: 250),
        upperBound: 0.1,
        lowerBound: 0.0,
      );
      _animationController?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController?.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: isLongPressEnable ? _onLongPressStart : null,
      onDoubleTap: () {
        if (widget.onDoubleTap != null) widget.onDoubleTap!(widget.message);
      },
      child: (() {
        if (isLongPressEnable) {
          return AnimatedBuilder(
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - _animationController!.value,
                child: _messageView,
              );
            },
            animation: _animationController!,
          );
        } else {
          return _messageView;
        }
      }()),
    );
  }

  Widget get _messageView {
    final message = widget.message.message;
    final emojiMessageConfiguration = messageConfig?.emojiMessageConfig;
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.message.reaction.reactions.isNotEmpty ? 6 : 0,
      ),
      child: (() {
        if (message.isAllEmoji) {
          return Container(
            decoration: BoxDecoration(
                color: widget.shouldHighlight
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: emojiMessageConfiguration?.padding ??
                            EdgeInsets.fromLTRB(
                              leftPadding2,
                              4,
                              leftPadding2,
                              widget.message.reaction.reactions.isNotEmpty
                                  ? 14
                                  : 0,
                            ),
                        child: Transform.scale(
                          scale: widget.shouldHighlight
                              ? widget.highlightScale
                              : 1.0,
                          child: Text(
                            message,
                            style: emojiMessageConfiguration?.textStyle ??
                                const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      if (widget.message.reaction.reactions.isNotEmpty)
                        ReactionWidget(
                          reaction: widget.message.reaction,
                          messageReactionConfig:
                              messageConfig?.messageReactionConfig,
                          isMessageBySender: widget.isMessageBySender,
                        ),
                    ],
                  ),
                  if (widget.isMessageBySender) ...[
                    if (widget.message.status == Status.sending)
                      Padding(
                        padding: emojiMessageConfiguration?.padding ??
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 13.0,
                          width: 13.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: widget.message.progressValue,
                          ),
                        ),
                      ),
                    if (widget.message.status == Status.sent)
                      Padding(
                        padding: emojiMessageConfiguration?.padding ??
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✔',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.orange,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    if (widget.message.status == Status.delivered)
                      Padding(
                        padding: emojiMessageConfiguration?.padding ??
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✔✔',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.orange,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    if (widget.message.status == Status.seen)
                      Padding(
                        padding: emojiMessageConfiguration?.padding ??
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✔✔',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.blue,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                  ],
                ]),
          );
        } else if (widget.message.messageType.isImage) {
          return Container(
            decoration: BoxDecoration(
                color: widget.shouldHighlight
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent),
            child: ImageMessageView(
              message: widget.message,
              isMessageBySender: widget.isMessageBySender,
              imageMessageConfig: messageConfig?.imageMessageConfig,
              token: messageConfig!.token,
              chatToken: messageConfig!.chatToken,
              messageReactionConfig: messageConfig?.messageReactionConfig,
              highlightImage: widget.shouldHighlight,
              highlightScale: widget.highlightScale,
            ),
          );
        } else if (widget.message.messageType.isText) {
          return Container(
            decoration: BoxDecoration(
                color: widget.shouldHighlight
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent),
            child: TextMessageView(
              inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
              outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
              isMessageBySender: widget.isMessageBySender,
              message: widget.message,
              chatBubbleMaxWidth: widget.chatBubbleMaxWidth,
              messageReactionConfig: messageConfig?.messageReactionConfig,
              highlightColor: widget.highlightColor,
              highlightMessage: widget.shouldHighlight,
            ),
          );
        } else if (widget.message.messageType.isMap) {
          return Container(
            decoration: BoxDecoration(
                color: widget.shouldHighlight
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent),
            child: MapMessageView(
              inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
              outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
              isMessageBySender: widget.isMessageBySender,
              message: widget.message,
              chatBubbleMaxWidth: widget.chatBubbleMaxWidth,
              messageReactionConfig: messageConfig?.messageReactionConfig,
              highlightColor: widget.highlightColor,
              highlightMessage: widget.shouldHighlight,
            ),
          );
        } else if (widget.message.messageType.isVoice) {
          return Container(
            decoration: BoxDecoration(
                color: widget.shouldHighlight
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent),
            child: VoiceMessageView(
              token: messageConfig!.token,
              chatToken: messageConfig!.chatToken,
              screenWidth: MediaQuery.of(context).size.width,
              message: widget.message,
              config: messageConfig?.voiceMessageConfig,
              onMaxDuration: widget.onMaxDuration,
              isMessageBySender: widget.isMessageBySender,
              messageReactionConfig: messageConfig?.messageReactionConfig,
              inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
              outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
            ),
          );
        } else if (widget.message.messageType.isCustom &&
            messageConfig?.customMessageBuilder != null) {
          return messageConfig?.customMessageBuilder!(widget.message);
        }
      }()),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) async {
    await _animationController?.forward();
    widget.onLongPress(
      details.globalPosition.dy - 120 - 64,
      details.globalPosition.dx,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
