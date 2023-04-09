class RateModel {
  final double one;
  final double two;
  final double three;
  final double four;
  final double five;
  final double avg;
  final int total;

  RateModel({
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
    required this.avg,
    required this.total,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) {
    return RateModel(
      one: json['one'] / json['total'] ?? 0.0,
      two: json['two'] / json['total'] ?? 0.0,
      three: json['three'] / json['total'] ?? 0.0,
      four: json['four'] / json['total'] ?? 0.0,
      five: json['five'] / json['total'] ?? 0.0,
      avg: double.tryParse(json['avg'].toString()) ?? 0.0,
      total: json['total'] ?? 0,
    );
  }
}
