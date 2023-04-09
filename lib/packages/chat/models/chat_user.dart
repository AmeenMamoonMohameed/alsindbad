
class ChatUser {
  final String id;
  final String name;
  final String? profilePhoto;

  ChatUser({
    required this.id,
    required this.name,
    this.profilePhoto,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json["id"],
        name: json["name"],
        profilePhoto: json["profilePhoto"],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'profilePhoto': profilePhoto,
      };
}
