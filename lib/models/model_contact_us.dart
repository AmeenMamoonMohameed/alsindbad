import 'package:akarak/models/model.dart';

class ContactUsModel {
  final int id;
  final UserModel createdBy;
  final String content;
  final DateTime createdOn;
  final DateTime? lastModifiedOn;

  ContactUsModel({
    required this.id,
    required this.createdBy,
    required this.content,
    required this.createdOn,
    this.lastModifiedOn,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    final userJson = {
      'id': json['createdBy']['id'] ?? 'Unknown',
      'userName': json['createdBy']['userName'],
      'email': json['createdBy']['email'],
      'profilePictureDataUrl': json['createdBy']['profilePictureDataUrl']
    };

    return ContactUsModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      content: json['content'] ?? 'Unknown',
      createdBy: UserModel.fromJson(userJson),
      createdOn: DateTime.tryParse(json['createdOn']) ?? DateTime.now(),
      lastModifiedOn: json['lastModifiedOn'] != null
          ? DateTime.tryParse(json['lastModifiedOn'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'createdBy': createdBy,
      'content': content,
      'createdOn': createdOn,
      'lastModifiedOn': lastModifiedOn,
    };
  }
}
