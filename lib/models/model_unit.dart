class UnitModel {
  final int id;
  final String code;
  final String name;
  final bool isDefault;
  final double exchange;
  final String? icon = null;
  final List<int> countries;

  UnitModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isDefault,
    required this.exchange,
    required this.countries,
  });

  @override
  bool operator ==(Object other) => other is UnitModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? 'Unknown',
      name: "${json['code'] ?? 'Unknown'} - ${json['name'] ?? 'Unknown'}",
      isDefault: json['isDefault'] ?? false,
      exchange: double.tryParse(json['exchange'].toString()) ?? 0.0,
      countries: List.from(json['countries']).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'isDefault': isDefault,
      'exchange': exchange,
      'countries': countries,
    };
  }
}
