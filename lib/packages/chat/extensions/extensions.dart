import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_user.dart';
import '../utils/constants.dart';
import '../utils/emoji_parser.dart';
import '../utils/package_strings.dart';
import '../values/enumaration.dart';
import '../widgets/chat_view_inherited_widget.dart';

extension TimeDifference on DateTime {
  String get getDay {
    final DateTime formattedDate = DateFormat(dateFormat).parse(toString());
    final DateFormat formatter = DateFormat.yMMMMd(enUS);
    final differenceInDays = formattedDate.difference(DateTime.now()).inDays;
    if (differenceInDays == 0) {
      return PackageStrings.today;
    } else if (differenceInDays <= 1 && differenceInDays >= -1) {
      return PackageStrings.yesterday;
    } else if (differenceInDays <= -2 && differenceInDays >= -6) {
      return DateFormat('EEEE').format(formattedDate);
    } else {
      return formatter.format(formattedDate);
    }
  }

  String get getDateFromDateTime {
    final DateFormat formatter = DateFormat(dateFormat);
    return formatter.format(this);
  }

  String get getTimeFromDateTime => DateFormat.Hm().format(this);
}

extension ValidateString on String {
  bool get isImageUrl {
    final imageUrlRegExp = RegExp(imageUrlRegExpression);
    return imageUrlRegExp.hasMatch(this) || startsWith('data:image');
  }

  bool get fromMemory => !startsWith('http://') && !startsWith('https://');

  bool get isAllEmoji {
    for (String s in EmojiParser().unemojify(this).split(" ")) {
      if (!s.startsWith(":") || !s.endsWith(":")) {
        return false;
      }
    }
    return true;
  }

  bool get isUrl => Uri.tryParse(this)?.isAbsolute ?? false;

  Widget getUserProfilePicture({
    required ChatUser? Function(String) getChatUser,
    double? profileCircleRadius,
    EdgeInsets? profileCirclePadding,
  }) {
    return Padding(
      padding: profileCirclePadding ?? const EdgeInsets.only(left: 4),
      child: CircleAvatar(
        radius: profileCircleRadius ?? 8,
        backgroundImage:
            NetworkImage(getChatUser(this)?.profilePhoto ?? profileImage),
      ),
    );
  }
}

extension MessageTypes on MessageType {
  bool get isImage => this == MessageType.image;

  bool get isText => this == MessageType.text;

  bool get isVoice => this == MessageType.voice;

  bool get isQuestion => this == MessageType.question;
  
  bool get isMap => this == MessageType.map;

  bool get isCustom => this == MessageType.custom;
}

extension ConnectionStates on ConnectionState {
  bool get isWaiting => this == ConnectionState.waiting;

  bool get isActive => this == ConnectionState.active;
}

extension ChatViewStateTitleExtension on String? {
  String getChatViewStateTitle(ChatViewState state) {
    switch (state) {
      case ChatViewState.hasMessages:
        return this ?? '';
      case ChatViewState.noData:
        return this ?? 'No Messages';
      case ChatViewState.loading:
        return this ?? '';
      case ChatViewState.error:
        return this ?? 'Something went wrong !!';
    }
  }
}

extension StatefulWidgetExtension on State {
  ChatViewInheritedWidget? get provide => ChatViewInheritedWidget.of(context);
}
