import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class BrandModel {
  late final int id;
  late final int categoryId;
  final String name;
  final String description;
  final int? count;
  final String? image;
  final String? icon;
  final Color? color;
  final bool isActive;

  BrandModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    this.count,
    this.image,
    this.icon,
    this.color,
    this.isActive = false,
  });

  @override
  bool operator ==(Object other) => other is BrandModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final color = UtilColor.getColorFromHex(json['color'] ?? "ff2b5097");
    return BrandModel(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'Unknown',
      count: json['count'] ?? 0,
      image: json['image'] ?? '',
      icon: json['icon'] ?? '',
      color: color,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'count': count,
      'image': image,
      'iconUrl': icon,
      'color': color?.toHex,
      'isActive': isActive,
    };
  }
}
