import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../app_properties.dart';
import '../../../models/link_preview_configuration.dart';
import '../../../models/message_reaction_configuration.dart';
import '../../../models/reaction.dart';
import '../../link_preview.dart';
import '../../reaction_widget.dart';

const double BUBBLE_RADIUS = 16;

///basic chat bubble type
///
///chat bubble [BorderRadius] can be customized using [bubbleRadius]
///chat bubble color can be customized using [color]
///chat bubble tail can be customized  using [tail]
///chat bubble display message can be changed using [text]
///[text] is the only required parameter
///message sender can be changed using [isSender]
///[sent],[delivered] and [seen] can be used to display the message state
///chat bubble [TextStyle] can be customized using [textStyle]

class BubbleNormal extends StatelessWidget {
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final String text;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final LinkPreviewConfiguration? linkPreviewConfig;
  final Reaction? reaction;
  final MessageReactionConfiguration? messageReactionConfig;

  BubbleNormal({
    Key? key,
    required this.text,
    this.bubbleRadius = BUBBLE_RADIUS,
    this.isSender = true,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    this.linkPreviewConfig,
    this.reaction,
    this.messageReactionConfig,
  }) : super(key: key);

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Row(
      children: <Widget>[
        isSender
            ? const Expanded(
                child: SizedBox(
                  width: 5,
                ),
              )
            : Container(),
        Container(
          color: Colors.transparent,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .8, minHeight: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isSender ? transparentYellow : Colors.blue.withOpacity(0.4),
                boxShadow: smallShadow,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(bubbleRadius),
                  topRight: Radius.circular(bubbleRadius),
                  bottomLeft: Radius.circular(tail
                      ? isSender
                          ? bubbleRadius
                          : 0
                      : BUBBLE_RADIUS),
                  bottomRight: Radius.circular(tail
                      ? isSender
                          ? 0
                          : bubbleRadius
                      : BUBBLE_RADIUS),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: stateTick
                        ? const EdgeInsets.fromLTRB(12, 6, 28, 6)
                        : const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                    child: text.isUrl
                        ? LinkPreview(
                            linkPreviewConfig: linkPreviewConfig,
                            url: text,
                          )
                        : Text(
                            text,
                            style: textStyle,
                            textAlign: TextAlign.left,
                          ),
                  ),
                  stateIcon != null && stateTick
                      ? Positioned(
                          bottom: 4,
                          right: 6,
                          child: stateIcon,
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                  if (reaction != null && reaction!.reactions.isNotEmpty)
                    ReactionWidget(
                      isMessageBySender: isSender,
                      reaction: reaction!,
                      messageReactionConfig: messageReactionConfig,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
