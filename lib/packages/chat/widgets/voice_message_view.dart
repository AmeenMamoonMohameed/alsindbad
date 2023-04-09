import 'dart:async';
import 'dart:io';

import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:akarak/packages/chat/widgets/question_message_widget.dart';
import 'package:akarak/packages/chat/widgets/reaction_widget.dart';
import 'package:audio_session/audio_session.dart';
// import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../app_properties.dart';
import '../models/chat_bubble.dart';
import '../models/message.dart';
import '../models/message_reaction_configuration.dart';
import '../models/voice_message_configuration.dart';
import 'bubbles/chat_bubbles.dart';

class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView({
    Key? key,
    required this.token,
    required this.chatToken,
    required this.screenWidth,
    required this.message,
    required this.isMessageBySender,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.onMaxDuration,
    this.messageReactionConfig,
    this.config,
  }) : super(key: key);
  final String token;
  final String chatToken;
  final VoiceMessageConfiguration? config;
  final double screenWidth;
  final Message message;
  final Function(int)? onMaxDuration;
  final bool isMessageBySender;
  final MessageReactionConfiguration? messageReactionConfig;
  final ChatBubble? inComingChatBubbleConfig;
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
  final _player = AudioPlayer();
  bool isCompleted = false;
  AudioSource? source;
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // final session = await AudioSession.instance;
    // await session.configure(const AudioSessionConfiguration.speech());
    // _player.playbackEventStream.listen((event) {},
    //     onError: (Object e, StackTrace stackTrace) {
    //   print('A stream error occurred: $e');
    // });
    try {
      source;
      if (widget.message.message.fromMemory) {
        source = AudioSource.uri(
          // File(widget.message.message).uri
          Uri.parse(widget.message.message),
        );
      } else {
        source = AudioSource.uri(
          Uri.parse(widget.message.message),
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "ChatToken": widget.chatToken,
            "FileType": "Chat",
          },
        );
      }
      await _player.setAudioSource(source!, preload: true);
      _player.positionStream.listen((position) {
        if (position.inMilliseconds.toDouble() ==
            _player.duration?.inMilliseconds.toDouble()) {
          isCompleted = true;
          _player.seek(const Duration(milliseconds: 0), index: 0);
          _player.stop();
        }
      });
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (widget.isMessageBySender
        ? widget.message.status == Status.sent
        : false) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (widget.isMessageBySender
        ? widget.message.status == Status.delivered
        : false) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (widget.isMessageBySender
        ? widget.message.status == Status.seen
        : false) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }
    return StreamBuilder<PositionData>(
        stream: _positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          return Row(
            children: <Widget>[
              widget.isMessageBySender
                  ? const Expanded(
                      child: SizedBox(
                        width: 5,
                      ),
                    )
                  : Container(),
              Container(
                color: Colors.transparent,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8,
                  // maxHeight: 75
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isMessageBySender
                          ? transparentYellow
                          : Colors.blue.withOpacity(0.4),
                      boxShadow: smallShadow,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            Radius.circular(widget.isMessageBySender ? 16 : 0),
                        bottomRight:
                            Radius.circular(widget.isMessageBySender ? 0 : 16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.message.attachmentMessage != null &&
                                widget.message.attachmentMessage!
                                    .hasValue()) ...[
                              QuestionMessageWidget(
                                  isSender: widget.isMessageBySender,
                                  message: widget.message),
                              const Divider(),
                            ],
                            Row(
                              children: [
                                RawMaterialButton(
                                  onPressed: () async {
                                    isCompleted = false;
                                    if (_player.playing) {
                                      await _player.pause();
                                    } else {
                                      if (isCompleted) {
                                        _player.seek(
                                            const Duration(milliseconds: 0),
                                            index: 0);
                                        isCompleted = false;
                                      }
                                      await _player.play();
                                    }
                                    // setState(() {});
                                  },
                                  elevation: 1.0,
                                  fillColor: Colors.white,
                                  padding: const EdgeInsets.all(0.0),
                                  shape: const CircleBorder(),
                                  constraints:
                                      const BoxConstraints(minWidth: 50),
                                  child: !_player.playing
                                      ? const Icon(
                                          Icons.play_arrow,
                                          size: 30.0,
                                        )
                                      : _player.processingState ==
                                                  ProcessingState.loading ||
                                              _player.processingState ==
                                                  ProcessingState.buffering
                                          ? const CircularProgressIndicator()
                                          : (_player.playing == false ||
                                                      _player.processingState ==
                                                          ProcessingState
                                                              .completed) &&
                                                  _player.processingState !=
                                                      ProcessingState.loading
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
                                    max: positionData?.duration.inMilliseconds
                                            .toDouble() ??
                                        0.0,
                                    value: (!isCompleted
                                            ? positionData
                                                ?.position.inMilliseconds
                                                .toDouble()
                                            : 0) ??
                                        0.0,
                                    onChanged: (value) {
                                      _player.seek(Duration(
                                          milliseconds: value.toInt()));
                                    },
                                    inactiveColor:
                                        Colors.grey.shade300.withOpacity(0.4),
                                    activeColor: Colors.grey.shade300,
                                    autofocus: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 8,
                          right: 25,
                          child: Text(
                              audioTimer(
                                  positionData?.duration.inMilliseconds
                                          .toDouble() ??
                                      0.0,
                                  (!isCompleted
                                          ? positionData
                                              ?.position.inMilliseconds
                                              .toDouble()
                                          : 0) ??
                                      0.0),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              )),
                        ),
                        if (widget.message.status == Status.sending)
                          Positioned(
                            bottom: 4,
                            right: 6,
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                value: widget.message.progressValue,
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
                        if (widget.message.reaction.reactions.isNotEmpty)
                          ReactionWidget(
                            isMessageBySender: widget.isMessageBySender,
                            reaction: widget.message.reaction,
                            messageReactionConfig: widget.messageReactionConfig,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });

    // return StreamBuilder<PositionData>(
    //     stream: _positionDataStream,
    //     builder: (context, snapshot) {
    //       final positionData = snapshot.data;
    //       return BubbleNormalAudio(
    //         color: const Color(0xFFE8E8EE),
    //         duration: positionData?.duration.inMilliseconds.toDouble(),
    //         position: !isCompleted
    //             ? positionData?.position.inMilliseconds.toDouble()
    //             : 0,
    //         // isSender: widget.isMessageBySender,
    //         isPlaying: _player.playing,
    //         isLoading: _player.processingState == ProcessingState.loading ||
    //             _player.processingState == ProcessingState.buffering,
    //         isPause: (_player.playing == false ||
    //                 _player.processingState == ProcessingState.completed) &&
    //             _player.processingState != ProcessingState.loading,
    //         onSeekChanged: (value) {
    //           _player.seek(Duration(milliseconds: value.toInt()));
    //         },
    //         onPlayPauseButtonClick: () async {
    //           isCompleted = false;
    //           if (_player.playing) {
    //             await _player.pause();
    //           } else {
    //             if (isCompleted) {
    //               _player.seek(const Duration(milliseconds: 0), index: 0);
    //               isCompleted = false;
    //             }
    //             await _player.play();
    //           }
    //           // setState(() {});
    //         },

    //         isSender: widget.isMessageBySender,
    //         sent: widget.isMessageBySender
    //             ? widget.message.status == Status.sent
    //             : false,
    //         delivered: widget.isMessageBySender
    //             ? widget.message.status == Status.delivered
    //             : false,
    //         seen: widget.isMessageBySender
    //             ? widget.message.status == Status.seen
    //             : false,
    //         reaction: widget.message.reaction,
    //         messageReactionConfig: widget.messageReactionConfig,
    //       );
    //     });
  }

  String audioTimer(double duration, double position) {
    if (duration > 0) duration = duration / 1000;
    if (position > 0) position = position / 1000;
    return '${(duration ~/ 60).toInt()}:${(duration % 60).toInt().toString().padLeft(2, '0')}/${position ~/ 60}:${(position % 60).toInt().toString().padLeft(2, '0')}';
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
