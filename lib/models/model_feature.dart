import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class FeatureModel {
  final int id;
  final int parentId;
  final String name;
  final int? count;
  final String? image;
  final IconData? icon;
  final Color? color;

  FeatureModel({
    required this.id,
    required this.parentId,
    required this.name,
    this.count,
    this.image,
    this.icon,
    this.color,
  });

  @override
  bool operator ==(Object other) => other is FeatureModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    String? image;

    if (json['image'] != null) {
      image = json['image'] ?? '';
    }
    final icon = UtilIcon.getIconFromCss(json['icon'] ?? "fas fa-archway");
    final color = UtilColor.getColorFromHex(json['color'] ?? "ff2b5097");
    return FeatureModel(
      id: json['id'] ?? 0,
      parentId: json['parentId'] ?? json['parentId'] ?? 0,
      name: json['name'] ?? 'Unknown',
      count: json['count'] ?? 0,
      image: image,
      icon: icon,
      color: color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'count': count,
      'image': image,
      'color': color?.toHex,
    };
  }
}
