import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

enum CategoryType { main, sub, label }

enum ListViewType { withIcons, withImages }

class CategoryModel {
  late final int id;
  late final int countryId;
  final int? parentId;
  final String name;
  final String description;
  final List<GroupModel>? groups;
  final List<BrandModel>? brands;
  final int? count;
  final String? image;
  final IconData? icon;
  final String? iconUrl;
  final Color? color;
  final CategoryType? type;
  final bool enableRent;
  final bool isActive;
  final bool hasBrands;
  final bool hasOrder;
  final bool hasMap;
  final bool hasArea;
  final bool hasColors;
  final bool hasShipping;
  final ListViewType listViewType;
  final List<ExtendedAttributeModel>? extendedAttributes;

  CategoryModel({
    required this.id,
    required this.countryId,
    this.parentId,
    required this.name,
    this.groups,
    this.brands,
    required this.description,
    this.count,
    this.image,
    this.icon,
    this.iconUrl,
    this.color,
    this.type,
    this.enableRent = false,
    this.isActive = false,
    this.hasBrands = false,
    this.hasOrder = false,
    this.hasMap = false,
    this.hasArea = false,
    this.hasColors = false,
    this.hasShipping = false,
    this.listViewType = ListViewType.withIcons,
    this.extendedAttributes,
  });

  @override
  bool operator ==(Object other) => other is CategoryModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<ExtendedAttributeModel>? extendedAttributes = [];
    if (json['extendedAttributes'] != null) {
      extendedAttributes =
          List.from(json['extendedAttributes'] ?? []).map((item) {
        return ExtendedAttributeModel.fromJson(item);
      }).toList();
    }
    ListViewType listViewType = ListViewType.values[int.parse(
        json['listViewType'] == null ? "0" : json['listViewType'].toString())];
    CategoryType type = CategoryType.values[
        int.parse(json['type'] == null ? "0" : json['type'].toString())];
    final icon = UtilIcon.getIconFromCss("fas fa-archway");
    final color = UtilColor.getColorFromHex(json['color'] ?? "ff2b5097");
    return CategoryModel(
      id: json['id'] ?? 0,
      countryId: json['countryId'] ?? 0,
      parentId: json['parentId'],
      name: json['name'] ?? 'Unknown',
      groups: json['groups'] == null
          ? []
          : List.from(json['groups'])
              .map((e) => GroupModel.fromJson(e))
              .toList(),
      brands: json['brands'] == null
          ? []
          : List.from(json['brands'])
              .map((e) => BrandModel.fromJson(e))
              .toList(),
      description: json['description'] ?? 'Unknown',
      count: json['count'] ?? 0,
      image: json['image'] ?? '',
      icon: icon,
      iconUrl: json['icon'] ?? '',
      color: color,
      type: type,
      enableRent: json['enableRent'] ?? false,
      isActive: json['isActive'] ?? false,
      hasBrands: json['hasBrands'] ?? false,
      hasOrder: json['hasOrder'] ?? false,
      hasMap: json['hasMap'] ?? false,
      hasArea: json['hasArea'] ?? false,
      hasColors: json['hasColors'] ?? false,
      hasShipping: json['hasShipping'] ?? false,
      listViewType: listViewType,
      extendedAttributes: extendedAttributes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryId': countryId,
      'parentId': parentId,
      'name': name,
      'groups': groups?.map((e) => e.toJson()).toList(),
      'brands': brands?.map((e) => e.toJson()).toList(),
      'count': count,
      'image': image,
      'iconUrl': iconUrl,
      'color': color?.toHex,
      'type': type?.index,
      'enableRent': enableRent,
      'isActive': isActive,
      'hasBrands': hasBrands,
      'hasOrder': hasOrder,
      'hasMap': hasMap,
      'hasArea': hasArea,
      'hasColors': hasColors,
      'hasShipping': hasShipping,
      'listViewType': listViewType.index,
      'extendedAttributes': extendedAttributes?.map((e) => e.toJson()).toList(),
    };
  }
}
