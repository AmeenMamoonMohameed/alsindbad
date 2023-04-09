import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:vibration/vibration.dart';
// import 'package:workmanager/workmanager.dart';

import '../../configs/application.dart';
import '../../notificationservice_.dart';
import '../../repository/chat_repository.dart';
import '../../widgets/widget.dart';

class ContactUs extends StatefulWidget {
  final ContactUsModel? msg;

  const ContactUs({
    Key? key,
    this.msg,
  }) : super(key: key);

  @override
  _ContactUsState createState() {
    return _ContactUsState();
  }
}

class _ContactUsState extends State<ContactUs> {
  final _textMsgController = TextEditingController();
  final _textTitleController = TextEditingController();
  final _focusMsg = FocusNode();
  final _focusTitle = FocusNode();

  String? _errorMsg;
  String? _errorTitle;

  @override
  void initState() {
    super.initState();
    _textMsgController.text = widget.msg == null ? '' : widget.msg!.content;
  }

  @override
  void dispose() {
    _textMsgController.dispose();
    _textTitleController.dispose();
    _focusMsg.dispose();
    _focusTitle.dispose();
    super.dispose();
  }

  ///On send
  void _onSave() async {
    UtilOther.hiddenKeyboard(context);
    setState(() {
      _errorMsg = UtilValidator.validate(_textMsgController.text);
      _errorTitle = UtilValidator.validate(_textTitleController.text);
    });
    if (_errorMsg == null && _errorTitle == null) {
      // For new msg
      final result = await ChatRepository.sendMessageContactUs(
          _textTitleController.text, _textMsgController.text);

      if (result != null) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "discoveryScreen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('contact_us'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                          // httpHeaders: {
                          //   "Authorization": "Basic",
                          // },
                          imageUrl: Application.domain +
                              AppBloc.userCubit.state!.profilePictureDataUrl
                                  .replaceAll("\\", "/")
                                  .replaceAll("TYPE", "thumb"),
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) {
                            return AppPlaceholder(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return AppPlaceholder(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.error),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppBloc.userCubit.state!.accountName,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              Translate.of(context).translate('title'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          AppTextInput(
                            hintText: Translate.of(context).translate(
                              'input_title',
                            ),
                            errorText: _errorTitle,
                            focusNode: _focusTitle,
                            maxLines: 1,
                            trailing: GestureDetector(
                              dragStartBehavior: DragStartBehavior.down,
                              onTap: () {
                                _textTitleController.clear();
                              },
                              child: const Icon(Icons.clear),
                            ),
                            onSubmitted: (text) {
                              _onSave();
                            },
                            onChanged: (text) {
                              setState(() {
                                _errorTitle = UtilValidator.validate(
                                  _textTitleController.text,
                                );
                              });
                            },
                            controller: _textTitleController,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              Translate.of(context).translate('message'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          AppTextInput(
                            hintText: Translate.of(context).translate(
                              'input_message',
                            ),
                            errorText: _errorMsg,
                            focusNode: _focusMsg,
                            maxLines: 7,
                            trailing: GestureDetector(
                              dragStartBehavior: DragStartBehavior.down,
                              onTap: () {
                                _textMsgController.clear();
                              },
                              child: const Icon(Icons.clear),
                            ),
                            onSubmitted: (text) {
                              _onSave();
                            },
                            onChanged: (text) {
                              setState(() {
                                _errorMsg = UtilValidator.validate(
                                  _textMsgController.text,
                                );
                              });
                            },
                            controller: _textMsgController,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppButton(
                Translate.of(context).translate('send'),
                onPressed: _onSave,
                mainAxisSize: MainAxisSize.max,
              ),
            )
          ],
        ),
      ),
    );
  }
}
