import 'package:flutter/material.dart';

enum AnalyticInfoIconType {
  svg,
  body,
}

class AnalyticInfo {
  final String? title;
  final String? src;
  final AnalyticInfoIconType iconType;
  final String? buttonTitle;
  final double? count;
  final Color? color;
  final String? routeName;
  final Widget? body;

  AnalyticInfo({
    this.title,
    this.src,
    required this.iconType,
    this.buttonTitle,
    this.count,
    this.color,
    this.routeName,
    this.body,
  });
}
