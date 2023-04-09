import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class CountryModel {
  final int id;
  final String name;
  final String description;
  final int? count;
  final String? image;
  final IconData? icon;
  final Color? color;
  final List<ExtendedAttributeModel>? extendedAttributes;

  CountryModel({
    required this.id,
    required this.name,
    required this.description,
    this.count,
    this.image,
    this.icon,
    this.color,
    this.extendedAttributes,
  });

  @override
  bool operator ==(Object other) => other is CountryModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    String? image;
    List<ExtendedAttributeModel>? extendedAttributes = [];
    if (json['image'] != null) {
      image = json['image'] ?? '';
    }
    if (json['extendedAttributes'] != null) {
      extendedAttributes =
          List.from(json['extendedAttributes'] ?? []).map((item) {
        return ExtendedAttributeModel.fromJson(item);
      }).toList();
    }

    final icon = UtilIcon.getIconFromCss(json['icon']);
    final color = UtilColor.getColorFromHex(json['color']);
    return CountryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'Unknown',
      count: json['count'] ?? 0,
      image: image,
      icon: icon,
      color: color,
      extendedAttributes: extendedAttributes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'count': count,
      'image': image,
      'color': color?.toHex,
      'extendedAttributes': extendedAttributes?.map((e) => e.toJson()).toList(),
    };
  }
}
