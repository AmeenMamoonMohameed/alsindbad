import 'dart:core';
import 'dart:ffi';

import 'package:akarak/models/model.dart';

enum ExtendedAttributeType {
  text,
  decimal,
  double,
  int,
  dateTime,
  json,
  image,
  range,
  bool,
  multi,
}

class ExtendedAttributeModel {
  final int id;
  final dynamic entityId;
  late ExtendedAttributeType? type;
  final String key;
  late String? name;
  late String? text;
  late num? decimal;
  late num? double_;
  late int? integer;
  late DateTime? dateTime;
  late bool? bool_;
  late double? rangMin;
  late double? rangMax;
  late String? json;
  late String? externalId;
  late String? group;
  late int? propertyId;
  late String? description;
  final bool isActive;
  final bool fromSystem;

  ExtendedAttributeModel({
    this.id = 0,
    this.entityId = 0,
    this.type = ExtendedAttributeType.text,
    required this.key,
    this.name,
    this.text,
    this.decimal,
    this.double_,
    this.integer,
    this.dateTime,
    this.bool_,
    this.rangMin,
    this.rangMax,
    this.json,
    this.externalId,
    this.group,
    this.propertyId,
    this.description,
    this.isActive = true,
    this.fromSystem = false,
  });

  ExtendedAttributeModel copyWith({
    int? id,
    dynamic entityId,
    ExtendedAttributeType? type,
    String? key,
    String? name,
    String? text,
    num? decimal,
    num? double,
    int? integer,
    DateTime? dateTime,
    bool? bool_,
    double? rangMin,
    double? rangMax,
    String? json,
    String? externalId,
    String? group,
    int? propertyId,
    String? description,
    bool? isActive,
    bool? fromSystem,
  }) =>
      ExtendedAttributeModel(
        id: id ?? this.id,
        entityId: entityId ?? this.entityId,
        type: type ?? this.type,
        key: key ?? this.key,
        name: name ?? this.name,
        text: text ?? this.text,
        decimal: decimal ?? this.decimal,
        double_: double ?? this.double_,
        integer: integer ?? this.integer,
        dateTime: dateTime ?? this.dateTime,
        bool_: bool_ ?? this.bool_,
        rangMin: rangMin ?? this.rangMin,
        rangMax: rangMax ?? this.rangMax,
        json: json ?? this.json,
        externalId: externalId ?? this.externalId,
        group: group ?? this.group,
        propertyId: propertyId ?? this.propertyId,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        fromSystem: fromSystem ?? this.fromSystem,
      );

  factory ExtendedAttributeModel.fromJson(Map<String, dynamic> json) {
    ExtendedAttributeType type = ExtendedAttributeType.text;
    if (json['type'] != null) {
      type = ExtendedAttributeType.values[json['type']];
    }
    return ExtendedAttributeModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      entityId: int.tryParse(json['entityId']?.toString() ?? '') ?? 0,
      type: type,
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      text: json['text'],
      decimal: num.tryParse(json['decimal']?.toString() ?? ''),
      double_: num.tryParse(json['double']?.toString() ?? ''),
      integer: int.tryParse(json['int']?.toString() ?? ''),
      dateTime: json['dateTime'],
      bool_: json['bool'],
      rangMin: double.tryParse(json['rangMin']?.toString() ?? ''),
      rangMax: double.tryParse(json['rangMax']?.toString() ?? ''),
      json: json['json'],
      externalId: json['externalId'],
      group: json['group'],
      propertyId: json['propertyId'],
      description: json['description'],
      isActive: json['isActive'],
      fromSystem: json['fromSystem'] ?? true,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'entityId': entityId,
      'type': type?.index,
      'key': key,
      'name': name,
      'text': text,
      'decimal': decimal,
      'double': double_,
      'int': integer,
      'dateTime': dateTime,
      'bool': bool_,
      'rangMin': rangMin,
      'rangMax': rangMax,
      'json': json,
      'externalId': externalId,
      'group': group,
      'propertyId': propertyId,
      'description': description,
      'isActive': isActive,
      'fromSystem': fromSystem,
    };
  }

  Object? getValue() {
    if (type == ExtendedAttributeType.text) {
      return text;
    } else if (type == ExtendedAttributeType.decimal) {
      return decimal;
    } else if (type == ExtendedAttributeType.double) {
      return double_;
    } else if (type == ExtendedAttributeType.int) {
      return integer;
    } else if (type == ExtendedAttributeType.dateTime) {
      return dateTime;
    } else if (type == ExtendedAttributeType.dateTime) {
      return bool_;
    }
    return null;
  }

  void setValue(Object? value) {
    if (type == ExtendedAttributeType.text) {
      text = value?.toString();
    } else if (type == ExtendedAttributeType.decimal) {
      decimal = value == null ? null : num.tryParse(value.toString());
    } else if (type == ExtendedAttributeType.double) {
      double_ = value == null ? null : num.tryParse(value.toString());
    } else if (type == ExtendedAttributeType.int) {
      integer = value == null ? null : int.tryParse(value.toString());
    } else if (type == ExtendedAttributeType.dateTime) {
      dateTime = value == null ? null : DateTime.tryParse(value.toString());
    }
  }
}
