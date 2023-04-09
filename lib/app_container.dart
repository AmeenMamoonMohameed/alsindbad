// import 'package:assets_audio_player/assets_audio_player.dart' as player;
import 'dart:io';

import 'package:akarak/packages/chat/models/message.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/screens/screen.dart';
import 'package:akarak/utils/utils.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_eval/flutter_eval.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() {
    return _AppContainerState();
  }
}

class _AppContainerState extends State<AppContainer> {
  String _selected = Routes.home;
  String? _linkMessage;
  bool _isCreatingLink = false;
  final String DynamicLink = 'https://alsindbad.online/app';
  // final String Link = 'https://flutterfiretests.page.link/MEGs';
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();

    // FirebaseMessaging.onMessage.listen((message) {
    //   _notificationHandle(message);
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   _notificationHandle(message);
    // });
  }

  void initDynamicLinks() {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      handleLink(dynamicLinkData.link);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  void handleLink(Uri uri) {
    List<String> seperatedLink = [];
    seperatedLink.addAll(uri.path.split("/")); // alsindbad.online and Arguments
    // uri.queryParameters
    if (seperatedLink[2] == 'product') {
      Navigator.pushNamed(context, Routes.productDetail, arguments: {
        'categoryId': int.parse(seperatedLink[3]),
        'id': int.parse(seperatedLink[4])
      });
    } else if (seperatedLink[2] == 'profile') {
      Navigator.pushNamed(context, Routes.profile,
          arguments: {'userId': seperatedLink[3]});
    }
    // Navigator.pushNamed(
    //   context,
    //   uri.path,
    // );
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://alsindbad.online',
      longDynamicLink: Uri.parse(
        'https://alsindbad.online?efr=0&ibi=io.flutter.plugins.firebase.dynamiclinksexample&apn=io.flutter.plugins.firebase.dynamiclinksexample&imv=0&amv=0&link=https%3A%2F%2Fexample%2Fhelloworld&ofl=https://ofl-example.com',
      ),
      link: Uri.parse(DynamicLink),
      androidParameters: const AndroidParameters(
        packageName: 'com.arma.akarak',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.arma.akarak',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  ///check route need auth
  bool _requireAuth(String route) {
    switch (route) {
      case Routes.home:
        return false;
      default:
        return true;
    }
  }

  ///Export index stack
  int _exportIndexed(String route) {
    switch (route) {
      case Routes.home:
        return 0;
      case Routes.chatList:
        return 1;
      case Routes.wishList:
        return 2;
      case Routes.account:
        return 3;
      default:
        return 0;
    }
  }

  ///Force switch home when authentication state change
  void _listenAuthenticateChange(AuthenticationState authentication) async {
    if (authentication == AuthenticationState.fail && _requireAuth(_selected)) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: _selected,
      );
      if (result != null) {
        setState(() {
          _selected = result as String;
        });
      } else {
        setState(() {
          _selected = Routes.home;
        });
      }
    }
  }

  ///On change tab bottom menu and handle when not yet authenticate
  void _onItemTapped(String route) async {
    // AppBloc.discoveryCubit.onResetPagination();
    final signed = AppBloc.authenticateCubit.state != AuthenticationState.fail;
    if (!signed && _requireAuth(route)) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: route,
      );
      if (result == null) return;
    }
    setState(() {
      _selected = route;
    });
    // if (route == Routes.discovery) {
    //   AppBloc.discoveryCubit.onLoad(FilterModel.fromDefault());
    // }
  }

  ///On handle submit product
  void _onSubmit() async {
    final signed = AppBloc.authenticateCubit.state != AuthenticationState.fail;
    if (!signed) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.submit,
      );
      if (result == null) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(context, Routes.submit);
  }

  ///Build Item Menu
  Widget _buildMenuItem(String route) {
    Color? color;
    String title = 'home';
    IconData iconData = Icons.help_outline;
    switch (route) {
      case Routes.home:
        iconData = Icons.home_outlined;
        title = 'home';
        break;
      case Routes.chatList:
        iconData = Icons.chat;
        title = 'messages';
        break;
      case Routes.wishList:
        iconData = Icons.bookmark_outline;
        title = 'wish_list';
        break;
      case Routes.account:
        iconData = Icons.account_circle_outlined;
        title = 'account';
        break;
      default:
        iconData = Icons.home_outlined;
        title = 'home';
        break;
    }
    if (route == _selected) {
      color = Theme.of(context).primaryColor;
    }
    return IconButton(
      onPressed: () {
        _onItemTapped(route);
      },
      padding: EdgeInsets.zero,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            Translate.of(context).translate(title),
            style: Theme.of(context).textTheme.button!.copyWith(
                  fontSize: 10,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  ///Build submit button
  Widget? _buildSubmit() {
    if (Application.setting.enableSubmit) {
      return FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: _onSubmit,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      );
    }
    return null;
  }

  ///Build bottom menu
  Widget _buildBottomMenu() {
    if (Application.setting.enableSubmit) {
      return BottomAppBar(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuItem(Routes.home),
              _buildMenuItem(Routes.wishList),
              const SizedBox(width: 56),
              _buildMenuItem(Routes.chatList),
              _buildMenuItem(Routes.account),
            ],
          ),
        ),
      );
    }
    return BottomAppBar(
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuItem(Routes.home),
            _buildMenuItem(Routes.wishList),
            _buildMenuItem(Routes.chatList),
            _buildMenuItem(Routes.account),
          ],
        ),
      ),
    );
  }

  Future showNotification() async {
    return BlocListener<ChatCubit, ChatState>(
        listener: (context, initState) async {
      if (initState is HasNewNotification) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    const submitPosition = FloatingActionButtonLocation.centerDocked;

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, authentication) async {
        _listenAuthenticateChange(authentication);
        if (authentication == AuthenticationState.success) {
          await AppBloc.chatCubit.onInit().whenComplete(() => setState(() {}));
        }
      },
      child: BlocListener<ChatSignalRCubit, ChatSignalRState>(
        listener: (context, chatSignalRState) {
          if (chatSignalRState == ChatSignalRState.close) {
            setState(() {});
          }
          if (chatSignalRState == ChatSignalRState.reconnecting) {
            setState(() {});
          }
          if (chatSignalRState == ChatSignalRState.reconnected) {
            setState(() {});
          }
          // ScaffoldMessenger.of(context).showSnackBar('snackBar');
        },
        child: BlocListener<ChatCubit, ChatState>(
          listener: (context, initState) async {
            // AppBloc.initCubit.stream.listen((state) async {
            if (initState is ChatUserSuccess) {
              if (initState.list.any((element) =>
                  element.lastMessage?.fromUserId !=
                      AppBloc.userCubit.state?.userId &&
                  element.lastMessage?.status != Status.seen)) {
                if (initState.isAlerm) {}
                if (initState.isVibrate) {
                  Vibration.cancel();
                  Vibration.vibrate(duration: 128);
                }

//
                if (initState.isOpenDrawer) {
                  if (!(Application.scaffoldKey.currentState?.isDrawerOpen ??
                      false)) {
                    if (ModalRoute.of(context)!.isCurrent) {
                      Application.scaffoldKey.currentState?.openDrawer();
                    }
                    // msgCount += 1;
                  }
                }
              }
            }
            // });
          },
          child: Scaffold(
            // appBar: AppBar(
            // automaticallyImplyLeading: false,
            // title: (AppBloc.chatSignalRCubit.state ==
            //             ChatSignalRState.reconnected ||
            //         AppBloc.userCubit.state == null)
            //     ? Container()
            //     : AppBloc.chatSignalRCubit.state ==
            //             ChatSignalRState.reconnecting
            //         ? const LinearProgressIndicator(
            //             backgroundColor: Colors.grey,
            //           )
            //         : LinearProgressIndicator(
            //             backgroundColor: Colors.grey,
            //             color: Theme.of(context).errorColor,
            //           ),
            // toolbarHeight:
            //     AppBloc.chatSignalRCubit.state == ChatSignalRState.reconnected
            //         ? 0
            //         : 5,
            // ),
            body: IndexedStack(
              index: _exportIndexed(_selected),
              children: const <Widget>[
                Home2(),
                ChatUsersList(),
                WishList(),
                Account()
              ],
            ),
            bottomNavigationBar: _buildBottomMenu(),
            floatingActionButton: _buildSubmit(),
            floatingActionButtonLocation: submitPosition,
          ),
        ),
      ),
    );
    // });
  }
}
