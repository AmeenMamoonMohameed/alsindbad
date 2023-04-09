import 'package:akarak/models/model.dart';

enum ReviewType { review, replayForReview }

class CommentModel {
  final int id;
  final int productId;
  final ReviewType reviewType;
  final int parentId;
  final UserModel createdBy;
  final String content;
  final DateTime createdOn;
  final DateTime? lastModifiedOn;
  final double rating;
  final bool isActive;
  final List<CommentModel>? replaies;

  CommentModel({
    required this.id,
    required this.productId,
    required this.reviewType,
    required this.parentId,
    required this.createdBy,
    required this.content,
    required this.createdOn,
    this.lastModifiedOn,
    required this.rating,
    required this.isActive,
    this.replaies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userJson = {
      'id': json['createdBy']['id'] ?? 'Unknown',
      'accountName': json['createdBy']['accountName'],
      'userName': json['createdBy']['userName'],
      'email': json['createdBy']['email'],
      'profilePictureDataUrl': json['createdBy']['profilePictureDataUrl']
    };
    // final listReplies = null;
    final listReplies = List.from(json['replaies'] ?? []).map((item) {
      return CommentModel.fromJson(item);
    }).toList();

    return CommentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      productId: int.tryParse(json['productId'].toString()) ?? 0,
      parentId: int.tryParse(json['parentId'].toString()) ?? 0,
      reviewType: json['reviewType'] == 0
          ? ReviewType.review
          : ReviewType.replayForReview,
      createdBy: UserModel.fromJson(userJson),
      content: json['content'] ?? 'Unknown',
      createdOn: DateTime.tryParse(json['createdOn']) ?? DateTime.now(),
      lastModifiedOn: json['lastModifiedOn'] != null
          ? DateTime.tryParse(json['lastModifiedOn'])
          : null,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      isActive: json['isActive'],
      replaies: listReplies,
    );
  }
}
