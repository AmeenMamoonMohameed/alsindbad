import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class GroupModel {
  final int id;
  final String name;
  final String description;
  final List<int> categories;
  final List<PropertyModel>? properties;
  final String? image;
  final IconData? icon;
  final String? iconUrl;
  final Color? color;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    this.properties,
    this.image,
    this.icon,
    this.iconUrl,
    this.color,
  });

  @override
  bool operator ==(Object other) => other is GroupModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // GroupType groupType = GroupType.group;
    final icon = UtilIcon.getIconFromCss("fas fa-archway");
    final color = UtilColor.getColorFromHex(json['color'] ?? "ff2b5097");
    return GroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'Unknown',
      categories: json['categories'] == null
          ? []
          : List.from(json['categories'])
              .map((e) => int.parse(e.toString()))
              .toList(),
      properties: json['properties'] == null
          ? []
          : List.from(json['properties'])
              .map((e) => PropertyModel.fromJson(e))
              .toList(),
      image: json['image'] ?? '',
      icon: icon,
      iconUrl: json['icon'] ?? '',
      color: color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories': categories,
      'properties': properties?.map((e) => e.toJson()).toList(),
      'image': image,
      'color': color?.toHex,
    };
  }
}
