import 'dart:io' if (kIsWeb) 'dart:html';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';

import '../values/typedefs.dart';

class ChatViewAppBar extends StatelessWidget {
  const ChatViewAppBar({
    Key? key,
    required this.chatTitle,
    this.backGroundColor,
    this.userStatus,
    this.profilePicture,
    this.chatTitleTextStyle,
    required this.onTapProfile,
    this.userStatusTextStyle,
    this.backArrowColor,
    this.actions,
    this.elevation,
    this.onBackPress,
    this.padding,
    this.leading,
    this.showLeading = true,
  }) : super(key: key);

  final Color? backGroundColor;
  final String chatTitle;
  final String? userStatus;
  final VoidCallBack onTapProfile;
  final String? profilePicture;
  final TextStyle? chatTitleTextStyle;
  final TextStyle? userStatusTextStyle;
  final Color? backArrowColor;
  final List<Widget>? actions;
  final double? elevation;
  final VoidCallBack? onBackPress;
  final EdgeInsets? padding;
  final Widget? leading;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation ?? 1,
      child: Container(
        padding: padding ??
            EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 4,
            ),
        color: backGroundColor ?? Colors.white,
        child: Row(
          children: [
            if (showLeading)
              leading ??
                  IconButton(
                    onPressed: onBackPress ?? () => Navigator.pop(context),
                    icon: Icon(
                      (!kIsWeb && Platform.isIOS)
                          ? Icons.arrow_back_ios
                          : Icons.arrow_back,
                      color: backArrowColor,
                    ),
                  ),
            Expanded(
              child: InkWell(
                onTap: onTapProfile,
                child: Row(
                  children: [
                    if (profilePicture != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                        child: CircleAvatar(
                            backgroundImage: NetworkImage(profilePicture!)),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatTitle,
                          style: chatTitleTextStyle ??
                              const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.25,
                              ),
                        ),
                        if (userStatus != null)
                          Text(
                            userStatus!,
                            style: userStatusTextStyle,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
