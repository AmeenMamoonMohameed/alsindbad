import 'package:akarak/utils/translate.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import '../extensions/extensions.dart';
import '../models/message.dart';
import '../models/replied_message_configuration.dart';
import '../utils/constants.dart';
import '../utils/package_strings.dart';
import 'chat_view_inherited_widget.dart';
import 'vertical_line.dart';

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    Key? key,
    required this.message,
    this.repliedMessageConfig,
    this.onTap,
  }) : super(key: key);

  final Message message;
  final RepliedMessageConfiguration? repliedMessageConfig;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentUser = ChatViewInheritedWidget.of(context)?.currentUser;
    final replyBySender = message.replyMessage.replyBy == currentUser?.id;
    final textTheme = Theme.of(context).textTheme;
    final replyMessage = message.replyMessage.message;
    final chatController = ChatViewInheritedWidget.of(context)?.chatController;
    final messagedUser =
        chatController?.getUserFromId(message.replyMessage.replyBy);
    final replyBy = replyBySender ? PackageStrings.you : messagedUser?.name;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: repliedMessageConfig?.margin ??
            const EdgeInsets.only(
              right: horizontalPadding,
              left: horizontalPadding,
              bottom: 4,
            ),
        constraints:
            BoxConstraints(maxWidth: repliedMessageConfig?.maxWidth ?? 280),
        child: Column(
          crossAxisAlignment:
              replyBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Text(
            //   replyBySender
            //       ? PackageStrings.repliedByYou
            //       : "${PackageStrings.repliedByYou} $replyBy",
            //   style: repliedMessageConfig?.replyTitleTextStyle ??
            //       textTheme.bodyText2!
            //           .copyWith(fontSize: 14, letterSpacing: 0.3),
            // ),
            const SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: replyBySender
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!replyBySender)
                    VerticalLine(
                      verticalBarWidth: repliedMessageConfig?.verticalBarWidth,
                      verticalBarColor: repliedMessageConfig?.verticalBarColor,
                      rightPadding: 4,
                    ),
                  Flexible(
                    child: Opacity(
                      opacity: repliedMessageConfig?.opacity ?? 0.8,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: repliedMessageConfig?.maxWidth ?? 280,
                        ),
                        padding: repliedMessageConfig?.padding ??
                            const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                        decoration: BoxDecoration(
                          borderRadius: _borderRadius(
                            replyMessage: replyMessage,
                            replyBySender: replyBySender,
                          ),
                          color: Colors.grey.shade500.withOpacity(0.5),
                        ),
                        child: message.replyMessage.messageType.isVoice
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: repliedMessageConfig?.micIconColor ??
                                        Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                  if (message
                                          .replyMessage.voiceMessageDuration !=
                                      null)
                                    Text(
                                      message.replyMessage.voiceMessageDuration!
                                          .toHHMMSS(),
                                      style: repliedMessageConfig?.textStyle,
                                    ),
                                ],
                              )
                            : message.replyMessage.messageType.isImage
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.photo,
                                        color: repliedMessageConfig
                                                ?.micIconColor ??
                                            Colors.white,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        Translate.of(context)
                                            .translate('photo'),
                                        style: repliedMessageConfig?.textStyle,
                                      ),
                                    ],
                                  )
                                : message.replyMessage.messageType.isMap
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: repliedMessageConfig
                                                    ?.micIconColor ??
                                                Colors.white,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            Translate.of(context)
                                                .translate('address'),
                                            style:
                                                repliedMessageConfig?.textStyle,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        replyMessage,
                                        style: repliedMessageConfig
                                                ?.textStyle ??
                                            textTheme.bodyText2!
                                                .copyWith(color: Colors.black),
                                      ),
                      ),
                    ),
                  ),
                  if (replyBySender)
                    VerticalLine(
                      verticalBarWidth: repliedMessageConfig?.verticalBarWidth,
                      verticalBarColor: repliedMessageConfig?.verticalBarColor,
                      leftPadding: 4,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadiusGeometry _borderRadius({
    required String replyMessage,
    required bool replyBySender,
  }) =>
      replyBySender
          ? repliedMessageConfig?.borderRadius ??
              (replyMessage.length < 37
                  ? BorderRadius.circular(replyBorderRadius1)
                  : BorderRadius.circular(replyBorderRadius2))
          : repliedMessageConfig?.borderRadius ??
              (replyMessage.length < 29
                  ? BorderRadius.circular(replyBorderRadius1)
                  : BorderRadius.circular(replyBorderRadius2));
}
