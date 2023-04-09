import 'package:akarak/configs/image.dart';
import 'package:akarak/packages/chat/chatview.dart';
import 'package:akarak/packages/chat/utils/package_strings.dart';
import 'package:akarak/packages/chat/values/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/attachment_message.dart';
import 'chat_list_widget.dart';
import 'chat_view_inherited_widget.dart';
import 'chatview_state_widget.dart';
import 'send_message_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.onTapMessage,
    this.questionMessage,
    required this.onCloseQuestion,
    required this.chatController,
    required this.currentUser,
    this.onSendMap,
    this.onSendTap,
    this.showReceiverProfileCircle = true,
    this.profileCircleConfig,
    this.chatBubbleConfig,
    this.repliedMessageConfig,
    this.swipeToReplyConfig,
    this.replyPopupConfig,
    this.reactionPopupConfig,
    this.loadMoreData,
    this.loadingWidget,
    this.messageConfig,
    this.isLastPage,
    this.appBar,
    ChatBackgroundConfiguration? chatBackgroundConfig,
    this.typeIndicatorConfig,
    this.sendMessageBuilder,
    this.showTypingIndicator = false,
    this.sendMessageConfig,
    this.onRecordingComplete,
    required this.chatViewState,
    ChatViewStateConfiguration? chatViewStateConfig,
    this.featureActiveConfig = const FeatureActiveConfig(),
    this.localize,
  })  : chatBackgroundConfig =
            chatBackgroundConfig ?? const ChatBackgroundConfiguration(),
        chatViewStateConfig =
            chatViewStateConfig ?? const ChatViewStateConfiguration(),
        super(key: key);

  final Function(Message message) onTapMessage;
  final AttachmentMessage? questionMessage;
  final VoidCallBack onCloseQuestion;
  final ProfileCircleConfiguration? profileCircleConfig;
  final bool showReceiverProfileCircle;
  final ChatBubbleConfiguration? chatBubbleConfig;
  final MessageConfiguration? messageConfig;
  final RepliedMessageConfiguration? repliedMessageConfig;
  final SwipeToReplyConfiguration? swipeToReplyConfig;
  final ReplyPopupConfiguration? replyPopupConfig;
  final ReactionPopupConfiguration? reactionPopupConfig;
  final ChatBackgroundConfiguration chatBackgroundConfig;
  final VoidCallBackWithFuture? loadMoreData;
  final Widget? loadingWidget;
  final bool? isLastPage;
  final StringMessageCallBack? onSendMap;
  final StringMessageCallBack? onSendTap;
  final RecordingMessageCallBack? onRecordingComplete;
  final ReplyMessageWithReturnWidget? sendMessageBuilder;
  final bool showTypingIndicator;
  final TypeIndicatorConfiguration? typeIndicatorConfig;
  final ChatController chatController;
  final SendMessageConfiguration? sendMessageConfig;
  final ChatViewState chatViewState;
  final ChatViewStateConfiguration? chatViewStateConfig;
  final ChatUser currentUser;
  final FeatureActiveConfig featureActiveConfig;
  final Map<String, String>? localize;

  final Widget? appBar;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SendMessageWidgetState> _sendMessageKey = GlobalKey();
  ReplyMessage replyMessage = const ReplyMessage();

  ChatController get chatController => widget.chatController;

  bool get showTypingIndicator => widget.showTypingIndicator;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  ChatViewState get chatViewState => widget.chatViewState;

  ChatViewStateConfiguration? get chatViewStateConfig =>
      widget.chatViewStateConfig;

  FeatureActiveConfig get featureActiveConfig => widget.featureActiveConfig;

  @override
  void initState() {
    super.initState();
    PackageStrings.message = widget.localize?['message'] != null
        ? widget.localize!['message']!
        : PackageStrings.message;
    PackageStrings.more = widget.localize?['more'] != null
        ? widget.localize!['more']!
        : PackageStrings.more;
    PackageStrings.photo = widget.localize?['photo'] != null
        ? widget.localize!['photo']!
        : PackageStrings.photo;
    PackageStrings.reactionPopupTitle =
        widget.localize?['reactionPopupTitle'] != null
            ? widget.localize!['reactionPopupTitle']!
            : PackageStrings.reactionPopupTitle;
    PackageStrings.repliedBy = widget.localize?['repliedBy'] != null
        ? widget.localize!['repliedBy']!
        : PackageStrings.repliedBy;
    PackageStrings.repliedByYou = widget.localize?['repliedByYou'] != null
        ? widget.localize!['repliedByYou']!
        : PackageStrings.repliedByYou;
    PackageStrings.repliedToYou = widget.localize?['repliedToYou'] != null
        ? widget.localize!['repliedToYou']!
        : PackageStrings.repliedToYou;
    PackageStrings.reply = widget.localize?['reply'] != null
        ? widget.localize!['reply']!
        : PackageStrings.reply;
    PackageStrings.replyTo = widget.localize?['replyTo'] != null
        ? widget.localize!['replyTo']!
        : PackageStrings.replyTo;
    PackageStrings.send = widget.localize?['send'] != null
        ? widget.localize!['send']!
        : PackageStrings.send;
    PackageStrings.today = widget.localize?['today'] != null
        ? widget.localize!['today']!
        : PackageStrings.today;
    PackageStrings.unsend = widget.localize?['unsend'] != null
        ? widget.localize!['unsend']!
        : PackageStrings.unsend;
    PackageStrings.yesterday = widget.localize?['yesterday'] != null
        ? widget.localize!['yesterday']!
        : PackageStrings.yesterday;
    PackageStrings.you = widget.localize?['you'] != null
        ? widget.localize!['you']!
        : PackageStrings.you;
    PackageStrings.errorMalformedEmojiName =
        widget.localize?['errorMalformedEmojiName'] != null
            ? widget.localize!['errorMalformedEmojiName']!
            : PackageStrings.errorMalformedEmojiName;
    PackageStrings.document = widget.localize?['document'] != null
        ? widget.localize!['document']!
        : PackageStrings.document;
    PackageStrings.camera = widget.localize?['camera'] != null
        ? widget.localize!['camera']!
        : PackageStrings.camera;
    PackageStrings.gallery = widget.localize?['gallery'] != null
        ? widget.localize!['gallery']!
        : PackageStrings.gallery;
    PackageStrings.audio = widget.localize?['audio'] != null
        ? widget.localize!['audio']!
        : PackageStrings.audio;
    PackageStrings.location = widget.localize?['location'] != null
        ? widget.localize!['location']!
        : PackageStrings.location;
    PackageStrings.contact = widget.localize?['contact'] != null
        ? widget.localize!['contact']!
        : PackageStrings.contact;
    chatController.chatUsers.add(widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    if (showTypingIndicator && chatViewState.hasMessages) {
      chatController.scrollToLastMessage();
    }
    return ChatViewInheritedWidget(
      chatController: chatController,
      featureActiveConfig: featureActiveConfig,
      currentUser: widget.currentUser,
      child: Container(
        height:
            chatBackgroundConfig.height ?? MediaQuery.of(context).size.height,
        width: chatBackgroundConfig.width ?? MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: chatBackgroundConfig.backgroundColor ?? Colors.white,
          image: const DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(Images
                .chatbackground), //NetworkImage(chatBackgroundConfig.backgroundImage!),
          ),
        ),
        padding: chatBackgroundConfig.padding,
        margin: chatBackgroundConfig.margin,
        child: Column(
          children: [
            if (widget.appBar != null) widget.appBar!,
            Expanded(
              child: Stack(
                children: [
                  if (chatViewState.isLoading)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: ChatViewStateWidget(
                        chatViewStateWidgetConfig:
                            chatViewStateConfig?.loadingWidgetConfig,
                        chatViewState: chatViewState,
                      ),
                    )
                  else if (chatViewState.noMessages)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: ChatViewStateWidget(
                        chatViewStateWidgetConfig:
                            chatViewStateConfig?.noMessageWidgetConfig,
                        chatViewState: chatViewState,
                        onReloadButtonTap:
                            chatViewStateConfig?.onReloadButtonTap,
                      ),
                    )
                  else if (chatViewState.isError)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: ChatViewStateWidget(
                        chatViewStateWidgetConfig:
                            chatViewStateConfig?.errorWidgetConfig,
                        chatViewState: chatViewState,
                        onReloadButtonTap:
                            chatViewStateConfig?.onReloadButtonTap,
                      ),
                    )
                  else if (chatViewState.hasMessages)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: ChatListWidget(
                        onTapMessage: widget.onTapMessage,
                        showTypingIndicator: widget.showTypingIndicator,
                        showReceiverProfileCircle:
                            widget.showReceiverProfileCircle,
                        replyMessage: replyMessage,
                        chatController: widget.chatController,
                        chatBackgroundConfig: widget.chatBackgroundConfig,
                        reactionPopupConfig: widget.reactionPopupConfig,
                        typeIndicatorConfig: widget.typeIndicatorConfig,
                        chatBubbleConfig: widget.chatBubbleConfig,
                        loadMoreData: widget.loadMoreData,
                        isLastPage: widget.isLastPage,
                        replyPopupConfig: widget.replyPopupConfig,
                        loadingWidget: widget.loadingWidget,
                        messageConfig: widget.messageConfig,
                        profileCircleConfig: widget.profileCircleConfig,
                        repliedMessageConfig: widget.repliedMessageConfig,
                        swipeToReplyConfig: widget.swipeToReplyConfig,
                        assignReplyMessage: (message) => _sendMessageKey
                            .currentState
                            ?.assignReplyMessage(message),
                      ),
                    ),
                  if (featureActiveConfig.enableTextField)
                    SendMessageWidget(
                      key: _sendMessageKey,
                      questionMessage: widget.questionMessage,
                      onCloseQuestion: widget.onCloseQuestion,
                      chatController: chatController,
                      sendMessageBuilder: widget.sendMessageBuilder,
                      sendMessageConfig: widget.sendMessageConfig,
                      backgroundColor: chatBackgroundConfig.backgroundColor,
                      onSendMap: _onSendMap,
                      onSendTap: _onSendTap,
                      onReplyCallback: (reply) =>
                          setState(() => replyMessage = reply),
                      onReplyCloseCallback: () =>
                          setState(() => replyMessage = const ReplyMessage()),
                      onRecordingComplete: _onRecordingComplete,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRecordingComplete(
      String path, Duration? voiceMessageDuration, ReplyMessage replyMessage) {
    if (widget.sendMessageBuilder == null) {
      if (widget.onRecordingComplete != null) {
        widget.onRecordingComplete!(path, voiceMessageDuration, replyMessage);
      }
      _assignReplyMessage();
    }
    chatController.scrollToLastMessage();
  }

  void _onSendTap(String message, ReplyMessage replyMessage) {
    if (widget.sendMessageBuilder == null) {
      if (widget.onSendTap != null) {
        widget.onSendTap!(message.trim(), replyMessage);
      }
      _assignReplyMessage();
    }
    chatController.scrollToLastMessage();
  }

  void _onSendMap(String message, ReplyMessage replyMessage) {
    if (widget.sendMessageBuilder == null) {
      if (widget.onSendTap != null) {
        widget.onSendMap!(message.trim(), replyMessage);
      }
      _assignReplyMessage();
    }
    chatController.scrollToLastMessage();
  }

  void _assignReplyMessage() {
    if (replyMessage.message.isNotEmpty) {
      setState(() => replyMessage = const ReplyMessage());
    }
  }
}
