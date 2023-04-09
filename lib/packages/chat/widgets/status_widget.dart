import 'package:flutter/material.dart';
import '../extensions/extensions.dart';
import '../chatview.dart';
import '../utils/measure_size.dart';

class StatusWidget extends StatefulWidget {
  const StatusWidget({
    Key? key,
    required this.reaction,
    this.messageReactionConfig,
    required this.isMessageBySender,
  }) : super(key: key);

  final Reaction reaction;
  final MessageReactionConfiguration? messageReactionConfig;
  final bool isMessageBySender;

  @override
  State<StatusWidget> createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  bool needToExtend = false;

  MessageReactionConfiguration? get messageReactionConfig =>
      widget.messageReactionConfig;
  final _reactionTextStyle = const TextStyle(fontSize: 13);
  ChatController? chatController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      chatController = provide!.chatController;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Convert into set to remove reduntant values
    final reactionsSet = widget.reaction.reactions.toSet();
    return Positioned(
      bottom: 0,
      right: widget.isMessageBySender && needToExtend ? 0 : null,
      child: InkWell(
        // onTap: () => chatController != null
        //     ? ReactionsBottomSheet().show(
        //         context: context,
        //         reaction: widget.reaction,
        //         chatController: chatController!,
        //         reactionsBottomSheetConfig:
        //             messageReactionConfig?.reactionsBottomSheetConfig,
        //       )
        //     : null,
        child: MeasureSize(
          onSizeChange: (extend) => setState(() => needToExtend = extend),
          child: Container(
            padding: messageReactionConfig?.padding ??
                const EdgeInsets.symmetric(vertical: 1.7, horizontal: 6),
            margin: messageReactionConfig?.margin ??
                EdgeInsets.only(
                  left: widget.isMessageBySender ? 4 : 0,
                  right: 4,
                ),
            decoration: BoxDecoration(
              color: messageReactionConfig?.backgroundColor ??
                  Colors.grey.shade200,
              borderRadius: messageReactionConfig?.borderRadius ??
                  BorderRadius.circular(16),
              border: Border.all(
                color: messageReactionConfig?.borderColor ?? Colors.white,
                width: messageReactionConfig?.borderWidth ?? 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  reactionsSet.join(' '),
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                if ((chatController?.chatUsers.length ?? 0) > 1) ...[
                  if (widget.reaction.reactedUserIds.length > 3 &&
                      !(reactionsSet.length > 1))
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '✔✔',
                        style:
                            messageReactionConfig?.reactedUserCountTextStyle ??
                                _reactionTextStyle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
