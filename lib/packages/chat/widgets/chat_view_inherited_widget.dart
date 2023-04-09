import 'package:akarak/packages/chat/controller/chat_controller.dart';
import 'package:akarak/packages/chat/models/chat_user.dart';
import 'package:akarak/packages/chat/models/feature_active_config.dart';
import 'package:flutter/material.dart';

class ChatViewInheritedWidget extends InheritedWidget {
  const ChatViewInheritedWidget({
    Key? key,
    required Widget child,
    required this.featureActiveConfig,
    required this.chatController,
    required this.currentUser,
  }) : super(key: key, child: child);
  final FeatureActiveConfig featureActiveConfig;
  final ChatController chatController;
  final ChatUser currentUser;

  static ChatViewInheritedWidget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatViewInheritedWidget>();

  @override
  bool updateShouldNotify(covariant ChatViewInheritedWidget oldWidget) =>
      oldWidget.featureActiveConfig != featureActiveConfig;
}
