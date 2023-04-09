import '../configs/application.dart';
import '../configs/image.dart';
import 'model.dart';

enum HomeSectionType {
  sectionA,
  sectionB,
  sectionC,
  sectionD,
  sectionG,
  sectionCarousel,
  sectionE,
}

class HomeSectionModel {
  final int id;
  final HomeSectionType sectionType;
  final String title;
  final String? description;
  final int priority;
  late List<ExtendedAttributeModel>? extendedAttributes;

  HomeSectionModel({
    required this.id,
    required this.sectionType,
    required this.title,
    this.description,
    required this.priority,
    this.extendedAttributes,
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    List<ExtendedAttributeModel>? extendedAttributes = [];
    var sectionType = HomeSectionType.sectionA;
    if (json['sectionType'] != null) {
      sectionType =
          HomeSectionType.values[int.parse(json['sectionType'].toString())];
    }
    if (json['extendedAttributes'] != null) {
      extendedAttributes =
          List.from(json['extendedAttributes'] ?? []).map((item) {
        return ExtendedAttributeModel.fromJson(item);
      }).toList();
    }
    return HomeSectionModel(
      id: json['id'] ?? 0,
      sectionType: sectionType,
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'],
      extendedAttributes: extendedAttributes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionType': sectionType.index,
      'title': title,
      'description': description,
      'priority': priority,
      'extendedAttributes': extendedAttributes?.map((e) => e.toJson()).toList(),
      // 'refreshToken': refreshToken,
    };
  }
}
