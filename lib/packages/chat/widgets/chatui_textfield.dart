import 'dart:io' show Platform;

import 'package:akarak/configs/routes.dart';
import 'package:akarak/models/model_coordinate.dart';
import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:akarak/utils/translate.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../chatview.dart';
import '../app_properties.dart';
import '../models/attachment_message.dart';
import '../utils/constants.dart';
import '../utils/package_strings.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'app_placeholder.dart';

class ChatUITextField extends StatefulWidget {
  const ChatUITextField({
    Key? key,
    required this.onSendMap,
    this.questionMessage,
    this.replyTo,
    required this.replyMessage,
    required this.onCloseTap,
    this.sendMessageConfig,
    required this.focusNode,
    required this.textEditingController,
    required this.onPressed,
    required this.onRecordingComplete,
  }) : super(key: key);
  final StringMessageCallBack onSendMap;
  final AttachmentMessage? questionMessage;
  final String? replyTo;
  final ReplyMessage replyMessage;
  final VoidCallBack onCloseTap;
  final SendMessageConfiguration? sendMessageConfig;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final VoidCallBack onPressed;
  final Function(String?, Duration?) onRecordingComplete;

  @override
  State<ChatUITextField> createState() => _ChatUITextFieldState();
}

class _ChatUITextFieldState extends State<ChatUITextField> {
  String _inputText = '';
  bool sendButton = false;
  bool show = false;
  AttachmentMessage? questionMessage;
  final ImagePicker _imagePicker = ImagePicker();

  RecorderController? controller;

  bool isRecording = false;
  bool isPause = false;

  SendMessageConfiguration? get sendMessageConfig => widget.sendMessageConfig;

  VoiceRecordingConfiguration? get voiceRecordingConfig =>
      widget.sendMessageConfig?.voiceRecordingConfiguration;

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      sendMessageConfig?.imagePickerIconsConfig;

  TextFieldConfiguration? get textFieldConfig =>
      sendMessageConfig?.textFieldConfig;

  OutlineInputBorder get _outLineBorder => OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
      );

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      controller = RecorderController();
      questionMessage = widget.questionMessage;
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.insert_drive_file, Colors.indigo,
                      PackageStrings.document),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                      Icons.camera_alt, Colors.pink, PackageStrings.camera),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple,
                      PackageStrings.gallery),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.headset, Colors.orange, PackageStrings.audio),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                      Icons.location_pin, Colors.teal, PackageStrings.location),
                  const SizedBox(
                    width: 40,
                  ),
                  const SizedBox(
                    width: 65,
                  ),
                  // iconCreation(
                  //     Icons.person, Colors.transparent, PackageStrings.contact),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (text == PackageStrings.camera) {
          _onIconPressed(ImageSource.camera);
        } else if (text == PackageStrings.gallery) {
          _onIconPressed(ImageSource.gallery);
        } else if (text == PackageStrings.audio) {
          _onSelectAudio();
        } else if (text == PackageStrings.location) {
          _onSelectLocation();
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Wrap(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  if (isRecording && controller != null) ...[
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      child: Card(
                        margin:
                            const EdgeInsets.only(left: 2, right: 2, bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            if (questionMessage != null &&
                                questionMessage!.hasValue())
                              questionWidget()
                            else if (widget.replyMessage.message.isNotEmpty)
                              replyWidget(),
                            Row(
                              children: [
                                AudioWaveforms(
                                  size: Size(
                                      MediaQuery.of(context).size.width -
                                          80 -
                                          70,
                                      50),
                                  recorderController: controller!,
                                  margin: voiceRecordingConfig?.margin,
                                  padding: voiceRecordingConfig?.padding ??
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration:
                                      voiceRecordingConfig?.decoration ??
                                          BoxDecoration(
                                            color: voiceRecordingConfig
                                                ?.backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                  waveStyle: voiceRecordingConfig?.waveStyle ??
                                      WaveStyle(
                                        extendWaveform: true,
                                        showMiddleLine: false,
                                        waveColor: voiceRecordingConfig
                                                ?.waveStyle?.waveColor ??
                                            Colors.black,
                                      ),
                                ),
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: IconButton(
                                    icon: Icon(
                                      isPause ? Icons.play_arrow : Icons.pause,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () async {
                                      if (isPause) {
                                        await controller?.record();
                                      } else {
                                        await controller?.pause();
                                      }
                                      isPause = !isPause;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      child: Card(
                        margin:
                            const EdgeInsets.only(left: 2, right: 2, bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            if (questionMessage != null &&
                                questionMessage!.hasValue())
                              questionWidget()
                            else if (widget.replyMessage.message.isNotEmpty)
                              replyWidget(),
                            TextFormField(
                              controller: widget.textEditingController,
                              focusNode: widget.focusNode,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              onChanged: (value) {
                                if (value.length > 0) {
                                  setState(() {
                                    sendButton = true;
                                  });
                                } else {
                                  setState(() {
                                    sendButton = false;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: PackageStrings.message,
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: IconButton(
                                  icon: Icon(
                                    show
                                        ? Icons.keyboard
                                        : Icons.emoji_emotions_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    if (!show) {
                                      widget.focusNode.unfocus();
                                      widget.focusNode.canRequestFocus = false;
                                    }
                                    setState(() {
                                      show = !show;
                                    });
                                  },
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (builder) =>
                                                bottomSheet());
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _onIconPressed(ImageSource.camera),
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      right: 2,
                      left: 2,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          child: IconButton(
                            icon: Icon(
                              sendButton || show
                                  ? Icons.send
                                  : isRecording
                                      ? Icons.stop
                                      : Icons.mic,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (sendButton || show) {
                                // _scrollController.animateTo(
                                //     _scrollController.position.maxScrollExtent,
                                //     duration: Duration(milliseconds: 300),
                                //     curve: Curves.easeOut);
                                widget.onPressed();
                                setState(() => _inputText = '');
                                widget.textEditingController.clear();
                                setState(() {
                                  sendButton = false;
                                });
                              } else {
                                if (widget.sendMessageConfig
                                        ?.allowRecordingVoice ??
                                    true &&
                                        Platform.isIOS &&
                                        Platform.isAndroid) {
                                  _recordOrStop();
                                }
                              }
                            },
                          ),
                        ),
                        if (isRecording) ...[
                          const SizedBox(height: 4),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey,
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                isRecording = false;
                                await controller?.stop();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              show
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: emojiSelect())
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _recordOrStop() async {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    if (!isRecording) {
      await controller?.record();
      isRecording = true;
    } else {
      final path = await controller?.stop();
      isRecording = false;
      final audioPlayer = AudioPlayer();
      var duration = await audioPlayer.setFilePath(path!);
      widget.onRecordingComplete(path, duration);
    }
    setState(() {});
  }

  void _onIconPressed(ImageSource imageSource) async {
    final onImageSelected = imagePickerIconsConfig?.onImageSelected;
    try {
      if (onImageSelected != null) {
        final XFile? image = await _imagePicker.pickImage(source: imageSource);
        onImageSelected(image?.path ?? '', widget.replyMessage, '');
      }
    } catch (e) {
      if (onImageSelected != null) {
        onImageSelected(
          '',
          widget.replyMessage,
          e.toString(),
        );
      }
    }
  }

  void onChanged(String inputText) => setState(() => _inputText = inputText);

  Widget questionWidget() {
    final TextDirection currentDirection = Directionality.of(context);
    final bool isRTL = currentDirection == TextDirection.rtl;
    if (widget.questionMessage != null) {
      return Container(
        decoration: BoxDecoration(
          color: widget.sendMessageConfig?.textFieldBackgroundColor ??
              Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        ),
        margin: const EdgeInsets.only(
          bottom: 0.4,
          right: 0.4,
          left: 0.4,
        ),
        padding: const EdgeInsets.fromLTRB(
          leftPadding,
          leftPadding,
          leftPadding,
          0,
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (questionMessage!.image.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: questionMessage!.image,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              constraints: const BoxConstraints(
                                  minHeight: 60, minWidth: 60),
                              // width: 60,
                              // height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fitWidth,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isRTL ? 0 : 5),
                                  topRight: Radius.circular(isRTL ? 5 : 0),
                                  bottomLeft: Radius.circular(isRTL ? 0 : 5),
                                  bottomRight: Radius.circular(isRTL ? 5 : 0),
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) {
                            return AppPlaceholder(
                              child: Container(
                                constraints: const BoxConstraints(
                                    minHeight: 60, minWidth: 60),
                                // width: 60,
                                // height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return AppPlaceholder(
                              child: Container(
                                constraints: const BoxConstraints(
                                    minHeight: 60, minWidth: 60),
                                // width: 60,
                                // height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                ),
                                child: const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionMessage!.name,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.25,
                              ),
                            ),
                            if (questionMessage!.description.isNotEmpty)
                              Text(
                                questionMessage!.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  letterSpacing: 0.25,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.close,
                  color:
                      widget.sendMessageConfig?.closeIconColor ?? Colors.black,
                  size: 16,
                ),
                onPressed: () {
                  widget.onCloseTap();
                  if (questionMessage != null && questionMessage!.hasValue()) {
                    questionMessage = null;
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget replyWidget() {
    if (widget.replyMessage.message.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: widget.sendMessageConfig?.textFieldBackgroundColor ??
              Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        ),
        margin: const EdgeInsets.only(
          bottom: 4,
          right: 0.4,
          left: 0.4,
        ),
        padding: const EdgeInsets.fromLTRB(
          leftPadding,
          leftPadding,
          leftPadding,
          0,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: widget.sendMessageConfig?.replyDialogColor ??
                Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${PackageStrings.replyTo} ${widget.replyTo}",
                    style: TextStyle(
                      color: widget.sendMessageConfig?.replyTitleColor ??
                          mediumYellow.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.25,
                    ),
                  ),
                  IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        color: widget.sendMessageConfig?.closeIconColor ??
                            Colors.black,
                        size: 16,
                      ),
                      onPressed: () {
                        widget.onCloseTap();
                        if (questionMessage != null &&
                            questionMessage!.hasValue()) {
                          questionMessage = null;
                        }
                      }),
                ],
              ),
              widget.replyMessage.messageType.isVoice
                  ? Row(
                      children: [
                        Icon(
                          Icons.mic,
                          color: widget.sendMessageConfig?.micIconColor,
                        ),
                        const SizedBox(width: 4),
                        if (widget.replyMessage.voiceMessageDuration != null)
                          Text(
                            widget.replyMessage.voiceMessageDuration!
                                .toHHMMSS(),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  widget.sendMessageConfig?.replyMessageColor ??
                                      Colors.black,
                            ),
                          ),
                      ],
                    )
                  : widget.replyMessage.messageType.isMap
                      ? Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: widget.sendMessageConfig?.micIconColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Translate.of(context).translate('address'),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget
                                        .sendMessageConfig?.replyMessageColor ??
                                    Colors.black,
                              ),
                            ),
                          ],
                        )
                      : widget.replyMessage.messageType.isImage
                          ? Row(
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 20,
                                  color: widget.sendMessageConfig
                                          ?.replyMessageColor ??
                                      Colors.grey.shade700,
                                ),
                                Text(
                                  Translate.of(context).translate('photo'),
                                  style: TextStyle(
                                    color: widget.sendMessageConfig
                                            ?.replyMessageColor ??
                                        Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.replyMessage.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget
                                        .sendMessageConfig?.replyMessageColor ??
                                    Colors.black,
                              ),
                            ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  ///On Select Location
  void _onSelectLocation() async {
    // String url = "https://www.google.com/maps/@15.377003,44.2153021,18z";
    // widget.onSendMap(url, widget.replyMessage);
    final selected = await Navigator.pushNamed(
      context,
      Routes.gpsPicker,
      arguments: null,
    );
    if (selected != null && selected is CoordinateModel) {
      setState(() {
        String url =
            "https://google.com/maps/@${selected.latitude},${selected.longitude}18.24z";
        widget.onSendMap(url, widget.replyMessage);
      });
    }
  }

  ///On Select Audio
  void _onSelectAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a'],
    );

    if (result != null) {
      PlayerController playerController = PlayerController();
      await playerController.extractWaveformData(
        path: result.files.single.path!,
        noOfSamples: 100,
      );
      final duration = await playerController
          .getDuration(DurationType.max); // Get duration of audio player

      widget.onRecordingComplete(
          result.files.single.path, Duration(milliseconds: duration));
      // File file = File(result.files.single.path);
    }
  }

  Widget emojiSelect() {
    // return EmojiPicker(
    //     config: Config(columns: 7),
    //     onEmojiSelected: (emoji, category) {
    //       print(emoji);
    //       setState(() {
    //         widget.textEditingController.text =
    //             widget.textEditingController.text + emoji.toString();
    //       });
    //     });
    return emoji.EmojiPicker(
      onEmojiSelected: (emoji.Category? category, emoji.Emoji emoji) {
        // Do something when emoji is tapped (optional)
      },
      onBackspacePressed: () {
        // Do something when the user taps the backspace button (optional)
        // Set it to null to hide the Backspace-Button
      },
      textEditingController: widget
          .textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
      config: emoji.Config(
        columns: 7,
        emojiSizeMax: 32 *
            (foundation.defaultTargetPlatform == TargetPlatform.iOS
                ? 1.30
                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: emoji.Category.RECENT,
        bgColor: const Color(0xFFF2F2F2),
        indicatorColor: Colors.blue,
        iconColor: Colors.grey,
        iconColorSelected: Colors.blue,
        backspaceColor: Colors.blue,
        skinToneDialogBgColor: Colors.white,
        skinToneIndicatorColor: Colors.grey,
        enableSkinTones: true,
        showRecentsTab: true,
        recentsLimit: 28,
        noRecents: const Text(
          'No Recents',
          style: TextStyle(fontSize: 20, color: Colors.black26),
          textAlign: TextAlign.center,
        ), // Needs to be const Widget
        loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: const emoji.CategoryIcons(),
        buttonMode: emoji.ButtonMode.MATERIAL,
      ),
    );
  }
}
