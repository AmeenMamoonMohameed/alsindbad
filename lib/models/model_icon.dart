import 'package:flutter/material.dart';

class IconModel {
  final String name;
  final Widget? icon;
  final String value;

  IconModel({
    required this.name,
    this.icon,
    required this.value,
  });

  @override
  bool operator ==(other) => other is IconModel && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
