import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../packages/chat/models/message.dart';
import '../../repository/chat_repository.dart';

class ChatUsersList extends StatefulWidget {
  const ChatUsersList({Key? key}) : super(key: key);

  @override
  _ChatUsersListState createState() {
    return _ChatUsersListState();
  }
}

class _ChatUsersListState extends State<ChatUsersList> {
  final _scrollController = ScrollController();
  final _endReachedThreshold = 500;
  final _textPickerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _scrollController.addListener(_onScroll);
    Application.newMessagesCount = 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textPickerController.dispose();
    super.dispose();
  }

  ///Handle load more
  void _onScroll() {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = AppBloc.chatUsersListCubit.state;
    if (state is ChatUsersListSuccess &&
        state.canLoadMore &&
        !state.loadingMore) {
      AppBloc.chatUsersListCubit.onLoadMore();
    }
  }

  ///On refresh
  Future<void> _onRefresh() async {
    await AppBloc.chatCubit.onInit(isChatUsers: true);
  }

  ///On Search
  void _onSearch(String text) {
    setState(() {
      AppBloc.chatUsersListCubit.keyword = text;
    });
    _onRefresh();
  }

  ///On navigate product detail
  Future<void> _onchat(ChatUserModel chatUserModel) async {
    // await AppBloc.chatCubit.onLoadMore().then((value) => null);
    Navigator.pushNamed(context, Routes.chat, arguments: chatUserModel)
        .then((value) {
      AppBloc.chatCubit.contactId = "";
      AppBloc.chatCubit.chatId = 0;
      AppBloc.chatCubit.chatList = [];
      _onRefresh();
    });
  }

  ///Action Item
  void _onAction(String userId) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        Widget orderItem = Container();
        // if (item.orderUse) {
        //   orderItem = AppListTitle(
        //     title: Translate.of(context).translate("order"),
        //     leading: const Icon(Icons.pending_actions_outlined),
        //     onPressed: () {
        //       Navigator.pop(context, "order");
        //     },
        //   );
        // }
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Column(
                      children: [
                        orderItem,
                        AppListTitle(
                          title: Translate.of(context).translate("remove"),
                          leading: const Icon(Icons.delete_outline),
                          onPressed: () {
                            Navigator.pop(context, "remove");
                          },
                        ),
                        AppListTitle(
                          title: Translate.of(context).translate("share"),
                          leading: const Icon(Icons.share_outlined),
                          onPressed: () {
                            Navigator.pop(context, "share");
                          },
                          border: false,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result == 'remove') {
      // AppBloc.chatUsersListCubit.onRemove(item.id);
    }
    if (result == 'share') {
      // Share.share(
      //   'Check out my item ${item.link}',
      //   subject: 'ArmaSoft',
      // );
    }
  }

  ///On report product
  void _onReport(BuildContext context_, String userId) async {
    if (!AppBloc.userCubit.state!.phoneNumberConfirmed) {
      UtilOther.showMessage(
        context: context,
        title: Translate.of(context).translate('confirm_phone_number'),
        message: Translate.of(context)
            .translate('the_phone_number_must_be_confirmed_first'),
        func: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.otp,
            arguments: {
              "userId": AppBloc.userCubit.state!.userId,
              "routeName": null
            },
          );
        },
        funcName: Translate.of(context).translate('confirm'),
      );
      return;
    }
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
                      reportedId: userId,
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

  ///On block user
  void _onBlock(
    BuildContext mainContext,
    String userId,
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
                      userId: userId, because: title);
                  if (result ?? false) {
                    _onRefresh();
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
  void _onSettings(BuildContext context_) async {
    await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool enableReadMessageIndicator = Preferences.getBool(
                "${Preferences.enableReadMessageIndicator}_${AppBloc.userCubit.state!.userId}") ??
            true;
        bool enableDeliveredMessageIndicator = Preferences.getBool(
                "${Preferences.enableDeliveredMessageIndicator}_${AppBloc.userCubit.state!.userId}") ??
            true;
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('setting'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  Translate.of(context)
                      .translate('enable_read_message_indicator'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ToggleSwitch(
                      minWidth: 90.0,
                      cornerRadius: 20.0,
                      initialLabelIndex: enableReadMessageIndicator ? 0 : 1,
                      totalSwitches: 2,
                      activeFgColor: Colors.white,
                      activeBgColor: [
                        Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                      ],
                      inactiveBgColor: Theme.of(context).dividerColor,
                      labels: [
                        Translate.of(context).translate('enabled'),
                        Translate.of(context).translate('disabled')
                      ],
                      onToggle: (index) {
                        enableReadMessageIndicator = index == 0;
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context)
                      .translate('enable_delivered_message_indicator'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ToggleSwitch(
                      minWidth: 90.0,
                      cornerRadius: 20.0,
                      initialLabelIndex:
                          enableDeliveredMessageIndicator ? 0 : 1,
                      totalSwitches: 2,
                      activeFgColor: Colors.white,
                      activeBgColor: [
                        Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                      ],
                      inactiveBgColor: Theme.of(context).dividerColor,
                      labels: [
                        Translate.of(context).translate('enabled'),
                        Translate.of(context).translate('disabled')
                      ],
                      onToggle: (index) {
                        enableDeliveredMessageIndicator = index == 0;
                        setState(() {});
                      },
                    ),
                  ],
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
                setState(() {});
                final result1 = await Preferences.setBool(
                    "${Preferences.enableReadMessageIndicator}_${AppBloc.userCubit.state!.userId}",
                    enableReadMessageIndicator);
                final result2 = await Preferences.setBool(
                    "${Preferences.enableDeliveredMessageIndicator}_${AppBloc.userCubit.state!.userId}",
                    enableDeliveredMessageIndicator);
                if (result1 && result2) {
                  AppBloc.messageCubit.onShow(
                      Translate.of(context).translate('settings_saved'));
                  Navigator.pop(context);
                  AppBloc.chatCubit.onSettingsLoad();
                } else {
                  AppBloc.messageCubit.onShow(Translate.of(context).translate(
                      'an_error_occurred_the_settings_were_not_saved'));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext mainContext) {
    // return BlocBuilder<ChatUsersListCubit, ChatUsersListState>(
    AppBloc.chatCubit.onInit(isChatUsers: true);

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        ///Loading
        Widget content = ListView.builder(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 28),
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: AppUserInfo(type: UserViewType.chat),
            );
          },
          itemCount: 8,
        );

        ///Success
        if (state is ChatUserSuccess) {
          int count = state.list.length;
          if (state.loadingMore) {
            count = count + 1;
          }

          content = ListView.builder(
            itemCount: state.list.length,
            itemBuilder: (context, index) {
              var item = state.list[index];
              return Slidable(
                key: ValueKey(item.userId),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      flex: 2,
                      onPressed: (BuildContext? buildContext) {
                        _onBlock(mainContext, item.userId);
                        // setState(() {});
                      },
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      icon: Icons.block,
                      label: Translate.of(context).translate('block'),
                    ),
                    SlidableAction(
                      onPressed: (BuildContext? buildContext) {
                        _onReport(mainContext, item.userId);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.flag,
                      label: Translate.of(context).translate('report'),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 1,
                          color: Theme.of(context).colorScheme.tertiary),
                      bottom: BorderSide(
                          width: 1,
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer),
                    ),
                    color: Colors.white,
                  ),
                  child: Container(
                    color: item.lastMessage?.fromUserId !=
                                AppBloc.userCubit.state?.userId &&
                            item.lastMessage?.status != null &&
                            item.lastMessage!.status != Status.seen
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: AppUserInfo(
                        chatUser: ChatUserModel(
                            userId: item.userId,
                            chatId: item.chatId,
                            userName: item.userName,
                            profilePictureDataUrl: item.profilePictureDataUrl,
                            accountName: item.accountName,
                            fullName: item.fullName,
                            lastMessage: item.lastMessage,
                            lastMessageTimeElapsed: item.lastMessageTimeElapsed,
                            hasNewMessage: item.hasNewMessage,
                            isOnline: item.isOnline),
                        type: UserViewType.chat,
                        onPressed: () async {
                          await _onchat(item);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          ///Empty
          if (state.list.isEmpty) {
            content = Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.sentiment_satisfied),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      Translate.of(context).translate('list_is_empty'),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return WillPopScope(
          onWillPop: () async {
            if (Application.scaffoldKey.currentState == null ||
                Application.scaffoldKey.currentState!.isDrawerOpen) {
              Navigator.of(context).pop();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(Translate.of(context).translate('chat_users_list')),
              actions: <Widget>[
                PopupMenuButton(
                    // add icon, by default "3 dot" icon
                    // icon: Icon(Icons.book)
                    itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child:
                          Text(Translate.of(context).translate('blocked_list')),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text(Translate.of(context).translate('setting')),
                    ),
                  ];
                }, onSelected: (value) {
                  if (value == 0) {
                    Navigator.pushNamed(context, Routes.blockedUsersList)
                        .then((value) => _onRefresh());
                  }
                  if (value == 1) {
                    _onSettings(mainContext);
                  }
                }),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppTextInput(
                      hintText: Translate.of(context).translate('search'),
                      onChanged: _onSearch,
                      onSubmitted: _onSearch,
                      controller: _textPickerController,
                      trailing: GestureDetector(
                        dragStartBehavior: DragStartBehavior.down,
                        onTap: () {
                          _textPickerController.clear();
                        },
                        child: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SafeArea(
                      child: content,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
