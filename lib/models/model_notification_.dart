// import 'package:akarak/models/model.dart';

// enum MessageType { custom, file, image, system, text, unsupported }

// enum Status { delivered, error, seen, sending, sent, nothing }

// class ChatModel {
//   final int? id;
//   final String remoteId;
//   final String fromUserId;
//   final String toUserId;
//   final String message;
//   final String? metadata;
//   final bool showStatus;
//   final DateTime? createdDate;
//   final int? unixTimeMilliseconds;
//   final Status status;
//   final MessageType type;
//   ChatModel({
//     this.id,
//     required this.remoteId,
//     required this.fromUserId,
//     required this.toUserId,
//     required this.message,
//     this.metadata,
//     this.showStatus = false,
//     this.createdDate,
//     this.unixTimeMilliseconds,
//     this.status = Status.sending,
//     this.type = MessageType.text,
//   });

//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     Status status = Status.sending;
//     MessageType type = MessageType.text;
//     if (json['status'] != null) {
//       status = Status.values[json['status']];
//     }
//     if (json['type'] != null) {
//       type = MessageType.values[json['type']];
//     }
//     return ChatModel(
//       id: int.tryParse(json['id'].toString()) ?? 0,
//       remoteId: json['remoteId'] ?? '',
//       fromUserId: json['fromUserId'] ?? 'Unknown',
//       toUserId: json['toUserId'] ?? 'Unknown',
//       message: json['message'] ?? 'Unknown',
//       metadata: json['metadata'] ?? 'Unknown',
//       showStatus: json['showStatus'] ?? false,
//       createdDate: DateTime.tryParse(json['createdDate'])!,
//       unixTimeMilliseconds: json['unixTimeMilliseconds'],
//       status: status,
//       type: type,
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       'remoteId': remoteId,
//       'fromUserId': fromUserId,
//       'toUserId': toUserId,
//       'message': message,
//       'metadata': metadata,
//       'createdDate': createdDate,
//       'unixTimeMilliseconds': unixTimeMilliseconds,
//       'status': status.index,
//       'type': type.index,
//     };
//   }

//   ChatModel copyWith({
//     int? id,
//     String? remoteId,
//     String? fromUserId,
//     String? toUserId,
//     String? message,
//     String? metadata,
//     DateTime? createdDate,
//     int? unixTimeMilliseconds,
//     Status? status,
//     MessageType? type,
//   }) {
//     id = id ?? this.id;
//     remoteId = remoteId ?? this.remoteId;
//     toUserId = toUserId ?? this.toUserId;
//     message = message ?? this.message;
//     metadata = metadata ?? this.metadata;
//     createdDate = createdDate ?? this.createdDate;
//     unixTimeMilliseconds = unixTimeMilliseconds ?? this.unixTimeMilliseconds;
//     status = status ?? this.status;
//     type = type ?? this.type;
//     return this;
//   }
// }
