import 'package:flutter/cupertino.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

enum PropertyType {
  entity,
  filter,
}

enum FieldType {
  textInput,
  datePicker,
  itemPicker,
  imagePicker,
  itemsPicker,
  colorPicker,
  rangSlider,
  slider,
  checkBox
}

enum FilterType {
  startWith,
  endWith,
  contains,
  greaterAndEqualThan,
  smallerAndEqualThan,
  greaterThan,
  smallerThan,
  equal,
}

enum ValueType {
  text,
  decimal,
  double,
  int,
  dateTime,
  json,
  image,
}

class PropertyModel {
  final int id;
  final PropertyType propertyType;
  final String key;
  final String name;
  final String keyLang;
  final String? inputPlacement;
  final String? description;
  final String? group;
  final SectionType section;
  final FieldType fieldType;
  final FilterType filterType;
  final ValueType valueType;
  final List<JsonProperty> json;
  final String? textHelper;
  final bool bySql;
  final bool isGeneric;
  final bool isRequired;
  final bool isActive;
  final bool isAppearInCard;
  final double max;
  final double min;

  PropertyModel({
    required this.id,
    required this.propertyType,
    required this.key,
    required this.name,
    this.inputPlacement,
    this.description,
    this.group,
    required this.keyLang,
    required this.section,
    required this.fieldType,
    required this.filterType,
    required this.valueType,
    required this.json,
    required this.textHelper,
    required this.bySql,
    required this.isActive,
    required this.max,
    required this.min,
    required this.isGeneric,
    required this.isRequired,
    required this.isAppearInCard,
  });

  @override
  bool operator ==(Object other) => other is PropertyModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory PropertyModel.fromJson(Map<String, dynamic> json_) {
    SectionType section = SectionType.sale;
    PropertyType propertyType = PropertyType.entity;
    FieldType fieldType = FieldType.textInput;
    FilterType filterType = FilterType.startWith;
    ValueType valueType = ValueType.image;
    if (json_['section'] != null) {
      section =
          SectionType.values[int.tryParse(json_['section'].toString()) ?? 0];
    }
    if (json_['propertyType'] != null) {
      propertyType = PropertyType
          .values[int.tryParse(json_['propertyType'].toString()) ?? 0];
    }
    if (json_['fieldType'] != null) {
      fieldType =
          FieldType.values[int.tryParse(json_['fieldType'].toString()) ?? 0];
    }
    if (json_['filterType'] != null) {
      filterType =
          FilterType.values[int.tryParse(json_['filterType'].toString()) ?? 0];
    }
    if (json_['valueType'] != null) {
      valueType =
          ValueType.values[int.tryParse(json_['valueType'].toString()) ?? 0];
    }
    return PropertyModel(
      id: json_['id'] ?? 0,
      propertyType: propertyType,
      key: json_['key'] ?? json_['key'] ?? 0,
      name: json_['name'] ?? 'Unknown',
      inputPlacement: json_['inputPlacement'] ?? 'Unknown',
      description: json_['description'] ?? 'Unknown',
      group: json_['group'] ?? 'Unknown',
      keyLang: json_['keyLang'] ?? 'Unknown',
      section: section,
      fieldType: fieldType,
      filterType: filterType,
      valueType: valueType,
      json: List.from(json_['json'])
          .map((e) => JsonProperty(name: e["key"], value: e["value"]))
          .toList(),
      // json: json_['json'],
      textHelper: json_['textHelper'],
      bySql: json_['bySql'],
      isActive: json_['isActive'],
      max: double.tryParse(json_['max'].toString()) ?? 0,
      min: double.tryParse(json_['min'].toString()) ?? 0,
      isGeneric: json_['isGeneric'] ?? false,
      isRequired: json_['isRequired'],
      isAppearInCard: json_['isAppearInCard'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyType': propertyType.index,
      'key': key,
      'name': name,
      'inputPlacement': inputPlacement,
      'description': description,
      'group': group,
      'keyLang': keyLang,
      'section': section.index,
      'fieldType': fieldType.index,
      'filterType': filterType.index,
      'valueType': valueType.index,
      'json': json.map((e) => e.toJson()).toList(),
      'textHelper': textHelper,
      'bySql': bySql,
      'isActive': isActive,
      'max': max,
      'min': min,
      'isGeneric': isGeneric,
      'isRequired': isRequired,
      'isAppearInCard': isAppearInCard,
    };
  }
}

class JsonProperty {
  final String name;
  final String value;

  JsonProperty({
    required this.name,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': name,
      'value': value,
    };
  }
}
