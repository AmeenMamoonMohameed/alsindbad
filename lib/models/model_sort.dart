class SortModel {
  final String name;
  final String? attr;
  final dynamic value;
  final String field;

  SortModel({
    required this.name,
    this.attr,
    required this.value,
    required this.field,
  });

  factory SortModel.fromJson(Map<String, dynamic> json) {
    return SortModel(
      name: json['langKey'] ?? "Unknown",
      attr: json['attr'],
      value: json['value'] ?? "Unknown",
      field: json['field'] ?? "Unknown",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'attr': attr,
      'value': value,
      'field': field,
    };
  }
}
