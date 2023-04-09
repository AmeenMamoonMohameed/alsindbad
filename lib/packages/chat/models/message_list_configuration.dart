
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../values/typedefs.dart';

class ChatBackgroundConfiguration {
  final Color? backgroundColor;
  final String? backgroundImage;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final StringWithReturnWidget? groupSeparatorBuilder;
  final GroupedListOrder groupedListOrder;
  final bool sortEnable;
  final TextStyle? messageTimeTextStyle;
  final Color? messageTimeIconColor;
  final DefaultGroupSeparatorConfiguration? defaultGroupSeparatorConfig;
  final Widget? loadingWidget;
  final Curve messageTimeAnimationCurve;

  const ChatBackgroundConfiguration({
    this.defaultGroupSeparatorConfig,
    this.backgroundColor,
    this.backgroundImage,
    this.height,
    this.width,
    this.groupSeparatorBuilder,
    this.groupedListOrder = GroupedListOrder.ASC,
    this.sortEnable = false,
    this.padding,
    this.margin,
    this.messageTimeTextStyle,
    this.messageTimeIconColor,
    this.loadingWidget,
    this.messageTimeAnimationCurve = Curves.decelerate,
  });
}

class DefaultGroupSeparatorConfiguration {
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  DefaultGroupSeparatorConfiguration({
    this.padding,
    this.textStyle,
  });
}
