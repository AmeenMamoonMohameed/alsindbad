import 'dart:convert';

import '../values/enumaration.dart';

enum AttachmentType { question }

class AttachmentMessage {
  final String id;
  final String name;
  final String description;
  final String image;
  final Map<String, dynamic>? data;
  final AttachmentType type;

  /// Provides max duration for recorded voice message.

  /// Id of message, it replies to.
  bool hasValue() =>
      id.isNotEmpty ||
      name.isNotEmpty ||
      description.isNotEmpty ||
      image.isNotEmpty;

  const AttachmentMessage({
    this.id = '',
    this.name = '',
    this.description = '',
    this.image = '',
    this.data,
    this.type = AttachmentType.question,
  });

  factory AttachmentMessage.fromJson(Map<String, dynamic> json) {
    var type = AttachmentType.question;
    if (json['type'] != null) {
      type = AttachmentType.values[int.parse(json['type'].toString())];
    }
    return AttachmentMessage(
      id: json['id'] ?? json['Id'],
      name: json['name'] ?? json['Name'],
      description: json['description'] ?? json['Description'],
      image: json['image'] ?? json['Image'],
      data: json['data'] != null || json['Data'] != null
          ? jsonDecode(json['data'] ?? json['Data'])
          : null,
      type: type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'data': jsonEncode(data),
        'type': type.index,
      };
}
