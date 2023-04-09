import 'package:akarak/app_properties.dart';
import 'package:flutter/material.dart';

import '../../../models/message_reaction_configuration.dart';
import '../../../models/reaction.dart';
import '../../reaction_widget.dart';

const double BUBBLE_RADIUS_AUDIO = 16;

///basic chat bubble type audio message widget
///
/// [onSeekChanged] double pass function to take actions on seek changes
/// [onPlayPauseButtonClick] void function to handle play pause button click
/// [isPlaying],[isPause] parameters to handle playing state
///[duration] is the duration of the audio message in seconds
///[position is the current position of the audio message playing in seconds
///[isLoading] is the loading state of the audio
///ex:- fetching from internet or loading from local storage
///chat bubble [BorderRadius] can be customized using [bubbleRadius]
///chat bubble color can be customized using [color]
///chat bubble tail can be customized  using [tail]
///message sender can be changed using [isSender]
///[sent],[delivered] and [seen] can be used to display the message state
///chat bubble [TextStyle] can be customized using [textStyle]

class BubbleNormalAudio extends StatelessWidget {
  final void Function(double value) onSeekChanged;
  final void Function() onPlayPauseButtonClick;
  final bool isPlaying;
  final bool isPause;
  final double? duration;
  final double? position;
  final bool isLoading;
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final Reaction? reaction;
  final MessageReactionConfiguration? messageReactionConfig;

  BubbleNormalAudio({
    Key? key,
    required this.onSeekChanged,
    required this.onPlayPauseButtonClick,
    this.isPlaying = false,
    this.isPause = false,
    this.duration,
    this.position,
    this.isLoading = true,
    this.bubbleRadius = BUBBLE_RADIUS_AUDIO,
    this.isSender = true,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 12,
    ),
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
              maxWidth: MediaQuery.of(context).size.width * .8, maxHeight: 75),
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
                      : BUBBLE_RADIUS_AUDIO),
                  bottomRight: Radius.circular(tail
                      ? isSender
                          ? 0
                          : bubbleRadius
                      : BUBBLE_RADIUS_AUDIO),
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      RawMaterialButton(
                        onPressed: onPlayPauseButtonClick,
                        elevation: 1.0,
                        fillColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        shape: const CircleBorder(),
                        constraints: const BoxConstraints(minWidth: 50),
                        child: !isPlaying
                            ? const Icon(
                                Icons.play_arrow,
                                size: 30.0,
                              )
                            : isLoading
                                ? const CircularProgressIndicator()
                                : isPause
                                    ? const Icon(
                                        Icons.play_arrow,
                                        size: 30.0,
                                      )
                                    : const Icon(
                                        Icons.pause,
                                        size: 30.0,
                                      ),
                      ),
                      Expanded(
                        child: Slider(
                          min: 0.0,
                          max: duration ?? 0.0,
                          value: position ?? 0.0,
                          onChanged: onSeekChanged,
                          inactiveColor: Colors.grey.shade300.withOpacity(0.4),
                          activeColor: Colors.grey.shade300,
                          autofocus: true,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 8,
                    right: 25,
                    child: Text(audioTimer(duration ?? 0.0, position ?? 0.0),
                        style: textStyle.copyWith(color: textStyle.color)),
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

  String audioTimer(double duration, double position) {
    if (duration > 0) duration = duration / 1000;
    if (position > 0) position = position / 1000;
    return '${(duration ~/ 60).toInt()}:${(duration % 60).toInt().toString().padLeft(2, '0')}/${position ~/ 60}:${(position % 60).toInt().toString().padLeft(2, '0')}';
  }
}
