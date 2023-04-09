enum ReportType { profile, chat, product, review, replay }

class ReportModel {
  final String reportedId;
  final String name;
  final String description;
  final ReportType type;

  ReportModel({
    required this.reportedId,
    required this.name,
    required this.description,
    required this.type,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    ReportType type = ReportType.profile;
    if (json['type'] != null) {
      type = ReportType.values[json['type']];
    }
    return ReportModel(
      reportedId: json['reportedId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: type,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "reportedId": reportedId,
      'name': name,
      'description': description,
      'type': type.index
    };
  }
}
