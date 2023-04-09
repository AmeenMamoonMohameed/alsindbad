class CoordinateModel {
  final String name;
  final double longitude;
  final double latitude;

  CoordinateModel({
    required this.name,
    required this.longitude,
    required this.latitude,
  });

  factory CoordinateModel.fromJson(Map<String, dynamic> json) {
    return CoordinateModel(
      name: json['name'] ?? 'Unknown',
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
    );
  }
}
