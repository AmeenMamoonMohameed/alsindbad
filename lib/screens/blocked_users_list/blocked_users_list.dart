import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';
import 'package:akarak/widgets/widget.dart';
import 'package:share/share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../repository/chat_repository.dart';

class BlockedUsersList extends StatefulWidget {
  const BlockedUsersList({Key? key}) : super(key: key);

  @override
  _BlockedUsersListState createState() {
    return _BlockedUsersListState();
  }
}

class _BlockedUsersListState extends State<BlockedUsersList> {
  final _textPickerController = TextEditingController();
  final BlockedUsersCubit blockedUsersCubit = BlockedUsersCubit();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    _textPickerController.dispose();
    super.dispose();
  }

  ///On refresh
  Future<void> _onRefresh() async {
    await blockedUsersCubit.onLoad();
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
                          title:
                              Translate.of(context).translate('cancel_block'),
                          leading: const Icon(Icons.cancel),
                          onPressed: () {
                            Navigator.pop(context, "cancel_block");
                          },
                        ),
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
    if (result == 'cancel_block') {
      blockedUsersCubit.unblockUser(userId);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    // return BlocBuilder<BlockedUsersCubit, BlockedUsersListState>(
    Widget buildContent = Scaffold(
        backgroundColor: Theme.of(mainContext).colorScheme.tertiaryContainer,
        appBar: AppBar(
          title: Text(Translate.of(context).translate('blocked_users_list')),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 15, left: 15, bottom: 20, top: 20),
              child: ListView.builder(
                itemCount: blockedUsersCubit.list.length,
                itemBuilder: (context, index) {
                  var item = blockedUsersCubit.list[index];
                  // var item = blockedUsersCubit.list.isNotEmpty ?  blockedUsersCubit.list[index] : null;
                  return Slidable(
                    key: ValueKey(item.userId),
                    // startActionPane: ActionPane(
                    //   motion: const ScrollMotion(),
                    //   dismissible: DismissiblePane(onDismissed: () {}),
                    //   children: [
                    //     // A SlidableAction can have an icon and/or a label.
                    //     SlidableAction(
                    //       flex: 3,
                    //       onPressed: (BuildContext? buildContext) {
                    //         blockedUsersCubit.list.removeAt(index);
                    //       },
                    //       backgroundColor: Colors.green,
                    //       foregroundColor: Colors.white,
                    //       icon: Icons.delete,
                    //       label: Translate.of(context).translate('cancel'),
                    //     ),
                    //   ],
                    // ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 2,
                          onPressed: (BuildContext? buildContext) {
                            blockedUsersCubit.unblockUser(item.userId);
                            setState(() {});
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.cancel,
                          label:
                              Translate.of(context).translate('cancel_block'),
                        ),

                        // SlidableAction(
                        //   onPressed: (BuildContext? buildContext) {},
                        //   backgroundColor: const Color(0xFF0392CF),
                        //   foregroundColor: Colors.white,
                        //   icon: Icons.save,
                        //   label: 'Save',
                        // ),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                        ),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: AppUserInfo(
                          chatUser: ChatUserModel(
                              userId: item.userId,
                              userName: item.userName,
                              profilePictureDataUrl: item.profilePictureDataUrl,
                              accountName: item.accountName,
                              fullName: item.fullName,
                              lastMessage: item.lastMessage,
                              lastMessageTimeElapsed:
                                  item.lastMessageTimeElapsed,
                              hasNewMessage: item.hasNewMessage,
                              isOnline: item.isOnline),
                          type: UserViewType.chat,
                          onPressed: () async {
                            _onAction(item.userId);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ));

    blockedUsersCubit.stream.listen((state) {
      if (state is BlockedUsersSuccess) {
        setState(() {});
      }
    });

    return buildContent;
  }
}
