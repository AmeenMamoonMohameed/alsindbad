import 'package:flutter/material.dart';

class MessageReactionConfiguration {
  final double? reactionSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final TextStyle? reactedUserCountTextStyle;
  final TextStyle? reactionCountTextStyle;
  final ReactionsBottomSheetConfiguration? reactionsBottomSheetConfig;
  final double? profileCircleRadius;
  final EdgeInsets? profileCirclePadding;

  MessageReactionConfiguration({
    this.reactionsBottomSheetConfig,
    this.reactionCountTextStyle,
    this.reactedUserCountTextStyle,
    this.reactionSize,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.profileCircleRadius,
    this.profileCirclePadding,
  });
}

class ReactionsBottomSheetConfiguration {
  ReactionsBottomSheetConfiguration({
    this.bottomSheetPadding,
    this.backgroundColor,
    this.reactionWidgetDecoration,
    this.reactionWidgetPadding,
    this.reactionWidgetMargin,
    this.reactedUserTextStyle,
    this.profileCircleRadius,
    this.reactionSize,
  });

  final EdgeInsetsGeometry? bottomSheetPadding;
  final EdgeInsetsGeometry? reactionWidgetPadding;
  final EdgeInsetsGeometry? reactionWidgetMargin;
  final Color? backgroundColor;
  final BoxDecoration? reactionWidgetDecoration;
  final TextStyle? reactedUserTextStyle;
  final double? profileCircleRadius;
  final double? reactionSize;
}
