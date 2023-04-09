import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/screens/chat/theme.dart' as chatTheme;
import 'package:akarak/utils/translate.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/model.dart';
import '../../packages/chat/chatview.dart';
import '../../packages/chat/models/attachment_message.dart';
import '../../repository/repository.dart';
import '../../utils/validate.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_input.dart';
import 'data.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel chatUser;
  final AttachmentMessage? questionMessage;
  const ChatScreen({Key? key, required this.chatUser, this.questionMessage})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  chatTheme.AppTheme theme = chatTheme.LightTheme();
  bool isDarkTheme = false;
  ChatUser? currentUser;
  AttachmentMessage? questionMessage;
  // List<Message> messages = [];
  ChatController? _chatController;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    questionMessage = widget.questionMessage;
    scrollController = ScrollController();
    scrollController.addListener(() {});
    currentUser = ChatUser(
      id: AppBloc.userCubit.state!.userId,
      name: AppBloc.userCubit.state!.accountName,
      profilePhoto: Data.profileImage,
    );
    _chatController = ChatController(
        initialMessageList: [],
        scrollController: scrollController,
        chatUsers: [
          ChatUser(
            id: AppBloc.userCubit.state!.userId,
            name: AppBloc.userCubit.state!.accountName,
            profilePhoto: Data.profileImage,
          ),
          ChatUser(
            id: widget.chatUser.userId,
            name: widget.chatUser.accountName,
            profilePhoto: Data.profileImage,
          ),
        ],
        onSetReaction: _onSetReaction);
    AppBloc.chatCubit.chatId = widget.chatUser.chatId;
    AppBloc.chatCubit.contactId = widget.chatUser.userId;
    AppBloc.chatCubit.onLoadChat();
  }

  @override
  void dispose() {
    AppBloc.chatCubit.contactId = '';
    AppBloc.chatCubit.chatId = 0;
    AppBloc.chatCubit.chatList = [];
    _chatController!.dispose();
    super.dispose();
  }

  ///On block user
  void _onBlock(
    BuildContext mainContext,
  ) async {
    String? errorTitle;
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? title;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('block'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context).translate('because_of'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 2,
                  errorText: errorTitle,
                  hintText: errorTitle ??
                      Translate.of(context).translate('because_of'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      title = text;
                      errorTitle =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('confirm'),
              onPressed: () async {
                errorTitle =
                    UtilValidator.validate(title ?? "", allowEmpty: true);
                setState(() {});
                if (errorTitle == null) {
                  Navigator.pop(context);
                  final result = await ChatRepository.blockUser(
                      userId: widget.chatUser.userId, because: title);
                  if (result ?? false) {
                    Navigator.pop(mainContext);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  ///On report product
  void _onReport(
    BuildContext context_,
  ) async {
    String? errorTitle;
    String? errorDescription;
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? title;
        String? description;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('report'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context)
                      .translate('specify_the_main_reason_for_reporting'),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 2,
                  errorText: errorTitle,
                  hintText: errorTitle ??
                      Translate.of(context).translate('report_title'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      title = text;
                      errorTitle =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 10,
                  errorText: errorDescription,
                  hintText: errorDescription ??
                      Translate.of(context).translate('report_description'),
                  controller: TextEditingController(),
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      description = text;
                      errorDescription =
                          UtilValidator.validate(text, allowEmpty: false);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('confirm'),
              onPressed: () async {
                errorTitle =
                    UtilValidator.validate(title ?? "", allowEmpty: false);
                errorDescription = UtilValidator.validate(description ?? "",
                    allowEmpty: false);
                setState(() {});
                if (errorTitle == null && errorDescription == null) {
                  Navigator.pop(context, description);
                  final result = await ChatRepository.sendReport(ReportModel(
                      reportedId: widget.chatUser.userId,
                      name: title!,
                      description: description!,
                      type: ReportType.profile));
                  if (result != null) {
                    AppBloc.messageCubit.onShow(Translate.of(context_)
                        .translate('the_message_has_been_sent'));
                  } else {
                    AppBloc.messageCubit.onShow(Translate.of(context_)
                        .translate(
                            'an_error_occurred,_the_message_was_not_sent'));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // _chatController.messageStreamController.sink.();
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(Images
                .chatbackground), //NetworkImage(chatBackgroundConfig.backgroundImage!),
          ),
        ),
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context_, state) {
            if (state is ReadStatusSuccess) {
              for (int i = 0;
                  i < _chatController!.initialMessageList.length;
                  i++) {
                if (_chatController!.initialMessageList[i].status !=
                    Status.seen) {
                  _chatController!.initialMessageList[i] = _chatController!
                      .initialMessageList[i]
                      .copyWith(status: Status.seen);
                }
              }
            }
            if (state is DeliveredStatusSuccess) {
              for (int i = 0;
                  i < _chatController!.initialMessageList.length;
                  i++) {
                if (_chatController!.initialMessageList[i].status !=
                        Status.delivered &&
                    _chatController!.initialMessageList[i].status !=
                        Status.seen) {
                  _chatController!.initialMessageList[i] = _chatController!
                      .initialMessageList[i]
                      .copyWith(status: Status.delivered);
                }
              }
            }
            if (state is NewReactionSuccess) {
              final index = _chatController!.initialMessageList
                  .indexWhere((item) => item.id == state.messageId.toString());
              _chatController!.initialMessageList[index] =
                  _chatController!.initialMessageList[index].copyWith(
                      reaction:
                          (state.reactions == null || state.reactions!.isEmpty)
                              ? null
                              : Reaction(
                                  reactions: state.reactions!,
                                  reactedUserIds: state.reactedUserIds!));
            }
            if (state is ChatSuccess) {
              for (int i = (state).list.length - 1; i >= 0; i--) {
                if (!_chatController!.initialMessageList.any(
                    (element) => element.id == state.list[i].id.toString())) {
                  _chatController!.initialMessageList.insert(
                      ((state).list.length - 1) - i,
                      Message(
                        id: state.list[i].id.toString(),
                        message: state.list[i].message,
                        createdAt: state.list[i].createdDate!,
                        sendBy: state.list[i].fromUserId,
                        replyMessage:
                            state.list[i].reply ?? const ReplyMessage(),
                        reaction: state.list[i].reactions != null
                            ? Reaction(
                                reactions: state.list[i].reactions ?? [],
                                reactedUserIds:
                                    state.list[i].reactedUserIds ?? [])
                            : null,
                        attachmentMessage: state.list[i].attachment,
                        messageType: state.list[i].type,
                        status: state.list[i].status,
                      ));
                }
              }
            }
            return _buildChatView();
          },
        ),
      ),
    );
  }

  _onTapMessage(Message message) {
    if (message.attachmentMessage == null ||
        !message.attachmentMessage!.hasValue()) return;

    if (message.attachmentMessage!.type == AttachmentType.question) {
      // Navigator.pop(context);
      // Navigator.pop(context);
      if (message.attachmentMessage!.data!['hasMap'] ?? false) {
        Navigator.pushNamed(
          context,
          Routes.productDetail,
          arguments: {
            "id": int.parse(message.attachmentMessage!.id),
            "categoryId": message.attachmentMessage!.data!['categoryId'],
          },
        );
      } else {
        Navigator.pushNamed(
          context,
          Routes.productScreen,
          arguments: {
            "id": int.parse(message.attachmentMessage!.id),
            "categoryId": message.attachmentMessage!.data!['categoryId'],
          },
        );
      }
    }
  }

  ChatView _buildChatView() {
    return ChatView(
      onTapMessage: _onTapMessage,
      loadingWidget: const Padding(
        padding: EdgeInsets.only(top: 16),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
      questionMessage: questionMessage,
      onCloseQuestion: () {
        questionMessage = null;
        setState(() {});
      },
      currentUser: currentUser!,
      chatController: _chatController!,
      onSendMap: _onSendMap,
      onSendTap: _onSendTap,
      onRecordingComplete: onRecordingComplete,
      chatViewState: ChatViewState.hasMessages,
      chatViewStateConfig: ChatViewStateConfiguration(
        loadingWidgetConfig: ChatViewStateWidgetConfiguration(
          loadingIndicatorColor: theme.outgoingChatBubbleColor,
        ),
        onReloadButtonTap: () {},
      ),
      typeIndicatorConfig: TypeIndicatorConfiguration(
        flashingCircleBrightColor: theme.flashingCircleBrightColor,
        flashingCircleDarkColor: theme.flashingCircleDarkColor,
      ),
      featureActiveConfig: const FeatureActiveConfig(
        enableSwipeToReply: true,
        enableSwipeToSeeTime: true,
        enablePagination: true,
      ),
      appBar: ChatViewAppBar(
        elevation: theme.elevation,
        backGroundColor: theme.appBarColor,
        profilePicture:
            Data.profileImage, // widget.chatUser.profilePictureDataUrl,
        backArrowColor: theme.backArrowColor,
        onTapProfile: () {
          Navigator.pushNamed(context, Routes.profile,
              arguments: widget.chatUser.userId);
        },
        chatTitle: widget.chatUser.accountName,
        chatTitleTextStyle: TextStyle(
          color: theme.appBarTitleTextStyle,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.25,
        ),
        userStatus: "online",
        userStatusTextStyle: const TextStyle(color: Colors.grey),
        actions: [
          // IconButton(
          //   onPressed: _onThemeIconTap,
          //   icon: Icon(
          //     isDarkTheme
          //         ? Icons.brightness_4_outlined
          //         : Icons.dark_mode_outlined,
          //     color: theme.themeIconColor,
          //   ),
          // ),
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Text(Translate.of(context).translate("block")),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text(Translate.of(context).translate("report")),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              _onBlock(context);
            } else if (value == 1) {
              _onReport(context);
            }
          }),
        ],
      ),
      isLastPage: (AppBloc.chatCubit.state is ChatSuccess)
          ? !(AppBloc.chatCubit.state as ChatSuccess).canLoadMore
          : false,
      loadMoreData: _loadMore,
      chatBackgroundConfig: ChatBackgroundConfiguration(
        messageTimeIconColor: theme.messageTimeIconColor,
        backgroundImage: Images.chatbackground,
        messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
        defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
          textStyle: TextStyle(
            color: theme.chatHeaderColor,
            fontSize: 17,
          ),
        ),
        backgroundColor: theme.backgroundColor,
      ),
      sendMessageConfig: SendMessageConfiguration(
        imagePickerIconsConfig: ImagePickerIconsConfiguration(
          cameraIconColor: theme.cameraIconColor,
          galleryIconColor: theme.galleryIconColor,
          onImageSelected: (imagePath, replyMessage, error) {
            _onSendTapImage(imagePath, replyMessage);
          },
        ),
        replyMessageColor: theme.replyMessageColor,
        defaultSendButtonColor: theme.sendButtonColor,
        replyDialogColor: theme.replyDialogColor,
        replyTitleColor: theme.replyTitleColor,
        textFieldBackgroundColor: theme.textFieldBackgroundColor,
        closeIconColor: theme.closeIconColor,
        textFieldConfig: TextFieldConfiguration(
          textStyle: TextStyle(color: theme.textFieldTextColor),
        ),
        micIconColor: theme.replyMicIconColor,
        voiceRecordingConfiguration: VoiceRecordingConfiguration(
          backgroundColor: theme.waveformBackgroundColor,
          recorderIconColor: theme.recordIconColor,
          waveStyle: WaveStyle(
            showMiddleLine: false,
            waveColor: theme.waveColor ?? Colors.white,
            extendWaveform: true,
          ),
        ),
      ),
      chatBubbleConfig: ChatBubbleConfiguration(
        outgoingChatBubbleConfig: ChatBubble(
          linkPreviewConfig: LinkPreviewConfiguration(
            backgroundColor: theme.linkPreviewOutgoingChatColor,
            bodyStyle: theme.outgoingChatLinkBodyStyle,
            titleStyle: theme.outgoingChatLinkTitleStyle,
          ),
          color: theme.outgoingChatBubbleColor,
        ),
        inComingChatBubbleConfig: ChatBubble(
          linkPreviewConfig: LinkPreviewConfiguration(
            linkStyle: TextStyle(
              color: theme.inComingChatBubbleTextColor,
              decoration: TextDecoration.underline,
            ),
            backgroundColor: theme.linkPreviewIncomingChatColor,
            bodyStyle: theme.incomingChatLinkBodyStyle,
            titleStyle: theme.incomingChatLinkTitleStyle,
          ),
          textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
          senderNameTextStyle:
              TextStyle(color: theme.inComingChatBubbleTextColor),
          color: theme.inComingChatBubbleColor,
        ),
      ),
      replyPopupConfig: ReplyPopupConfiguration(
        backgroundColor: theme.replyPopupColor,
        buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
        topBorderColor: theme.replyPopupTopBorderColor,
      ),
      reactionPopupConfig: ReactionPopupConfiguration(
        glassMorphismConfig: GlassMorphismConfiguration(),
        shadow: BoxShadow(
          color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
          blurRadius: 20,
        ),
        backgroundColor: theme.reactionPopupColor,
      ),
      messageConfig: MessageConfiguration(
        token: AppBloc.userCubit.state?.token ?? '',
        chatToken: AppBloc.chatCubit.chatToken ?? '',
        messageReactionConfig: MessageReactionConfiguration(
          backgroundColor: theme.messageReactionBackGroundColor,
          borderColor: theme.messageReactionBackGroundColor,
          reactedUserCountTextStyle:
              TextStyle(color: theme.inComingChatBubbleTextColor),
          reactionCountTextStyle:
              TextStyle(color: theme.inComingChatBubbleTextColor),
          reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
            backgroundColor: theme.backgroundColor,
            reactedUserTextStyle: TextStyle(
              color: theme.inComingChatBubbleTextColor,
            ),
            reactionWidgetDecoration: BoxDecoration(
              color: theme.inComingChatBubbleColor,
              boxShadow: [
                BoxShadow(
                  color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                  offset: const Offset(0, 20),
                  blurRadius: 40,
                )
              ],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        imageMessageConfig: ImageMessageConfiguration(
          onTap: (msg) {
            dynamic d = msg;
          },
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          shareIconConfig: ShareIconConfiguration(
            onPressed: (msgg) {
              dynamic d = msgg;
            },
            defaultIconBackgroundColor: theme.shareIconBackgroundColor,
            defaultIconColor: theme.shareIconColor,
          ),
        ),
      ),
      profileCircleConfig:
          ProfileCircleConfiguration(profileImageUrl: Data.profileImage),
      repliedMessageConfig: RepliedMessageConfiguration(
        backgroundColor: theme.repliedMessageColor,
        verticalBarColor: theme.verticalBarColor,
        repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
          enableHighlightRepliedMsg: true,
          highlightColor: Colors.pinkAccent.shade100,
          highlightScale: 1.1,
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
        ),
        replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
      ),
      swipeToReplyConfig: SwipeToReplyConfiguration(
        replyIconColor: theme.swipeToReplyIconColor,
      ),
      localize: {
        'message': Translate.of(context).translate('message'),
        'more': Translate.of(context).translate('more'),
        'photo': Translate.of(context).translate('photo'),
        'reactionPopupTitle':
            Translate.of(context).translate('reactionPopupTitle'),
        'repliedBy': Translate.of(context).translate('repliedBy'),
        'repliedByYou': Translate.of(context).translate('repliedByYou'),
        'reply': Translate.of(context).translate('reply'),
        'replyTo': Translate.of(context).translate('replyTo'),
        'send': Translate.of(context).translate('send'),
        'today': Translate.of(context).translate('today'),
        'unsend': Translate.of(context).translate('unsend'),
        'yesterday': Translate.of(context).translate('yesterday'),
        'you': Translate.of(context).translate('you'),
        'errorMalformedEmojiName':
            Translate.of(context).translate('errorMalformedEmojiName'),
        'document': Translate.of(context).translate('document'),
        'camera': Translate.of(context).translate('camera'),
        'gallery': Translate.of(context).translate('gallery'),
        'audio': Translate.of(context).translate('audio'),
        'location': Translate.of(context).translate('location'),
        'contact': Translate.of(context).translate('contact'),
      },
    );
  }

  Future<void> _loadMore() async {
    final list = await AppBloc.chatCubit.onLoadMoreChatTest();
    if (list != null) {
      List<Message> listMessages = [];
      for (int i = list.length - 1; i >= 0; i--) {
        if (!_chatController!.initialMessageList
            .any((element) => element.id == list[i].id.toString())) {
          listMessages.add(Message(
            id: list[i].id.toString(),
            message: list[i].message,
            createdAt: list[i].createdDate!,
            sendBy: list[i].fromUserId,
            replyMessage: list[i].reply ?? const ReplyMessage(),
            reaction: list[i].reactions != null
                ? Reaction(
                    reactions: list[i].reactions ?? [],
                    reactedUserIds: list[i].reactedUserIds ?? [])
                : null,
            attachmentMessage: list[i].attachment,
            messageType: list[i].type,
            status: list[i].status,
          ));
        }
      }
      _chatController!.loadMoreData(listMessages);
    }
  }

  Future<void> _onSendTap(
    String message,
    ReplyMessage replyMessage,
  ) async {
    final id = int.parse(_chatController!.initialMessageList.last.id) + 1;
    _chatController!.addMessage(
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser!.id,
        replyMessage: replyMessage,
        attachmentMessage: questionMessage,
        messageType: MessageType.text,
        status: Status.sending,
      ),
    );
    await _onSubmit(
        remotId: id.toString(),
        message: message,
        replyMessage: replyMessage,
        questionMessage: questionMessage);
  }

  Future<void> _onSendMap(
    String message,
    ReplyMessage replyMessage,
  ) async {
    final id = int.parse(_chatController!.initialMessageList.last.id) + 1;
    _chatController!.addMessage(
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser!.id,
        replyMessage: replyMessage,
        attachmentMessage: questionMessage,
        messageType: MessageType.map,
        status: Status.sending,
      ),
    );
    await _onSubmit(
        remotId: id.toString(),
        message: message,
        replyMessage: replyMessage,
        questionMessage: questionMessage,
        type: MessageType.map);
  }

  Future<void> _onSetReaction(
    String emoji,
    String messageId,
    String userId,
  ) async {
    final result = await AppBloc.chatCubit
        .onSendReaction(messageId: int.parse(messageId), emoji: emoji);
    if (!result) {
      final index = _chatController!.initialMessageList
          .indexWhere((element) => element.id == messageId);
      _chatController!.initialMessageList[index].reaction.reactions
          .remove(emoji);
      _chatController!.initialMessageList[index].reaction.reactedUserIds
          .remove(currentUser!.id);
      setState(() {});
    }
  }

  Future<void> _onSendTapImage(
    String filePath,
    ReplyMessage replyMessage,
  ) async {
    if (filePath.isEmpty) return;
    final id = int.parse(_chatController!.initialMessageList.last.id) + 1;
    final file = File(filePath);
    Uint8List bytes = file.readAsBytesSync();
    String bs4str = base64Encode(bytes);

    _chatController!.addMessage(
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: bs4str,
        replyMessage: replyMessage,
        sendBy: currentUser!.id,
        messageType: MessageType.image,
        status: Status.sending,
      ),
    );
    await _onSubmit(
        remotId: id.toString(),
        message: filePath,
        replyMessage: null,
        type: MessageType.image);
  }

  Future<void> onRecordingComplete(
    String audioPath,
    Duration? voiceMessageDuration,
    ReplyMessage replyMessage,
  ) async {
    final id = int.parse(_chatController!.initialMessageList.last.id) + 1;
    _chatController!.addMessage(Message(
      id: id.toString(),
      createdAt: DateTime.now(),
      message: audioPath,
      replyMessage: replyMessage,
      attachmentMessage: questionMessage,
      sendBy: currentUser!.id,
      messageType: MessageType.voice,
      voiceMessageDuration: voiceMessageDuration,
      status: Status.sending,
    ));
    await _onSubmit(
        remotId: id.toString(),
        message: audioPath,
        replyMessage: replyMessage,
        type: MessageType.voice,
        voiceMessageDuration: voiceMessageDuration,
        questionMessage: questionMessage);
  }

  Future<void> _onSubmit(
      {required String remotId,
      required String message,
      ReplyMessage? replyMessage,
      Duration? voiceMessageDuration,
      AttachmentMessage? questionMessage,
      MessageType type = MessageType.text}) async {
    Map<String, dynamic>? upload;
    if (type == MessageType.image || type == MessageType.voice) {
      upload = await FileRepository.protectedUploadBuild(
          file: File(message),
          externalId: AppBloc.chatCubit.chatId.toString(),
          type: type == MessageType.image
              ? ProtectedUploadType.image
              : ProtectedUploadType.audio);
    }
    // message submit
    if (questionMessage != null && questionMessage.hasValue()) {
      this.questionMessage = null;
      setState(() {});
    }
    await AppBloc.chatCubit
        .onSave(
            message: ChatModel(
                id: 0,
                chatId: AppBloc.chatCubit.chatList.isNotEmpty
                    ? AppBloc.chatCubit.chatList.first.chatId
                    : 0,
                remoteId: remotId,
                message: message,
                fromUserId: AppBloc.userCubit.state!.userId,
                type: type,
                status: Status.error,
                contactId: widget.chatUser.userId,
                createdDate: null, //DateTime.now(),
                reply: replyMessage,
                voiceMessageDuration: voiceMessageDuration,
                attachment: questionMessage,
                upload: upload),
            progress: (value) {
              final index = _chatController!.initialMessageList
                  .indexWhere((element) => element.id == remotId);
              _chatController!.initialMessageList[index].progressValue =
                  value.toDouble();
              setState(() {});
            })
        .then((int? msgId) {
      if (msgId != null) {
        final index = _chatController!.initialMessageList
            .indexWhere((element) => element.id == remotId);
        final updatedMessage = _chatController!.initialMessageList[index]
            .copyWith(id: msgId.toString(), status: Status.sent);
        _chatController!.initialMessageList[index] = updatedMessage;

        setState(() {});
      } else {
        final index = _chatController!.initialMessageList
            .indexWhere((element) => element.id == remotId);
        final updatedMessage = _chatController!.initialMessageList[index]
            .copyWith(id: msgId.toString(), status: Status.error);
        _chatController!.initialMessageList[index] = updatedMessage;
      }
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = chatTheme.LightTheme();
        isDarkTheme = false;
      } else {
        theme = chatTheme.DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
