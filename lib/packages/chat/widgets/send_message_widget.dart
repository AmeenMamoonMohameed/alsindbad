import 'dart:io' if (kIsWeb) 'dart:html';
import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart' show DurationExtension;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../extensions/extensions.dart';
import '../controller/chat_controller.dart';
import '../models/attachment_message.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../models/reply_message.dart';
import '../models/send_message_configuration.dart';
import '../utils/constants.dart';
import '../utils/package_strings.dart';
import '../values/typedefs.dart';
import 'chatui_textfield.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    this.questionMessage,
    required this.onCloseQuestion,
    required this.onSendMap,
    required this.onSendTap,
    required this.chatController,
    this.sendMessageConfig,
    this.backgroundColor,
    this.sendMessageBuilder,
    this.onReplyCallback,
    this.onReplyCloseCallback,
    this.onRecordingComplete,
  }) : super(key: key);
  final AttachmentMessage? questionMessage;
  final VoidCallBack onCloseQuestion;
  final StringMessageCallBack onSendMap;
  final StringMessageCallBack onSendTap;
  final RecordingMessageCallBack? onRecordingComplete;
  final SendMessageConfiguration? sendMessageConfig;
  final Color? backgroundColor;
  final ReplyMessageWithReturnWidget? sendMessageBuilder;
  final ReplyMessageCallBack? onReplyCallback;
  final VoidCallBack? onReplyCloseCallback;
  final ChatController chatController;

  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  final _textEditingController = TextEditingController();
  ReplyMessage _replyMessage = const ReplyMessage();
  final _focusNode = FocusNode();

  ChatUser get repliedUser =>
      widget.chatController.getUserFromId(_replyMessage.replyTo);

  String get _replyTo => _replyMessage.replyTo == currentUser?.id
      ? PackageStrings.you
      : _replyMessage.replyTo.isNotEmpty
          ? repliedUser.name
          : '';

  ChatUser? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      currentUser = provide!.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.sendMessageBuilder != null
        ? Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: widget.sendMessageBuilder!(_replyMessage),
          )
        : Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      bottomPadding4,
                      bottomPadding4,
                      bottomPadding4,
                      _bottomPadding,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ChatUITextField(
                          onSendMap: widget.onSendMap,
                          questionMessage: widget.questionMessage,
                          focusNode: _focusNode,
                          replyMessage: _replyMessage,
                          replyTo: _replyTo,
                          onCloseTap: _onCloseTap,
                          textEditingController: _textEditingController,
                          onPressed: _onPressed,
                          sendMessageConfig: widget.sendMessageConfig,
                          onRecordingComplete: _onRecordingComplete,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _onRecordingComplete(String? path, Duration? voiceMessageDuration) {
    if (path != null) {
      widget.onRecordingComplete
          ?.call(path, voiceMessageDuration, _replyMessage);
      if (_replyMessage.message.isNotEmpty) {
        setState(() => _replyMessage = const ReplyMessage());
      }
    }
  }

  void _onPressed() {
    if (_textEditingController.text.isNotEmpty &&
        !_textEditingController.text.startsWith('\n')) {
      widget.onSendTap(_textEditingController.text, _replyMessage);
      if (_replyMessage.message.isNotEmpty) {
        setState(() => _replyMessage = const ReplyMessage());
      }
      _textEditingController.clear();
    }
  }

  void assignReplyMessage(Message message) {
    if (currentUser != null && widget.questionMessage == null) {
      setState(() {
        _replyMessage = ReplyMessage(
          message: message.message,
          replyBy: currentUser!.id,
          replyTo: message.sendBy,
          messageType: message.messageType,
          messageId: message.id,
          voiceMessageDuration: message.voiceMessageDuration,
        );
      });
    }
    FocusScope.of(context).requestFocus(_focusNode);
    if (widget.onReplyCallback != null) widget.onReplyCallback!(_replyMessage);
  }

  void _onCloseTap() {
    if (widget.questionMessage != null) {
      widget.onCloseQuestion();
      setState(() {});
    } else {
      setState(() => _replyMessage = const ReplyMessage());
      if (widget.onReplyCloseCallback != null) widget.onReplyCloseCallback!();
    }
  }

  double get _bottomPadding => (!kIsWeb && Platform.isIOS)
      ? (_focusNode.hasFocus
          ? bottomPadding1
          : window.viewPadding.bottom > 0
              ? bottomPadding2
              : bottomPadding3)
      : bottomPadding3;

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
