import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:akarak/packages/chat/models/message_list_configuration.dart';
import 'package:flutter/material.dart';
import 'bubbles/chat_bubbles.dart';

class ChatGroupHeader extends StatelessWidget {
  const ChatGroupHeader({
    Key? key,
    required this.day,
    this.groupSeparatorConfig,
  }) : super(key: key);

  final DateTime day;
  final DefaultGroupSeparatorConfiguration? groupSeparatorConfig;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: groupSeparatorConfig?.padding ??
          const EdgeInsets.symmetric(vertical: 12),
      child: DateChip(
        text: day.getDay,
        color: const Color(0x558AD3D5),
      ),

      // Text(
      //   day.getDay,
      //   textAlign: TextAlign.center,
      //   style: groupSeparatorConfig?.textStyle ?? const TextStyle(fontSize: 17),
      // ),
    );
  }
}
